--[[
  ak4y-advancedHunting — オープンなサーバー実装（QBCore / oxmysql）
  元の Luraph 難読化ファイルは監査不能なため置き換え。
  インベントリは ox_inventory 優先（未使用時は付与・削除が失敗し得ます）。
]]

local QBCore = exports['qb-core']:GetCoreObject()
local usedRedeemCodes = {}

local function giveItem(src, item, amount)
    amount = tonumber(amount) or 1
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(src, item, amount)
    end
    if GetResourceState('qb-inventory') == 'started' then
        return exports['qb-inventory']:AddItem(src, item, amount, false, false, 'ak4y-advancedHunting')
    end
    return false
end

local function removeItem(src, item, amount)
    amount = tonumber(amount) or 1
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:RemoveItem(src, item, amount)
    end
    if GetResourceState('qb-inventory') == 'started' then
        return exports['qb-inventory']:RemoveItem(src, item, amount, false, 'ak4y-advancedHunting')
    end
    return false
end

local function searchCount(src, item)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:Search(src, 'count', item) or 0
    end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return 0 end
    local ok, it = pcall(function() return Player.Functions.GetItemByName(item) end)
    if ok and it then return it.amount or it.count or 0 end
    return 0
end

local function defaultTasksJson()
    local t = {}
    for i = 1, #AK4Y.Tasks do
        t[i] = { hasCount = 0, taken = false }
    end
    return json.encode(t)
end

local function parseTasks(jsonStr)
    if not jsonStr or jsonStr == '' then return nil end
    local ok, data = pcall(json.decode, jsonStr)
    if not ok or type(data) ~= 'table' then return nil end
    return data
end

local function ensureRow(citizenid)
    local row = MySQL.single.await('SELECT * FROM ak4y_advancedhunting WHERE citizenid = ? LIMIT 1', { citizenid })
    if row then return row end
    MySQL.insert.await(
        'INSERT INTO ak4y_advancedhunting (citizenid, currentXP, tasks, taskResetTime) VALUES (?, 0, ?, NOW())',
        { citizenid, defaultTasksJson() }
    )
    return MySQL.single.await('SELECT * FROM ak4y_advancedhunting WHERE citizenid = ? LIMIT 1', { citizenid })
end

local function maybeResetTasks(row)
    local cid = row.citizenid
    local tr = MySQL.scalar.await('SELECT UNIX_TIMESTAMP(taskResetTime) FROM ak4y_advancedhunting WHERE citizenid = ?', { cid })
    tr = tonumber(tr)
    if not tr or tr <= 0 then
        MySQL.update.await('UPDATE ak4y_advancedhunting SET taskResetTime = NOW() WHERE citizenid = ?', { cid })
        return MySQL.single.await('SELECT * FROM ak4y_advancedhunting WHERE citizenid = ? LIMIT 1', { cid })
    end
    local periodDays = tonumber(AK4Y.TaskResetPeriod) or 1
    local nextReset = tr + (periodDays * 86400)
    if os.time() >= nextReset then
        MySQL.update.await(
            'UPDATE ak4y_advancedhunting SET tasks = ?, taskResetTime = NOW() WHERE citizenid = ?',
            { defaultTasksJson(), cid }
        )
        return MySQL.single.await('SELECT * FROM ak4y_advancedhunting WHERE citizenid = ? LIMIT 1', { cid })
    end
    return row
end

local function steamHexTo64(steamIdentifier)
    if not steamIdentifier or steamIdentifier == '' then return nil end
    local hex = steamIdentifier:lower():match('steam:(.+)')
    if not hex then return nil end
    local dec = tonumber(hex, 16)
    if not dec then return nil end
    return tostring(dec + 76561197960265728)
end

local function fetchSteamAvatar(steam64, cb)
    if not SteamApiKey or SteamApiKey == '' or SteamApiKey == 'CHANGE_ME' or not steam64 then
        cb(nil)
        return
    end
    local url = ('https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s'):format(SteamApiKey, steam64)
    PerformHttpRequest(url, function(code, body)
        if code ~= 200 or not body or body == '' then
            cb(nil)
            return
        end
        local ok, data = pcall(json.decode, body)
        if not ok or not data or not data.response or not data.response.players or not data.response.players[1] then
            cb(nil)
            return
        end
        cb(data.response.players[1].avatarfull)
    end, 'GET')
end

local function animalHashToKey(hash)
    hash = tonumber(hash)
    if not hash then return nil end
    for key, def in pairs(AK4Y.AnimalItems) do
        if tonumber(def.hash) == hash then return key, def end
    end
    return nil
end

local function discordLog(title, message)
    if not Discord_Webhook or Discord_Webhook == '' or Discord_Webhook == 'CHANGE_ME' then return end
    PerformHttpRequest(
        Discord_Webhook,
        function() end,
        'POST',
        json.encode({
            username = 'Advanced Hunting',
            embeds = { { title = title, description = message, color = 3066993 } },
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

local lastXpGain = {}

QBCore.Functions.CreateCallback('ak4y-advancedHunting:getLevelData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb({ currentXP = 0 }) return end
    local row = ensureRow(Player.PlayerData.citizenid)
    cb({ currentXP = tonumber(row.currentXP) or 0 })
end)

QBCore.Functions.CreateCallback('ak4y-advancedHunting:getPlayerDetails', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    local cid = Player.PlayerData.citizenid
    local row = ensureRow(cid)
    row = maybeResetTasks(row)
    local tr = MySQL.scalar.await('SELECT UNIX_TIMESTAMP(taskResetTime) FROM ak4y_advancedhunting WHERE citizenid = ?', { cid })
    tr = tonumber(tr) or os.time()
    local periodDays = tonumber(AK4Y.TaskResetPeriod) or 1
    local expiredHour = tr + (periodDays * 86400)
    local steamId = QBCore.Functions.GetIdentifier(source, 'steam')
    local steam64 = steamHexTo64(steamId)
    fetchSteamAvatar(steam64, function(avatarUrl)
        cb({
            currentXP = tonumber(row.currentXP) or 0,
            tasks = row.tasks or defaultTasksJson(),
            taskResetTime = row.taskResetTime,
            expiredHour = expiredHour,
            osTime = os.time(),
            steamid = steam64,
            avatarUrl = avatarUrl or '',
        })
    end)
end)

QBCore.Functions.CreateCallback('ak4y-advancedHunting:taskDone', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    local taskId = tonumber(data and data.taskId)
    if not taskId or taskId < 1 or taskId > #AK4Y.Tasks then cb(false) return end
    local row = ensureRow(Player.PlayerData.citizenid)
    row = maybeResetTasks(row)
    local tasks = parseTasks(row.tasks) or {}
    local entry = tasks[taskId]
    local cfg = AK4Y.Tasks[taskId]
    if not entry or not cfg or entry.taken then cb(false) return end
    if (tonumber(entry.hasCount) or 0) < (tonumber(cfg.requiredCount) or 999) then cb(false) return end
    entry.taken = true
    tasks[taskId] = entry
    local pay = tonumber(cfg.rewardPrice) or 0
    local method = AK4Y.PaymentMethod == 'bank' and 'bank' or 'cash'
    if pay > 0 then Player.Functions.AddMoney(method, pay, 'hunting-task') end
    MySQL.update.await('UPDATE ak4y_advancedhunting SET tasks = ? WHERE citizenid = ?', { json.encode(tasks), Player.PlayerData.citizenid })
    discordLog('Hunting task', ('**%s** task #%s reward $%s'):format(Player.PlayerData.name, tostring(taskId), tostring(pay)))
    cb(true)
end)

QBCore.Functions.CreateCallback('ak4y-advancedHunting:buyItem', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    local uid = tonumber(data and data.itemId)
    if not uid then cb(false) return end
    local cfg
    for _, v in ipairs(AK4Y.MarketPage) do
        if v.uniqueId == uid then cfg = v break end
    end
    if not cfg then cb(false) return end
    local price = tonumber(cfg.itemPrice) or 0
    local method = AK4Y.PaymentMethod == 'bank' and 'bank' or 'cash'
    if price > 0 and not Player.Functions.RemoveMoney(method, price, 'hunting-buy') then cb(false) return end
    local count = tonumber(cfg.itemCount) or 1
    local ok = giveItem(source, cfg.itemName, count)
    if not ok then
        if price > 0 then Player.Functions.AddMoney(method, price, 'hunting-buy-refund') end
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('ak4y-advancedHunting:sellItem', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    local uid = tonumber(data and data.itemId)
    local cnt = tonumber(data and data.itemCount)
    if not uid or not cnt or cnt < 1 or cnt > 500 then cb(false) return end
    local cfg
    for _, v in ipairs(AK4Y.SellItems) do
        if v.uniqueId == uid then cfg = v break end
    end
    if not cfg then cb(false) return end
    local have = searchCount(source, cfg.itemName)
    if have < cnt then cb(false) return end
    if not removeItem(source, cfg.itemName, cnt) then cb(false) return end
    local unit = tonumber(cfg.itemPrice) or 0
    local pay = unit * cnt
    local method = AK4Y.PaymentMethod == 'bank' and 'bank' or 'cash'
    if pay > 0 then Player.Functions.AddMoney(method, pay, 'hunting-sell') end
    cb(true)
end)

QBCore.Functions.CreateCallback('ak4y-advancedHunting:sendInput', function(source, cb, data)
    local input = data and data.input
    if type(input) ~= 'string' or #input < 3 or #input > 64 then cb(false) return end
    if type(RedeemCodes) == 'table' and RedeemCodes[input] and not usedRedeemCodes[input] then
        local xp = tonumber(RedeemCodes[input])
        if xp and xp > 0 and xp <= 1000000 then
            usedRedeemCodes[input] = true
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then cb(false) return end
            local row = ensureRow(Player.PlayerData.citizenid)
            local newXp = (tonumber(row.currentXP) or 0) + xp
            MySQL.update.await('UPDATE ak4y_advancedhunting SET currentXP = ? WHERE citizenid = ?', { newXp, Player.PlayerData.citizenid })
            cb(xp)
            return
        end
    end
    cb(false)
end)

RegisterNetEvent('hunting:RemoveItem', function(itemName)
    local src = source
    if type(itemName) ~= 'string' or #itemName > 64 then return end
    if searchCount(src, itemName) < 1 then return end
    removeItem(src, itemName, 1)
end)

RegisterNetEvent('hunting:updatexp', function()
    local src = source
    local now = os.time()
    if (lastXpGain[src] or 0) + 3 > now then return end
    lastXpGain[src] = now
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local mn = (AK4Y.UpdateXP and tonumber(AK4Y.UpdateXP.min)) or 5
    local mx = (AK4Y.UpdateXP and tonumber(AK4Y.UpdateXP.max)) or 10
    if mx < mn then mn, mx = mx, mn end
    local add = math.random(mn, mx)
    local row = ensureRow(Player.PlayerData.citizenid)
    local newXp = (tonumber(row.currentXP) or 0) + add
    MySQL.update.await('UPDATE ak4y_advancedhunting SET currentXP = ? WHERE citizenid = ?', { newXp, Player.PlayerData.citizenid })
end)

RegisterNetEvent('hunting:itemver', function(items, animalHash)
    local src = source
    if type(items) ~= 'table' then return end
    local basic = items.BasicItem
    local rare = items.RareItem
    if type(basic) ~= 'string' or type(rare) ~= 'string' then return end
    local _, def = animalHashToKey(animalHash)
    if not def or def.BasicItem ~= basic or def.RareItem ~= rare then return end
    local roll = math.random(1, 100)
    local giveName = roll <= 18 and rare or basic
    giveItem(src, giveName, 1)
    if giveName == rare then
        TriggerClientEvent('ak4y-advancedHunting:rareItem', src, animalHash)
    end
    discordLog('Hunting loot', ('**%s** %s'):format(GetPlayerName(src) or '?', giveName))
end)

RegisterNetEvent('ak4y-advancedHunting:taskCountAdd', function(taskId, add)
    local src = source
    taskId = tonumber(taskId)
    add = tonumber(add) or 1
    if add < 1 or add > 5 then return end
    if not taskId or taskId < 1 or taskId > #AK4Y.Tasks then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local row = ensureRow(Player.PlayerData.citizenid)
    row = maybeResetTasks(row)
    local tasks = parseTasks(row.tasks) or {}
    if not tasks[taskId] then tasks[taskId] = { hasCount = 0, taken = false } end
    if tasks[taskId].taken then return end
    local req = tonumber(AK4Y.Tasks[taskId].requiredCount) or 999
    local cur = tonumber(tasks[taskId].hasCount) or 0
    if cur >= req then return end
    tasks[taskId].hasCount = math.min(req, cur + add)
    MySQL.update.await('UPDATE ak4y_advancedhunting SET tasks = ? WHERE citizenid = ?', { json.encode(tasks), Player.PlayerData.citizenid })
end)
