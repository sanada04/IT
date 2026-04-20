local QBCore = exports['qb-core']:GetCoreObject()

local questPed
local enemyPeds = {}
local raidActive = false
local elevatorBusy = false
local dataStolen = false
local dataStealBusy = false

--- GTA の関係グループ名は8文字以内（qb-target と同じく joaat でハッシュ化）
local ENEMY_GROUP_NAME = 'HRAID01'
local ENEMY_REL_GROUP = joaat(ENEMY_GROUP_NAME)

local function notify(msg, ntype)
    QBCore.Functions.Notify(msg, ntype or 'primary')
end

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAPed(hash) then
        return nil
    end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
    return hash
end

local function ensureRelationshipGroup()
    if not DoesRelationshipGroupExist(ENEMY_REL_GROUP) then
        AddRelationshipGroup(ENEMY_GROUP_NAME)
    end
end

local function deleteEnemies()
    for _, ped in ipairs(enemyPeds) do
        if ped and DoesEntityExist(ped) then
            DeletePed(ped)
        end
    end
    enemyPeds = {}
end

local function spawnQuestNpc()
    local cfg = Config.QuestNpc
    local hash = loadModel(cfg.model)
    if not hash then return end

    local c = cfg.coords
    questPed = CreatePed(4, hash, c.x, c.y, c.z - 1.0, c.w, false, true)
    SetEntityAsMissionEntity(questPed, true, true)
    SetEntityInvincible(questPed, true)
    FreezeEntityPosition(questPed, true)
    SetBlockingOfNonTemporaryEvents(questPed, true)

    if cfg.scenario and cfg.scenario ~= '' then
        TaskStartScenarioInPlace(questPed, cfg.scenario, 0, true)
    end

    SetModelAsNoLongerNeeded(hash)

    exports['qb-target']:AddTargetEntity(questPed, {
        options = {
            {
                type = 'client',
                event = 'humane_lab_raid:client:startRaid',
                icon = 'fas fa-skull-crossbones',
                label = Config.Text.targetAccept,
            },
            {
                type = 'client',
                event = 'humane_lab_raid:client:exchangeData',
                icon = 'fas fa-sack-dollar',
                label = Config.Text.targetExchange,
            },
        },
        distance = 2.5,
    })
end

local function useElevator()
    local playerPed = PlayerPedId()
    local elev = Config.Elevator
    local nowPos = GetEntityCoords(playerPed)
    local fromDist = #(nowPos - elev.from)
    local toDist = #(nowPos - elev.to)
    local dst = fromDist <= toDist and elev.to or elev.from

    DoScreenFadeOut(400)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    RequestCollisionAtCoord(dst.x, dst.y, dst.z)
    SetEntityCoords(playerPed, dst.x, dst.y, dst.z, false, false, false, false)
    SetGameplayCamRelativeHeading(0.0)

    Wait(200)
    DoScreenFadeIn(400)
    notify(Config.Text.elevatorDone, 'success')
end

local function setupElevator()
    local elev = Config.Elevator
    if not elev or not elev.from or not elev.to then
        return
    end

    CreateThread(function()
        while true do
            local waitTime = 1000
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local radius = elev.radius or 1.2
            local fromDist = #(pos - elev.from)
            local toDist = #(pos - elev.to)
            local dist = math.min(fromDist, toDist)

            if dist <= radius then
                waitTime = 0
                BeginTextCommandDisplayHelp('STRING')
                AddTextComponentSubstringPlayerName(('~INPUT_CONTEXT~ %s'):format(Config.Text.elevatorUse or 'エレベータを使う'))
                EndTextCommandDisplayHelp(0, false, false, -1)

                if IsControlJustReleased(0, 38) and not elevatorBusy then
                    elevatorBusy = true
                    useElevator()
                    Wait(500)
                    elevatorBusy = false
                end
            elseif dist <= radius + 10.0 then
                waitTime = 200
            end

            Wait(waitTime)
        end
    end)
end

local function tryStealData()
    if dataStealBusy then return end
    if not raidActive then
        notify(Config.Text.dataNeedRaid, 'error')
        return
    end
    if dataStolen then
        notify(Config.Text.dataAlreadyStolen, 'error')
        return
    end

    dataStealBusy = true
    local ped = PlayerPedId()
    local duration = (Config.DataTerminal and Config.DataTerminal.stealDurationMs) or 10000

    notify(Config.Text.stealingData, 'primary')
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', 0, true)

    local endAt = GetGameTimer() + duration
    while GetGameTimer() < endAt do
        Wait(0)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 35, true)
        DisableControlAction(0, 75, true)
    end

    ClearPedTasks(ped)

    if not lib or not lib.callback then
        notify(Config.Text.dataSystemError, 'error')
        dataStealBusy = false
        return
    end

    local result = lib.callback.await('humane_lab_raid:server:rewardUsb', false)
    if result and result.ok then
        dataStolen = true
        notify(Config.Text.dataStolen, 'success')
    else
        local reason = result and result.reason or 'unknown'
        if reason == 'already_has' then
            notify(Config.Text.dataAlreadyHasUsb, 'error')
        elseif reason == 'inventory_full' then
            notify(Config.Text.dataInventoryFull, 'error')
        elseif reason == 'invalid_item' then
            notify(Config.Text.dataInvalidItem, 'error')
        elseif reason == 'too_far' then
            notify(Config.Text.dataFailed, 'error')
        else
            notify(Config.Text.dataSystemError, 'error')
        end
    end

    dataStealBusy = false
end

local function setupDataTerminal()
    local terminal = Config.DataTerminal
    if not terminal or not terminal.coords then
        return
    end

    CreateThread(function()
        while true do
            local waitTime = 1000
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local radius = terminal.radius or 1.5
            local dist = #(pos - terminal.coords)

            if dist <= radius then
                waitTime = 0
                BeginTextCommandDisplayHelp('STRING')
                AddTextComponentSubstringPlayerName(('~INPUT_CONTEXT~ %s'):format(Config.Text.stealData or 'データを盗む'))
                EndTextCommandDisplayHelp(0, false, false, -1)

                if IsControlJustReleased(0, 38) then
                    tryStealData()
                end
            elseif dist <= radius + 8.0 then
                waitTime = 200
            end

            Wait(waitTime)
        end
    end)
end

local function armAndHostile(ped, weaponHash)
    SetPedArmour(ped, 50)
    SetPedAccuracy(ped, 40)
    SetPedSeeingRange(ped, 80.0)
    SetPedHearingRange(ped, 80.0)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatRange(ped, 2)
    SetPedFleeAttributes(ped, 0, false)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    ensureRelationshipGroup()
    SetPedRelationshipGroupHash(ped, ENEMY_REL_GROUP)

    GiveWeaponToPed(ped, weaponHash, 250, false, true)
    SetCurrentPedWeapon(ped, weaponHash, true)

    TaskCombatPed(ped, PlayerPedId(), 0, 16)
end

--- @return boolean
local function spawnEnemies()
    local ecfg = Config.EnemyPeds
    local hash = loadModel(ecfg.model)
    if not hash then
        return false
    end

    deleteEnemies()

    local playerGroup = GetPedRelationshipGroupHash(PlayerPedId())
    SetRelationshipBetweenGroups(5, ENEMY_REL_GROUP, playerGroup)
    SetRelationshipBetweenGroups(5, playerGroup, ENEMY_REL_GROUP)

    for _, pos in ipairs(ecfg.spawns) do
        local ped = CreatePed(4, hash, pos.x, pos.y, pos.z - 1.0, pos.w, false, true)
        if ped and ped ~= 0 then
            SetEntityAsMissionEntity(ped, true, true)
            armAndHostile(ped, ecfg.weapon)
            enemyPeds[#enemyPeds + 1] = ped
        end
    end

    SetModelAsNoLongerNeeded(hash)
    return #enemyPeds > 0
end

RegisterNetEvent('humane_lab_raid:client:startRaid', function()
    if raidActive then
        notify(Config.Text.busy, 'error')
        return
    end
    if not spawnEnemies() then
        notify('敵NPCの生成に失敗しました（モデルまたは座標を確認）', 'error')
        return
    end
    dataStolen = false
    raidActive = true
    notify(Config.Text.accepted, 'success')
end)

RegisterNetEvent('humane_lab_raid:client:exchangeData', function()
    local result = lib.callback.await('humane_lab_raid:server:exchangeData', false)
    if not result or not result.ok then
        if result and result.reason == 'no_usb' then
            notify(Config.Text.exchangeNoUsb, 'error')
        else
            notify(Config.Text.exchangeFailed, 'error')
        end
        return
    end

    -- 換金完了時は襲撃を終了し、残っている敵を掃除する
    deleteEnemies()
    raidActive = false
    dataStolen = false

    notify((Config.Text.exchangeSuccess):format(result.amount or 0), 'success')
end)

--- 敵が全滅したら再度受注できるようにする（任意）
CreateThread(function()
    while true do
        Wait(2000)
        if not raidActive or #enemyPeds == 0 then
            goto continue
        end
        local alive = false
        for _, ped in ipairs(enemyPeds) do
            if ped and DoesEntityExist(ped) and not IsEntityDead(ped) then
                alive = true
                break
            end
        end
        if not alive then
            raidActive = false
            enemyPeds = {}
        end
        ::continue::
    end
end)

CreateThread(function()
    spawnQuestNpc()
    setupElevator()
    setupDataTerminal()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if questPed and DoesEntityExist(questPed) then
        exports['qb-target']:RemoveTargetEntity(questPed)
        DeletePed(questPed)
        questPed = nil
    end

    deleteEnemies()
end)
