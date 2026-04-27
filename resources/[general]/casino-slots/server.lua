local QBCore = exports['qb-core']:GetCoreObject()

math.randomseed(os.time())

-- 確変状態管理 { [playerId] = spinsLeft }
local chanceMode = {}

-- ── 抽選 ──────────────────────────────────────────────────────────────────────

local function weightedRandom(weights)
    local total = 0
    for _, sym in ipairs(Config.Symbols) do
        total = total + (weights[sym.id] or sym.weight)
    end
    local r = math.random(1, total)
    local cumulative = 0
    for _, sym in ipairs(Config.Symbols) do
        cumulative = cumulative + (weights[sym.id] or sym.weight)
        if r <= cumulative then
            return sym.id
        end
    end
    return Config.Symbols[#Config.Symbols].id
end

local function getWeights(playerId)
    if Config.Chance.enabled and (chanceMode[playerId] or 0) > 0 then
        return Config.Chance.symbolWeights
    end
    local w = {}
    for _, sym in ipairs(Config.Symbols) do w[sym.id] = sym.weight end
    return w
end

local function calculatePayout(r1, r2, r3, bet)
    if r1 == r2 and r2 == r3 then
        if r1 == 'seven'   then return bet * Config.Payouts.three_seven,   'jackpot' end
        if r1 == 'diamond' then return bet * Config.Payouts.three_diamond,  'bigwin'  end
        if r1 == 'star'    then return bet * Config.Payouts.three_star,     'bigwin'  end
        return bet * Config.Payouts.three_same, 'win'
    end

    local match = nil
    if r1 == r2 then match = r1 elseif r2 == r3 then match = r2 elseif r1 == r3 then match = r1 end

    if match then
        if match == 'seven'   then return bet * Config.Payouts.two_seven,   'smallwin' end
        if match == 'diamond' then return bet * Config.Payouts.two_diamond,  'smallwin' end
        return bet * Config.Payouts.two_same, 'smallwin'
    end

    return 0, 'lose'
end

-- ── 確変処理 ──────────────────────────────────────────────────────────────────

local function isChanceTrigger(resultType)
    if not Config.Chance.enabled then return false end
    for _, t in ipairs(Config.Chance.triggerOn) do
        if t == resultType then return true end
    end
    return false
end

local function updateChance(playerId, resultType)
    local current = chanceMode[playerId] or 0
    local entered = false

    if isChanceTrigger(resultType) then
        chanceMode[playerId] = Config.Chance.spins
        entered = true
    elseif current > 0 then
        chanceMode[playerId] = current - 1
    end

    return chanceMode[playerId] or 0, entered
end

-- ── スピンコールバック ─────────────────────────────────────────────────────────

lib.callback.register('casino-slots:spin', function(source, bet)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return { success = false, reason = 'error' } end

    local validBet = false
    for _, amount in ipairs(Config.BetAmounts) do
        if bet == amount then validBet = true; break end
    end
    if not validBet then return { success = false, reason = 'invalid_bet' } end

    local cash = player.PlayerData.money['cash']
    if cash < bet then return { success = false, reason = 'no_money' } end

    player.Functions.RemoveMoney('cash', bet, 'casino-slot-bet')

    local weights = getWeights(src)
    local r1 = weightedRandom(weights)
    local r2 = weightedRandom(weights)
    local r3 = weightedRandom(weights)

    local payout, resultType = calculatePayout(r1, r2, r3, bet)
    if payout > 0 then
        player.Functions.AddMoney('cash', payout, 'casino-slot-win')
    end

    local spinsLeft, chanceEntered = updateChance(src, resultType)

    if Config.Debug then
        print(('[casino-slots] src=%d bet=%d reels=%s/%s/%s payout=%d type=%s chance=%d'):format(
            src, bet, r1, r2, r3, payout, resultType, spinsLeft))
    end

    return {
        success      = true,
        reels        = { r1, r2, r3 },
        payout       = payout,
        resultType   = resultType,
        newBalance   = player.PlayerData.money['cash'],
        chanceLeft   = spinsLeft,
        chanceEntered = chanceEntered,
    }
end)

-- ── 切断時のクリーンアップ ────────────────────────────────────────────────────

AddEventHandler('playerDropped', function()
    chanceMode[source] = nil
end)
