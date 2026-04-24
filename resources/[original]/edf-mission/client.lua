local QBCore = nil
do
    local ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
    if ok and core then QBCore = core end
end

local inMission      = false
local isLeader       = false
local savedPos       = nil
local savedHeading   = 0.0
local spawnedUfos    = {}
local spawnedEnemies = {}
local enemyBlips     = {}  -- ped -> blip
local healthPacks    = {}
local waveInfo       = { current = 0, total = 0 }
local monitorActive  = false
local npcPed         = nil
local pendingInvite  = nil  -- { partyId, inviterName, deadline }
local hasDied        = false

local function Notify(msg, t)
    if QBCore then
        QBCore.Functions.Notify(msg, t or 'primary', 5000)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(false, false)
    end
end

local function loadModel(hash)
    if not IsModelValid(hash) then return false end
    RequestModel(hash)
    local deadline = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > deadline then return false end
        Wait(50)
    end
    return true
end

local function DrawText2D(text, x, y, scale)
    SetTextFont(0)
    SetTextScale(0.0, scale or 0.35)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

-- ─── NPC Spawn ────────────────────────────────────────────────────
local function spawnNpc()
    local hash = GetHashKey(Config.NpcModel)
    if not loadModel(hash) then return end

    npcPed = CreatePed(4, hash,
        Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z - 1.0,
        Config.NpcCoords.w, false, false)

    if not DoesEntityExist(npcPed) then return end

    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    SetPedDiesWhenInjured(npcPed, false)
    TaskStartScenarioInPlace(npcPed, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    SetModelAsNoLongerNeeded(hash)

    -- Map blip
    local blip = AddBlipForCoord(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z)
    SetBlipSprite(blip, 153)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('EDF ミッション')
    EndTextCommandSetBlipName(blip)
end

-- ─── Nearby Player List ───────────────────────────────────────────
local function getNearbyPlayers()
    local myPed = PlayerPedId()
    local myPos = GetEntityCoords(myPed)
    local myId  = GetPlayerServerId(PlayerId())
    local list  = {}
    for _, pid in ipairs(GetActivePlayers()) do
        local serverId = GetPlayerServerId(pid)
        if serverId ~= myId then
            local dist = #(myPos - GetEntityCoords(GetPlayerPed(pid)))
            if dist <= Config.InviteRadius then
                list[#list + 1] = {
                    src  = serverId,
                    name = GetPlayerName(pid),
                    dist = math.floor(dist),
                }
            end
        end
    end
    return list
end

-- ─── NPC Interact Loop ────────────────────────────────────────────
CreateThread(function()
    Wait(3000)  -- wait for world load
    spawnNpc()

    while true do
        Wait(0)
        if not DoesEntityExist(npcPed) then
            Wait(5000); spawnNpc()
        else
            local myPos  = GetEntityCoords(PlayerPedId())
            local npcPos = GetEntityCoords(npcPed)
            local dist   = #(myPos - npcPos)

            if dist <= Config.NpcInteractDist and not inMission then
                DrawText2D('[E] EDFミッションを受ける', 0.5, 0.91, 0.38)
                if IsControlJustPressed(0, 38) then  -- E key
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        action        = 'open',
                        nearbyPlayers = getNearbyPlayers(),
                    })
                end
            end
        end
    end
end)

-- ─── Invite Received (in-game prompt) ────────────────────────────
RegisterNetEvent('edf:inviteReceived', function(partyId, inviterName)
    if inMission then
        TriggerServerEvent('edf:respondInvite', partyId, false); return
    end
    pendingInvite = {
        partyId     = partyId,
        inviterName = inviterName,
        deadline    = GetGameTimer() + Config.InviteTimeout * 1000,
    }

    CreateThread(function()
        local inv = pendingInvite
        while pendingInvite == inv and GetGameTimer() < inv.deadline do
            Wait(0)
            local left = math.ceil((inv.deadline - GetGameTimer()) / 1000)
            DrawText2D(
                inv.inviterName .. ' からEDFミッション招待\n[E] 参加   [Backspace] 断る   (' .. left .. '秒)',
                0.5, 0.84, 0.37)

            if IsControlJustPressed(0, 38) then   -- E = accept
                pendingInvite = nil
                TriggerServerEvent('edf:respondInvite', inv.partyId, true)
                return
            end
            if IsControlJustPressed(0, 177) then  -- Backspace = decline
                pendingInvite = nil
                TriggerServerEvent('edf:respondInvite', inv.partyId, false)
                Notify('招待を断りました', 'error')
                return
            end
        end
        -- Timeout
        if pendingInvite == inv then
            pendingInvite = nil
            TriggerServerEvent('edf:respondInvite', inv.partyId, false)
            Notify('招待がタイムアウトしました', 'error')
        end
    end)
end)

-- ─── HUD (wave counter) ───────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(0)
        if inMission and waveInfo.current > 0 then
            DrawText2D('WAVE  ' .. waveInfo.current .. ' / ' .. waveInfo.total, 0.88, 0.04, 0.5)
        end
    end
end)

-- ─── 弾薬補充スレッド ──────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(2000)
        if inMission then
            local ped = PlayerPedId()
            for _, w in ipairs(Config.PlayerWeapons) do
                local hash = GetHashKey(w.name)
                if HasPedGotWeapon(ped, hash, false) then
                    SetPedAmmo(ped, hash, w.ammo)
                end
            end
        end
    end
end)

-- ─── Health Pack Pickup & Respawn ────────────────────────────────
CreateThread(function()
    while true do
        Wait(300)
        if inMission then
            local ped   = PlayerPedId()
            local pos   = GetEntityCoords(ped)
            local hp    = GetEntityHealth(ped)
            local maxHp = GetEntityMaxHealth(ped)
            local armor = GetPedArmour(ped)

            -- Pickup check
            if hp < maxHp or armor < 200 then
                for _, pk in ipairs(healthPacks) do
                    if pk.exists and DoesEntityExist(pk.obj) then
                        if #(pos - GetEntityCoords(pk.obj)) <= Config.HealthPackDistance then
                            SetEntityHealth(ped, maxHp)
                            SetPedArmour(ped, 200)
                            ClearPedBloodDamage(ped)
                            DeleteObject(pk.obj)
                            pk.exists    = false
                            pk.respawnAt = GetGameTimer() + Config.HealthPackRespawnInterval * 1000
                            Notify('回復パックを使用しました！', 'success')
                            break
                        end
                    end
                end
            end

            -- Respawn check
            local alive = 0
            for _, pk in ipairs(healthPacks) do
                if pk.exists then alive = alive + 1 end
            end
            if alive < Config.HealthPackMax then
                local hash = GetHashKey(Config.HealthPackModel)
                RequestModel(hash)
                for _, pk in ipairs(healthPacks) do
                    if not pk.exists and pk.respawnAt and GetGameTimer() >= pk.respawnAt then
                        if HasModelLoaded(hash) then
                            local obj = spawnOneHealthPack(hash, pk.px, pk.py, pk.pz)
                            if obj then
                                pk.obj       = obj
                                pk.exists    = true
                                pk.respawnAt = nil
                                alive        = alive + 1
                                if alive >= Config.HealthPackMax then break end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ─── UFO Helpers ──────────────────────────────────────────────────
local function spawnUfo(x, y, z)
    local vh = GetHashKey('hydra')
    local oh = GetHashKey('p_spinning_anus_s')
    if not loadModel(vh) or not loadModel(oh) then return nil end

    local veh = CreateVehicle(vh, x, y, z, 0.0, true, false)
    if not DoesEntityExist(veh) then return nil end

    SetEntityInvincible(veh, true)
    SetVehicleEngineOn(veh, true, true, false)
    FreezeEntityPosition(veh, true)
    SetVehicleUndriveable(veh, true)

    local obj = CreateObject(oh, x, y, z, true, false, false)
    AttachEntityToEntity(obj, veh, 0,
        0.0, 0.0, -0.6, 0.0, 0.0, 180.0,
        false, false, false, false, 2, true)

    SetModelAsNoLongerNeeded(vh)
    SetModelAsNoLongerNeeded(oh)
    return { veh = veh, obj = obj }
end

local function cleanupUfos()
    for _, u in ipairs(spawnedUfos) do
        if DoesEntityExist(u.veh) then DeleteVehicle(u.veh) end
        if DoesEntityExist(u.obj) then DeleteObject(u.obj) end
    end
    spawnedUfos = {}
end

-- ─── Enemy Helpers ────────────────────────────────────────────────
local function retargetEnemy(ped)
    local nearest, nearDist = nil, 9999
    for _, pid in ipairs(GetActivePlayers()) do
        local pp   = GetPlayerPed(pid)
        local dist = #(GetEntityCoords(ped) - GetEntityCoords(pp))
        if dist < nearDist then nearDist = dist; nearest = pp end
    end
    if nearest then TaskCombatPed(ped, nearest, 0, 16) end
end

local function spawnEnemy(x, y, z, health, armor)
    -- ロードできる最初のモデルを使用
    local hash = nil
    for _, model in ipairs(Config.EnemyModels) do
        local h = GetHashKey(model)
        if IsModelValid(h) and loadModel(h) then
            hash = h; break
        end
    end
    if not hash then return nil end

    local ped = CreatePed(4, hash, x, y, z, math.random(0, 359), true, false)
    if not DoesEntityExist(ped) then return nil end

    SetEntityMaxHealth(ped, health + 100)
    SetEntityHealth(ped, health + 100)
    SetPedArmour(ped, armor)

    -- 素手で突進させる
    GiveWeaponToPed(ped, GetHashKey('WEAPON_UNARMED'), 0, false, true)
    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
    SetPedCombatAttributes(ped, 46, false)  -- カバー使用禁止
    SetPedCombatAttributes(ped, 5,  true)   -- 武装した相手にも突撃
    SetPedCombatAttributes(ped, 17, true)   -- 常に戦闘継続
    SetPedCombatRange(ped, 0)               -- 近距離戦闘
    SetPedFleeAttributes(ped, 0, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    retargetEnemy(ped)

    -- 赤いブリップを追加
    local blip = AddBlipForEntity(ped)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 1)   -- 赤
    SetBlipScale(blip, 0.65)
    SetBlipDisplay(blip, 2)
    enemyBlips[ped] = blip

    SetModelAsNoLongerNeeded(hash)
    return ped
end

local function cleanupEnemies()
    for _, ped in ipairs(spawnedEnemies) do
        local blip = enemyBlips[ped]
        if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
        if DoesEntityExist(ped) then DeletePed(ped) end
    end
    spawnedEnemies = {}
    enemyBlips     = {}
end

-- ─── Health Pack Spawn ────────────────────────────────────────────
local function spawnOneHealthPack(hash, px, py, pz)
    local obj = CreateObject(hash, px, py, pz, false, false, false)
    if not DoesEntityExist(obj) then return nil end
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, true, true)
    return obj
end

local function spawnHealthPacks()
    for _, pk in ipairs(healthPacks) do
        if DoesEntityExist(pk.obj) then DeleteObject(pk.obj) end
    end
    healthPacks = {}

    local hash = GetHashKey(Config.HealthPackModel)
    if not loadModel(hash) then return end

    local fz = Config.MissionArea.z + Config.HealthPackFloatHeight
    for _, off in ipairs(Config.HealthPackOffsets) do
        local px = Config.MissionArea.x + off.x
        local py = Config.MissionArea.y + off.y
        local obj = spawnOneHealthPack(hash, px, py, fz)
        if obj then
            healthPacks[#healthPacks + 1] = { obj = obj, exists = true, respawnAt = nil, px = px, py = py, pz = fz }
        end
    end
    SetModelAsNoLongerNeeded(hash)
end

-- ─── Wave Spawn (Leader Only) ─────────────────────────────────────
RegisterNetEvent('edf:spawnWave', function(wave, total, count, health, armor, ufoCount)
    if not isLeader then return end
    waveInfo = { current = wave, total = total }

    CreateThread(function()
        if wave == 1 then
            cleanupUfos()
            for i = 1, math.min(ufoCount, #Config.UfoOffsets) do
                local off = Config.UfoOffsets[i]
                local u = spawnUfo(
                    Config.MissionArea.x + off.x,
                    Config.MissionArea.y + off.y,
                    Config.MissionArea.z + off.z)
                if u then spawnedUfos[#spawnedUfos + 1] = u end
            end
        end

        cleanupEnemies()
        Wait(300)

        local spawned = 0
        for i = 1, count do
            local off = Config.EnemyDropOffsets[((i - 1) % #Config.EnemyDropOffsets) + 1]
            local rx  = (math.random() - 0.5) * 18
            local ry  = (math.random() - 0.5) * 18
            local ped = spawnEnemy(
                Config.MissionArea.x + off.x + rx,
                Config.MissionArea.y + off.y + ry,
                Config.MissionArea.z,
                health, armor)
            if ped then spawnedEnemies[#spawnedEnemies + 1] = ped; spawned = spawned + 1 end
            Wait(80)
        end

        TriggerServerEvent('edf:waveSpawned', spawned)

        if monitorActive then return end
        monitorActive = true
        local tracked = {}

        -- Death detection
        CreateThread(function()
            while inMission and isLeader do
                Wait(400)
                for _, ped in ipairs(spawnedEnemies) do
                    if not tracked[ped] and DoesEntityExist(ped) and IsEntityDead(ped) then
                        tracked[ped] = true
                        -- ブリップを即削除
                        local blip = enemyBlips[ped]
                        if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
                        enemyBlips[ped] = nil
                        -- キルを報告
                        local killerEnt = GetPedSourceOfDeath(ped)
                        local killerSrc = 0
                        if DoesEntityExist(killerEnt) then
                            local pidx = NetworkGetPlayerIndexFromPed(killerEnt)
                            if pidx >= 0 then killerSrc = GetPlayerServerId(pidx) end
                        end
                        TriggerServerEvent('edf:reportKill', killerSrc)
                    end
                end
            end
            monitorActive = false
        end)

        -- Periodic retarget
        CreateThread(function()
            while inMission and isLeader do
                Wait(3000)
                for _, ped in ipairs(spawnedEnemies) do
                    if DoesEntityExist(ped) and not IsEntityDead(ped) then
                        retargetEnemy(ped)
                    end
                end
            end
        end)
    end)
end)

-- ─── Mission Start ────────────────────────────────────────────────
RegisterNetEvent('edf:missionStart', function(difficulty, spawnPos, amILeader)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    savedPos     = vector3(pos.x, pos.y, pos.z)
    savedHeading = GetEntityHeading(ped)

    inMission      = true
    isLeader       = amILeader
    monitorActive  = false
    pendingInvite  = nil
    hasDied        = false
    waveInfo       = { current = 0, total = (Config.Difficulties[difficulty] and Config.Difficulties[difficulty].waves) or 0 }

    SetEntityCoords(ped, spawnPos.x, spawnPos.y, spawnPos.z, false, false, false, true)
    Wait(300)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 200)

    RemoveAllPedWeapons(ped, true)
    Wait(100)
    for _, w in ipairs(Config.PlayerWeapons) do
        GiveWeaponToPed(ped, GetHashKey(w.name), w.ammo, false, false)
    end

    spawnHealthPacks()

    local diffLabel = (Config.Difficulties[difficulty] and Config.Difficulties[difficulty].label) or difficulty
    SendNUIMessage({ action = 'missionStart' })
    Notify('ミッション開始！ 難易度: ' .. diffLabel, 'primary')
end)

-- ─── 自分の死亡検知 → 全滅チェック ──────────────────────────────
CreateThread(function()
    while true do
        Wait(500)
        if inMission and not hasDied and IsEntityDead(PlayerPedId()) then
            hasDied = true
            TriggerServerEvent('edf:playerDied')
        end
    end
end)

-- ─── Wave Announce (countdown) ───────────────────────────────────
RegisterNetEvent('edf:waveAnnounce', function(wave, total, countdown)
    waveInfo  = { current = wave, total = total }
    countdown = countdown or 3

    SendNUIMessage({ action = 'countdown', wave = wave, total = total, seconds = countdown })

    -- 音付きカウントダウン
    CreateThread(function()
        for i = countdown, 1, -1 do
            PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            Wait(1000)
        end
        PlaySoundFrontend(-1, 'WAYPOINT_SET', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    end)
end)

-- ─── Kill Update ──────────────────────────────────────────────────
RegisterNetEvent('edf:killUpdate', function(kills, alive)
    SendNUIMessage({ action = 'killUpdate', kills = kills, alive = alive })
end)

-- ─── Mission End ──────────────────────────────────────────────────
RegisterNetEvent('edf:missionEnd', function(success, ranking)
    local myId = GetPlayerServerId(PlayerId())
    SetNuiFocus(true, true)
    SendNUIMessage({
        action  = 'missionEnd',
        success = success,
        ranking = ranking,
        myId    = myId,
    })
end)

-- ─── Return to City ───────────────────────────────────────────────
RegisterNetEvent('edf:returnToCity', function()
    cleanupUfos()
    cleanupEnemies()
    for _, pk in ipairs(healthPacks) do
        if DoesEntityExist(pk.obj) then DeleteObject(pk.obj) end
    end
    healthPacks   = {}
    inMission     = false
    isLeader      = false
    monitorActive = false
    pendingInvite = nil
    hasDied       = false
    waveInfo      = { current = 0, total = 0 }

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    CreateThread(function()
        -- フェードアウト
        DoScreenFadeOut(800)
        Wait(900)

        local ped = PlayerPedId()
        local rx  = savedPos and savedPos.x or Config.NpcCoords.x
        local ry  = savedPos and savedPos.y or Config.NpcCoords.y
        local rz  = savedPos and savedPos.z or Config.NpcCoords.z
        local rh  = savedPos and savedHeading or Config.NpcCoords.w

        -- 復活 (死亡状態を解除してから移動)
        if IsEntityDead(ped) then
            NetworkResurrectLocalPlayer(rx, ry, rz, rh, true, false)
            Wait(200)
        end

        SetEntityCoords(ped, rx, ry, rz, false, false, false, true)
        SetEntityHeading(ped, rh)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        SetPedArmour(ped, 0)
        ClearPedTasksImmediately(ped)
        RemoveAllPedWeapons(ped, true)

        savedPos = nil

        Wait(400)
        -- フェードイン
        DoScreenFadeIn(1000)

        Notify('ミッション終了。街に戻りました', 'primary')
    end)
end)

-- ─── Party Updated ────────────────────────────────────────────────
RegisterNetEvent('edf:partyUpdated', function(partyData)
    SendNUIMessage({ action = 'partyUpdated', party = partyData })
end)

-- ─── Notify ───────────────────────────────────────────────────────
RegisterNetEvent('edf:notify', function(msg, t)
    Notify(msg, t)
end)

-- ─── NUI Callbacks ────────────────────────────────────────────────
RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('createParty', function(data, cb)
    -- メニューを開いたまま維持（パーティ管理を続けるため）
    TriggerServerEvent('edf:createParty', data.difficulty or 'normal')
    cb('ok')
end)

RegisterNUICallback('invitePlayer', function(data, cb)
    -- Menu stays open; invite is sent while menu is visible
    TriggerServerEvent('edf:sendInvite', tonumber(data.targetSrc))
    cb('ok')
end)

RegisterNUICallback('leaveParty', function(_, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('edf:leaveParty')
    SendNUIMessage({ action = 'close' })  -- UIパネルも閉じる
    cb('ok')
end)

RegisterNUICallback('startMission', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('edf:startMission', data.difficulty or 'normal')
    cb('ok')
end)

RegisterNUICallback('resultClose', function(_, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('edf:requestReturn')
    cb('ok')
end)

-- ─── Fallback command (admin/test) ───────────────────────────────
RegisterNetEvent('edf:openMenu', function()
    if inMission then Notify('ミッション中はメニューを開けません', 'error'); return end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', nearbyPlayers = getNearbyPlayers() })
end)
