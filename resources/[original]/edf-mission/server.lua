local parties             = {}  -- partyId -> party table
local playerParty         = {}  -- src -> partyId
local invites             = {}  -- targetSrc -> { partyId, inviterSrc, inviterName }
local missionSavedWeapons = {}  -- src -> array of saved weapon entries

local function newId()
    return tostring(math.floor(math.random() * 90000) + 10000)
end

local function partyInfo(pid)
    local p = parties[pid]
    if not p then return nil end
    local members = {}
    for _, src in ipairs(p.members) do
        members[#members + 1] = { src = src, name = GetPlayerName(src) }
    end
    return {
        id         = pid,
        leader     = p.leader,
        members    = members,
        state      = p.state,
        difficulty = p.difficulty,
    }
end

local function broadcastParty(pid, event, ...)
    local p = parties[pid]
    if not p then return end
    for _, src in ipairs(p.members) do
        TriggerClientEvent(event, src, ...)
    end
end

local function removeMember(pid, src)
    local p = parties[pid]
    if not p then return end
    local new = {}
    for _, m in ipairs(p.members) do
        if m ~= src then new[#new + 1] = m end
    end
    p.members = new
    p.kills[src] = nil
    playerParty[src] = nil
end

-- ─── ox_inventory Weapon Save / Restore ──────────────────────────

local function saveAndClearWeapons(src)
    local inv = exports.ox_inventory:GetInventoryItems(src)
    local saved = {}
    if inv then
        for slot, item in pairs(inv) do
            if item and item.name and item.name:sub(1, 7) == 'WEAPON_' then
                saved[#saved + 1] = {
                    name     = item.name,
                    count    = item.count or 1,
                    metadata = item.metadata or {},
                    slot     = item.slot or slot,
                }
                exports.ox_inventory:RemoveItem(src, item.name, item.count or 1, item.metadata, item.slot or slot)
            end
        end
    end
    missionSavedWeapons[src] = saved
end

local function giveMissionWeapons(src)
    for _, w in ipairs(Config.PlayerWeapons) do
        exports.ox_inventory:AddItem(src, w.name, 1, { ammo = w.ammo })
    end
end

local function restoreWeapons(src)
    if not missionSavedWeapons[src] then return end
    for _, w in ipairs(Config.PlayerWeapons) do
        exports.ox_inventory:RemoveItem(src, w.name, 1)
    end
    for _, w in ipairs(missionSavedWeapons[src]) do
        exports.ox_inventory:AddItem(src, w.name, w.count, w.metadata)
    end
    missionSavedWeapons[src] = nil
end

local function endMission(pid, success)
    local p = parties[pid]
    if not p or p.state == 'ended' then return end
    p.state = 'ended'

    local ranking = {}
    for src, k in pairs(p.kills) do
        ranking[#ranking + 1] = { src = src, name = GetPlayerName(src), kills = k }
    end
    table.sort(ranking, function(a, b) return a.kills > b.kills end)

    broadcastParty(pid, 'edf:missionEnd', success, ranking)

    -- Return players to city after 15 s, then dissolve party
    SetTimeout(15000, function()
        if not parties[pid] then return end
        for _, m in ipairs(parties[pid].members) do
            restoreWeapons(m)
        end
        broadcastParty(pid, 'edf:returnToCity')
        SetTimeout(3000, function()
            if not parties[pid] then return end
            for _, m in ipairs(parties[pid].members) do
                playerParty[m] = nil
            end
            parties[pid] = nil
        end)
    end)
end

local function spawnNextWave(pid)
    local p = parties[pid]
    if not p or p.state ~= 'active' then return end
    p.wave = p.wave + 1

    if p.wave > p.totalWaves then
        endMission(pid, true)
        return
    end

    local diff = Config.Difficulties[p.difficulty]
    -- カウントダウン付きでアナウンス
    broadcastParty(pid, 'edf:waveAnnounce', p.wave, p.totalWaves, Config.CountdownSeconds)
    -- カウントダウン後にスポーン
    SetTimeout(Config.CountdownSeconds * 1000, function()
        if not parties[pid] or parties[pid].state ~= 'active' then return end
        TriggerClientEvent('edf:spawnWave', p.leader, p.wave, p.totalWaves,
            diff.perWave, diff.health, diff.armor, diff.ufos)
    end)
end

-- ─── Shared join logic ────────────────────────────────────────────

local function tryJoinParty(src, pid)
    if playerParty[src] then
        TriggerClientEvent('edf:notify', src, 'すでにパーティに参加しています', 'error'); return false
    end
    local p = parties[pid]
    if not p then
        TriggerClientEvent('edf:notify', src, 'パーティが見つかりません', 'error'); return false
    end
    if p.state ~= 'waiting' then
        TriggerClientEvent('edf:notify', src, 'ミッション中は参加できません', 'error'); return false
    end
    if #p.members >= Config.MaxPartySize then
        TriggerClientEvent('edf:notify', src, 'パーティが満員です', 'error'); return false
    end
    p.members[#p.members + 1] = src
    p.kills[src] = 0
    playerParty[src] = pid
    broadcastParty(pid, 'edf:partyUpdated', partyInfo(pid))
    TriggerClientEvent('edf:notify', src, 'パーティに参加しました', 'success')
    return true
end

-- ─── Party Management ─────────────────────────────────────────────

RegisterNetEvent('edf:createParty', function(difficulty)
    local src = source
    if playerParty[src] then
        TriggerClientEvent('edf:notify', src, 'すでにパーティに参加しています', 'error'); return
    end
    if not Config.Difficulties[difficulty] then difficulty = 'normal' end

    local pid = newId()
    parties[pid] = {
        id         = pid,
        leader     = src,
        members    = { src },
        state      = 'waiting',
        difficulty = difficulty,
        kills      = { [src] = 0 },
        wave       = 0,
        totalWaves = Config.Difficulties[difficulty].waves,
        aliveEnemies = 0,
    }
    playerParty[src] = pid
    TriggerClientEvent('edf:partyUpdated', src, partyInfo(pid))
    TriggerClientEvent('edf:notify', src,
        'パーティを作成しました。ID: ' .. pid, 'success')
end)

-- ─── Invite System ────────────────────────────────────────────────

RegisterNetEvent('edf:sendInvite', function(targetSrc)
    local src = source
    local pid = playerParty[src]
    if not pid then
        TriggerClientEvent('edf:notify', src, 'パーティに参加していません', 'error'); return
    end
    local p = parties[pid]
    if not p or p.state ~= 'waiting' then
        TriggerClientEvent('edf:notify', src, 'ミッション中は招待できません', 'error'); return
    end
    if p.leader ~= src then
        TriggerClientEvent('edf:notify', src, 'リーダーのみ招待できます', 'error'); return
    end
    if #p.members >= Config.MaxPartySize then
        TriggerClientEvent('edf:notify', src, 'パーティが満員です', 'error'); return
    end
    targetSrc = tonumber(targetSrc)
    if not targetSrc or not GetPlayerName(targetSrc) then
        TriggerClientEvent('edf:notify', src, '対象プレイヤーが見つかりません', 'error'); return
    end
    if playerParty[targetSrc] then
        TriggerClientEvent('edf:notify', src, 'そのプレイヤーはすでにパーティに参加しています', 'error'); return
    end
    if invites[targetSrc] then
        TriggerClientEvent('edf:notify', src, 'すでに招待済みです', 'error'); return
    end

    local inviterName = GetPlayerName(src)
    invites[targetSrc] = { partyId = pid, inviterSrc = src, inviterName = inviterName }
    TriggerClientEvent('edf:inviteReceived', targetSrc, pid, inviterName)
    TriggerClientEvent('edf:notify', src, GetPlayerName(targetSrc) .. ' に招待を送りました', 'success')

    -- Auto-expire invite
    SetTimeout(Config.InviteTimeout * 1000 + 1000, function()
        if invites[targetSrc] and invites[targetSrc].partyId == pid then
            invites[targetSrc] = nil
        end
    end)
end)

RegisterNetEvent('edf:respondInvite', function(partyId, accepted)
    local src = source
    local inv = invites[src]
    if not inv or inv.partyId ~= partyId then return end
    invites[src] = nil

    if not accepted then
        local inviterSrc = inv.inviterSrc
        if GetPlayerName(inviterSrc) then
            TriggerClientEvent('edf:notify', inviterSrc,
                GetPlayerName(src) .. ' が招待を断りました', 'error')
        end
        return
    end

    tryJoinParty(src, partyId)
end)

RegisterNetEvent('edf:leaveParty', function()
    local src = source
    local pid = playerParty[src]
    if not pid then return end
    local p = parties[pid]
    if not p then playerParty[src] = nil; return end

    removeMember(pid, src)
    TriggerClientEvent('edf:notify', src, 'パーティを離脱しました', 'primary')

    if #p.members == 0 then
        parties[pid] = nil; return
    end
    if p.leader == src then
        p.leader = p.members[1]
        TriggerClientEvent('edf:notify', p.leader, 'リーダーになりました', 'primary')
    end
    broadcastParty(pid, 'edf:partyUpdated', partyInfo(pid))
end)

RegisterNetEvent('edf:startMission', function(difficulty)
    local src = source
    local pid = playerParty[src]

    -- ソロ: パーティがなければ自動作成
    if not pid then
        if not Config.Difficulties[difficulty] then difficulty = 'normal' end
        pid = newId()
        parties[pid] = {
            id           = pid,
            leader       = src,
            members      = { src },
            state        = 'waiting',
            difficulty   = difficulty,
            kills        = { [src] = 0 },
            wave         = 0,
            totalWaves   = Config.Difficulties[difficulty].waves,
            aliveEnemies = 0,
        }
        playerParty[src] = pid
    end

    local p = parties[pid]
    if p.leader ~= src then
        TriggerClientEvent('edf:notify', src, 'リーダーのみ開始できます', 'error'); return
    end
    if p.state ~= 'waiting' then
        TriggerClientEvent('edf:notify', src, 'すでに開始されています', 'error'); return
    end

    p.state      = 'active'
    p.wave       = 0
    p.kills      = {}
    p.aliveCount = #p.members
    for _, m in ipairs(p.members) do p.kills[m] = 0 end

    -- Build per-player spawn coords
    local spawnData = {}
    for i, m in ipairs(p.members) do
        local off = Config.PlayerSpawnOffsets[i] or { x = 0, y = 0 }
        spawnData[m] = {
            x = Config.MissionArea.x + off.x,
            y = Config.MissionArea.y + off.y,
            z = Config.MissionArea.z,
        }
    end

    for _, m in ipairs(p.members) do
        saveAndClearWeapons(m)
        giveMissionWeapons(m)
        TriggerClientEvent('edf:missionStart', m, p.difficulty, spawnData[m], m == p.leader)
    end

    SetTimeout(Config.WaveStartDelay, function()
        spawnNextWave(pid)
    end)
end)

-- ─── In-Mission Events ────────────────────────────────────────────

RegisterNetEvent('edf:waveSpawned', function(count)
    local src = source
    local pid = playerParty[src]
    if not pid then return end
    local p = parties[pid]
    if not p or p.state ~= 'active' then return end
    if src ~= p.leader then return end
    p.aliveEnemies = count
end)

RegisterNetEvent('edf:reportKill', function(killerSrc)
    local src = source
    local pid = playerParty[src]
    if not pid then return end
    local p = parties[pid]
    if not p or p.state ~= 'active' then return end
    if src ~= p.leader then return end  -- only leader reports

    killerSrc = tonumber(killerSrc) or 0
    if killerSrc ~= 0 and p.kills[killerSrc] then
        p.kills[killerSrc] = p.kills[killerSrc] + 1
    end

    p.aliveEnemies = math.max(0, p.aliveEnemies - 1)

    -- Broadcast live kill counts
    local killList = {}
    for s, k in pairs(p.kills) do
        killList[tostring(s)] = k
    end
    broadcastParty(pid, 'edf:killUpdate', killList, p.aliveEnemies)

    if p.aliveEnemies <= 0 then
        SetTimeout(Config.WaveClearDelay, function()
            spawnNextWave(pid)
        end)
    end
end)

-- ─── Player Death (全滅チェック) ─────────────────────────────────

RegisterNetEvent('edf:playerDied', function()
    local src = source
    local pid = playerParty[src]
    if not pid then return end
    local p = parties[pid]
    if not p or p.state ~= 'active' then return end

    p.aliveCount = math.max(0, (p.aliveCount or 1) - 1)
    if p.aliveCount <= 0 then
        endMission(pid, false)
    end
end)

-- ─── Disconnect Cleanup ───────────────────────────────────────────

AddEventHandler('playerDropped', function()
    local src = source
    local pid = playerParty[src]
    if not pid then return end
    local p = parties[pid]
    if not p then playerParty[src] = nil; return end

    local wasActive = p.state == 'active'
    removeMember(pid, src)

    if #p.members == 0 then
        parties[pid] = nil; return
    end

    if wasActive then
        p.aliveCount = math.max(0, (p.aliveCount or 1) - 1)
        if p.aliveCount <= 0 then
            endMission(pid, false); return
        end
    end

    if p.leader == src then p.leader = p.members[1] end
    broadcastParty(pid, 'edf:partyUpdated', partyInfo(pid))
end)

-- ─── Early Return ─────────────────────────────────────────────────

RegisterNetEvent('edf:requestReturn', function()
    local src = source
    local pid = playerParty[src]
    if not pid then return end
    local p = parties[pid]
    if not p or p.state ~= 'ended' then return end
    restoreWeapons(src)
    TriggerClientEvent('edf:returnToCity', src)
end)

-- ─── Command ──────────────────────────────────────────────────────

RegisterCommand('edf', function(src)
    TriggerClientEvent('edf:openMenu', src)
end, false)
