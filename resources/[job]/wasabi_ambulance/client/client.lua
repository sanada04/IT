-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local framework = 'esx'
local QBCore = nil
local targetType = nil

if GetResourceState('qtarget') == 'started' then
    targetType = 'qtarget'
elseif GetResourceState('qb-target') == 'started' then
    targetType = 'qb-target'
end

local function addTargetModel(models, data)
    if targetType == 'qtarget' then
        exports.qtarget:AddTargetModel(models, data)
    elseif targetType == 'qb-target' then
        exports['qb-target']:AddTargetModel(models, data)
    end
end

local function addPlayerTarget(data)
    if targetType == 'qtarget' then
        exports.qtarget:Player(data)
    elseif targetType == 'qb-target' then
        exports['qb-target']:AddGlobalPlayer(data)
    end
end

local function addBoxZone(name, coords, width, length, zoneData, targetData)
    if targetType == 'qtarget' then
        exports.qtarget:AddBoxZone(name, coords, width, length, zoneData, targetData)
    elseif targetType == 'qb-target' then
        exports['qb-target']:AddBoxZone(name, coords, width, length, zoneData, targetData)
    end
end

local function removeZone(name)
    if targetType == 'qtarget' then
        exports.qtarget:RemoveZone(name)
    elseif targetType == 'qb-target' then
        exports['qb-target']:RemoveZone(name)
    end
end

-- ox_lib の第2引数は待ち時間(ms)。100 だとストリーミング負荷で即タイムアウトする。
local function loadAnimDict(dict, timeoutMs)
    timeoutMs = timeoutMs or 15000
    if lib and lib.requestAnimDict then
        local ok = pcall(function()
            lib.requestAnimDict(dict, timeoutMs)
        end)
        if ok and HasAnimDictLoaded(dict) then
            return true
        end
    end
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local deadline = GetGameTimer() + timeoutMs
        while not HasAnimDictLoaded(dict) do
            if GetGameTimer() > deadline then
                return false
            end
            Wait(10)
        end
    end
    return true
end

local function loadModel(modelNameOrHash, timeoutMs)
    timeoutMs = timeoutMs or 15000
    local model = type(modelNameOrHash) == 'string' and joaat(modelNameOrHash) or modelNameOrHash
    if lib and lib.requestModel then
        local ok = pcall(function()
            lib.requestModel(modelNameOrHash, timeoutMs)
        end)
        if ok and HasModelLoaded(model) then
            return true
        end
    end
    if not HasModelLoaded(model) then
        RequestModel(model)
        local deadline = GetGameTimer() + timeoutMs
        while not HasModelLoaded(model) do
            if GetGameTimer() > deadline then
                return false
            end
            Wait(10)
        end
    end
    return true
end

if GetResourceState('es_extended') == 'started' then
    ESX = exports["es_extended"]:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
    framework = 'qb'
    QBCore = exports['qb-core']:GetCoreObject()
    ESX = {
        PlayerData = {},
        UI = { Menu = { CloseAll = function() end } },
        Game = {}
    }
    ESX.GetPlayerData = function()
        return QBCore.Functions.GetPlayerData()
    end
    ESX.TriggerServerCallback = function(name, cb, ...)
        QBCore.Functions.TriggerCallback(name, cb, ...)
    end
    ESX.SetPlayerData = function(key, value)
        ESX.PlayerData[key] = value
    end
    ESX.Game.GetClosestPlayer = function()
        local players = GetActivePlayers()
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local closest, closestDist = -1, -1
        for _, p in ipairs(players) do
            if p ~= PlayerId() then
                local tPed = GetPlayerPed(p)
                local dist = #(GetEntityCoords(tPed) - pCoords)
                if closestDist == -1 or dist < closestDist then
                    closest = p
                    closestDist = dist
                end
            end
        end
        return closest, closestDist
    end
end
isDead, disableKeys, inMenu, stretcher, stretcherMoving, isBusy = nil, nil, nil, nil, nil, nil
local playerLoaded, injury
plyRequests = {}

CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Wait(1000)
    end
    ESX.PlayerData.job = ESX.GetPlayerData().job
    addTargetModel({`xm_prop_x17_bag_med_01a`}, {
        options = {
            {
                event = 'wasabi_ambulance:pickupBag',
                icon = 'fas fa-hand-paper',
                label = Strings.pickup_bag_target,
            },
            {
                event = 'wasabi_ambulance:interactBag',
                icon = 'fas fa-briefcase',
                label = Strings.interact_bag_target,
            },

        },
        job = 'all',
        distance = 1.5
    })
    addPlayerTarget({
        options = {
            {
                event = 'wasabi_ambulance:diagnosePatient',
                icon = 'fas fa-stethoscope',
                label = Strings.diagnose_patient,
                job = 'ambulance',
            },
            {
                event = 'wasabi_ambulance:reviveTarget',
                icon = 'fas fa-medkit',
                label = Strings.revive_patient,
                job = 'ambulance',
            },
            {
                event = 'wasabi_ambulance:healTarget',
                icon = 'fas fa-bandage',
                label = Strings.heal_patient,
                job = 'ambulance',
            },
            {
                event = 'wasabi_ambulance:useSedative',
                icon = 'fas fa-syringe',
                label = Strings.sedate_patient,
                job = 'ambulance',
            }
        },
        distance = 2.5,
    })
end)

AddEventHandler("onClientMapStart", function()
	exports.spawnmanager:spawnPlayer()
	Wait(5000)
	exports.spawnmanager:setAutoSpawn(false)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    local ped = cache.ped
    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, 200)
	ESX.PlayerData = xPlayer
	playerLoaded = true
    if Config.AntiCombatLog.enabled then
        ESX.TriggerServerCallback('wasabi_ambulance:checkDeath', function(dead)
            if dead then
                Wait(2000) -- For slow clients we will wait 2 seconds~ for the ped to be spawned
                SetEntityHealth(PlayerPedId(), 0)
                if Config.AntiCombatLog.notification.enabled then
                    TriggerEvent('wasabi_ambulance:notify', Config.AntiCombatLog.notification.title, Config.AntiCombatLog.desc, 'error', 'skull-crossbones')
                end
            end
        end)
    end
    if ESX.PlayerData.job.name == 'ambulance' then
        TriggerServerEvent('wasabi_ambulance:requestSync')
    end
end)

if framework == 'qb' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        local pdata = ESX.GetPlayerData()
        ESX.PlayerData = pdata
        playerLoaded = true
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
            TriggerServerEvent('wasabi_ambulance:requestSync')
        end
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        ESX.PlayerData.job = job
        if job and job.name == 'ambulance' then
            TriggerServerEvent('wasabi_ambulance:requestSync')
        end
    end)
end

RegisterNetEvent('wasabi_ambulance:notify', function(title, desc, style, icon)
    if icon then
        lib.notify({
            title = title,
            description = desc,
            duration = 3500,
            icon = icon,
            type = style
        })
    else
        lib.notify({
            title = title,
            description = desc,
            duration = 3500,
            type = style
        })
    end
end)

RegisterNetEvent('esx:setJob', function(job)
	ESX.PlayerData.job = job
    if job.name == 'ambulance' then
        TriggerServerEvent('wasabi_ambulance:requestSync')
    end
end)

if framework == 'qb' then
    RegisterNetEvent('hospital:client:Revive', function()
        if not isDead then return end
        TriggerEvent('wasabi_ambulance:revive')
    end)
end

CreateThread(function()
	while true do
		local sleep = 1500
		if isDead or disableKeys then
            sleep = 0
			DisableAllControlActions(0)
            EnableControlAction(0, 1, true) -- Camera Pan(Mouse)
			EnableControlAction(0, 2, true) -- Camera Tilt(Mouse)
            EnableControlAction(0, 38, true) -- E Key
			EnableControlAction(0, 46, true) -- E Key
            EnableControlAction(0, 47, true) -- G Key
			EnableControlAction(0, 245, true) -- T Key
		end
        Wait(sleep)
	end
end)

AddEventHandler('esx:onPlayerSpawn', function()
    isDead = false
    local ped = cache.ped
    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, 200)
    SetPlayerHealthRechargeLimit(PlayerId(), 0.0)
    if firstSpawn then
        firstSpawn = false
        while not playerLoaded do
            Wait(1000)
        end
        loadAnimDict('get_up@directional@movement@from_knees@action', 15000)
        TaskPlayAnim(ped, 'get_up@directional@movement@from_knees@action', 'getup_r_0', 8.0, -8.0, -1, 0, 0, 0, 0, 0)
    else
        AnimpostfxStopAll()
        loadAnimDict('get_up@directional@movement@from_knees@action', 15000)
        TaskPlayAnim(ped, 'get_up@directional@movement@from_knees@action', 'getup_r_0', 8.0, -8.0, -1, 0, 0, 0, 0, 0)
    end
    TriggerServerEvent('wasabi_ambulance:setDeathStatus', false)
    RemoveAnimDict('get_up@directional@movement@from_knees@action')
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    injury = nil
    ESX.UI.Menu.CloseAll()
    if Config.MythicHospital then
        TriggerEvent('mythic_hospital:client:RemoveBleed')
        TriggerEvent('mythic_hospital:client:ResetLimbs')
    end
    for k,v in pairs(DeathReasons) do
        for i=1, #v do
            if data.deathCause == v[i] then
                injury = tostring(k) -- Not sure maybe will return string anyway
                break
            end
        end
    end
    TriggerServerEvent('wasabi_ambulance:injurySync', injury)
    OnPlayerDeath()
end)

if framework == 'qb' then
    RegisterNetEvent('hospital:client:SetDeathStatus', function(isPlayerDead)
        if isPlayerDead and not isDead then
            injury = nil
            TriggerServerEvent('wasabi_ambulance:injurySync', injury)
            OnPlayerDeath()
        end
    end)

    AddEventHandler('gameEventTriggered', function(name, args)
        if name ~= 'CEventNetworkEntityDamage' or isDead then return end
        local victim = args[1]
        if victim == PlayerPedId() and IsEntityDead(PlayerPedId()) then
            injury = nil
            TriggerServerEvent('wasabi_ambulance:injurySync', injury)
            OnPlayerDeath()
        end
    end)
end

-- I am monster thread
CreateThread(function()
    while ESX.PlayerData.job == nil do
        Wait(1000) -- Necessary for some of the loops that use job check in these threads within threads.
    end
    for k,v in pairs(Config.Locations) do
        if v.Blip.Enabled then
            CreateBlip(v.Blip.Coords, v.Blip.Sprite, v.Blip.Color, v.Blip.String, v.Blip.Scale, false)
        end
        if v.BossMenu.Enabled then
            addBoxZone(k.."_medboss", v.BossMenu.Target.coords, v.BossMenu.Target.width, v.BossMenu.Target.length, {
                name=k.."_medboss",
                heading=v.BossMenu.Target.heading,
                debugPoly=false,
                minZ=v.BossMenu.Target.minZ,
                maxZ=v.BossMenu.Target.maxZ
            }, {
                options = {
                    {
                        event = 'wasabi_ambulance:openBossMenu',
                        icon = 'fa-solid fa-suitcase-medical',
                        label = v.BossMenu.Target.label
                    }
                },
                job = 'ambulance',
                distance = 2.0
            })
        end
        if v.CheckIn.Enabled then
            CreateThread(function()
                local ped, pedSpawned
                local textUI
                while true do
                    local sleep = 1500
                    local playerPed = cache.ped
                    local coords = GetEntityCoords(playerPed)
                    local dist = #(coords - v.CheckIn.Coords)
                    if dist <= 30 and not pedSpawned then
                        loadModel(v.CheckIn.Ped, 15000)
                        ped = CreatePed(28, v.CheckIn.Ped, v.CheckIn.Coords.x, v.CheckIn.Coords.y, v.CheckIn.Coords.z, v.CheckIn.Heading, false, false)
                        FreezeEntityPosition(ped, true)
                        SetEntityInvincible(ped, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        if loadAnimDict('mini@strip_club@idles@bouncer@base', 15000) then
                            TaskPlayAnim(ped, 'mini@strip_club@idles@bouncer@base', 'base', 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                        else
                            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
                        end
                        pedSpawned = true
                    elseif dist < 5 and pedSpawned then
                        if not textUI then
                            lib.showTextUI(v.CheckIn.Label)
                            textUI = true
                        end
                        sleep = 0
                        if IsControlJustReleased(0, 38) then
                            textUI = nil
                            lib.hideTextUI()
                            ESX.TriggerServerCallback('wasabi_ambulance:tryRevive', function(cb)
                                if cb == 'success' then
                                    TriggerEvent('wasabi_ambulance:notify', Strings.checkin_hospital, Strings.checkin_hospital_desc, 'success')
                                elseif cb == 'max' then
                                    TriggerEvent('wasabi_ambulance:notify', Strings.max_ems, Strings.max_ems_desc, 'error')
                                else
                                    TriggerEvent('wasabi_ambulance:notify', Strings.not_enough_funds, Strings.not_enough_funds_desc, 'error')
                                end
                            end, v.CheckIn.Cost, v.CheckIn.MaxOnDuty, v.CheckIn.PayAccount)
                        end
                    elseif dist > 4 and textUI then
                        lib.hideTextUI()
                        textUI = nil
                    elseif dist >= 31 and pedSpawned then
                        local model = GetEntityModel(ped)
                        SetModelAsNoLongerNeeded(model)
                        DeletePed(ped)
                        SetPedAsNoLongerNeeded(ped)
                        RemoveAnimDict('mini@strip_club@idles@bouncer@base')
                        pedSpawned = nil
                    end
                    Wait(sleep)
                end
            end)
        end
        if v.Cloakroom.Enabled then
            CreateThread(function()
                local textUI
                while true do
                    local sleep = 1500
                    if ESX.PlayerData.job.name == 'ambulance' then
                        local ped = cache.ped
                        local coords = GetEntityCoords(ped)
                        local dist = #(coords - v.Cloakroom.Coords)
                        if dist <= v.Cloakroom.Range then
                            if not textUI then
                                lib.showTextUI(v.Cloakroom.Label)
                                textUI = true
                            end
                            sleep = 0
                            if IsControlJustReleased(0, 38) then
                                openOutfits(k)
                            end
                        else
                            if textUI then
                                lib.hideTextUI()
                                textUI = nil
                            end
                        end
                    end
                    Wait(sleep)
                end
            end)
        end
        if v.MedicalSupplies.Enabled then
            addBoxZone(k.."_medsup", v.MedicalSupplies.Coords, 1.0, 1.0, {
                name=k.."_medsup",
                heading=v.MedicalSupplies.Heading,
                debugPoly=false,
                minZ=v.MedicalSupplies.Coords.z-1.5,
                maxZ=v.MedicalSupplies.Coords.z+1.5
            }, {
                options = {
                    {
                        event = 'wasabi_ambulance:medicalSuppliesMenu',
                        icon = 'fa-solid fa-suitcase-medical',
                        label = Strings.request_supplies_target,
                        hospital = k
                    }
                },
                job = 'ambulance',
                distance = 1.5
            })
            CreateThread(function() 
                local ped, pedSpawned
                while true do
                    local sleep = 1500
                    local playerPed = cache.ped
                    local coords = GetEntityCoords(playerPed)
                    local dist = #(coords - v.MedicalSupplies.Coords)
                    if dist <= 30 and not pedSpawned then
                        loadModel(v.MedicalSupplies.Ped, 15000)
                        ped = CreatePed(28, v.MedicalSupplies.Ped, v.MedicalSupplies.Coords.x, v.MedicalSupplies.Coords.y, v.MedicalSupplies.Coords.z, v.MedicalSupplies.Heading, false, false)
                        FreezeEntityPosition(ped, true)
                        SetEntityInvincible(ped, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        if loadAnimDict('mini@strip_club@idles@bouncer@base', 15000) then
                            TaskPlayAnim(ped, 'mini@strip_club@idles@bouncer@base', 'base', 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                        else
                            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
                        end
                        pedSpawned = true
                    elseif dist >= 31 and pedSpawned then
                        local model = GetEntityModel(ped)
                        SetModelAsNoLongerNeeded(model)
                        DeletePed(ped)
                        SetPedAsNoLongerNeeded(ped)
                        RemoveAnimDict('mini@strip_club@idles@bouncer@base')
                        pedSpawned = false
                    end
                    Wait(sleep)
                end
            end)
        end
        if v.Vehicles.Enabled then
            CreateThread(function()
                local zone = v.Vehicles.Zone
                local textUI
                while true do
                    local sleep = 1500
                    if ESX.PlayerData.job.name == 'ambulance' then
                        local playerPed = cache.ped
                        local coords = GetEntityCoords(playerPed)
                        local dist = #(coords - zone.coords)
                        local dist2 = #(coords - v.Vehicles.Spawn.air.coords)
                        if dist < zone.range + 1 and not inMenu and not IsPedInAnyVehicle(playerPed, false) then
                            sleep = 0
                            if not textUI then
                                lib.showTextUI(zone.label)
                                textUI = true
                            end
                            if IsControlJustReleased(0, 38) then
                                textUI = nil
                                lib.hideTextUI()
                                openVehicleMenu(k)
                                sleep = 1500
                            end
                        elseif dist < zone.range + 1 and not inMenu and IsPedInAnyVehicle(playerPed, false) then
                            sleep = 0
                            if not textUI then
                                textUI = true
                                lib.showTextUI(zone.return_label)
                            end
                            if IsControlJustReleased(0, 38) then
                                textUI = nil
                                lib.hideTextUI()
                                if DoesEntityExist(cache.vehicle) then
                                    DoScreenFadeOut(800)
                                    while not IsScreenFadedOut() do Wait(100) end
                                    SetEntityAsMissionEntity(cache.vehicle)
                                    DeleteVehicle(cache.vehicle)
                                    DoScreenFadeIn(800)
                                end
                            end
                        elseif dist2 < 10 and IsPedInAnyVehicle(playerPed, false) then
                            sleep = 0
                            if not textUI then
                                textUI = true
                                lib.showTextUI(zone.return_label)
                            end
                            if IsControlJustReleased(0, 38) then
                                textUI = nil
                                lib.hideTextUI()
                                if DoesEntityExist(cache.vehicle) then
                                    DoScreenFadeOut(800)
                                    while not IsScreenFadedOut() do Wait(100) end
                                    SetEntityAsMissionEntity(cache.vehicle)
                                    DeleteVehicle(cache.vehicle)
                                    SetEntityCoordsNoOffset(playerPed, zone.coords.x, zone.coords.y, zone.coords.z, false, false, false, true)
                                    DoScreenFadeIn(800)
                                end
                            end
                        else
                            if textUI then
                                textUI = nil
                                lib.hideTextUI()
                            end
                        end
                    end
                    Wait(sleep)
                end
            end)
        end
    end
end)

RegisterNetEvent('wasabi_ambulance:syncRequests')
AddEventHandler('wasabi_ambulance:syncRequests', function(_plyRequests, quiet)
    if ESX.PlayerData.job.name == 'ambulance' then
        plyRequests = _plyRequests
        if not quiet then
            TriggerEvent('wasabi_ambulance:notify', Strings.assistance_title, Strings.assistance_desc, 'error', 'suitcase-medical')
        end
    end
end)

-- esx_ambulancejob compatibility
RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()
    TriggerEvent("wasabi_ambulance:revive")
end)

RegisterNetEvent('wasabi_ambulance:revivePlayer', function()
    if LocalPlayer.state.dead then
        local ped = cache.ped
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local injury = LocalPlayer.state.injury
        DoScreenFadeOut(800)
        while not IsScreenFadedOut() do
            Wait(50)
        end
        TriggerServerEvent('wasabi_ambulance:setDeathStatus', false)
        isDead = false
        NetworkResurrectLocalPlayer(coords, heading, true, false)
        ClearPedBloodDamage(ped)
        if Config.MythicHospital then
            TriggerEvent('mythic_hospital:client:RemoveBleed')
            TriggerEvent('mythic_hospital:client:ResetLimbs')
        end
        FreezeEntityPosition(ped, false)
        DoScreenFadeIn(800)
        AnimpostfxStopAll()
        TriggerServerEvent('esx:onPlayerSpawn')
        TriggerEvent('esx:onPlayerSpawn')
        ClearPedTasks(ped)
        if not injury then
            SetEntityHealth(ped, 200)
        else
            ApplyDamageToPed(ped, Config.ReviveHealth[injury])
        end
    end 
end)

RegisterNetEvent('wasabi_ambulance:revive',function()
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    TriggerServerEvent('wasabi_ambulance:setDeathStatus', false)
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do
        Wait(50)
    end
    NetworkResurrectLocalPlayer(coords, heading, true, false)
    ClearPedBloodDamage(ped)
    isDead = false
    if Config.MythicHospital then
        TriggerEvent('mythic_hospital:client:RemoveBleed')
        TriggerEvent('mythic_hospital:client:ResetLimbs')
    end
    DoScreenFadeIn(800)
    AnimpostfxStopAll()
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
end)

RegisterNetEvent('wasabi_ambulance:heal', function(full, quiet)
    local ped = cache.ped
    local maxHealth = 200
    if not full then
        local health = GetEntityHealth(ped)
        local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
        SetEntityHealth(ped, newHealth)
    else
        SetEntityHealth(ped, maxHealth)
    end
    if not quiet then
        TriggerEvent('wasabi_ambulance:notify', Strings.player_successful_heal, Strings.player_healed_desc, 'success')
    end
end)

RegisterNetEvent('wasabi_ambulance:sedate', function()
    local ped = cache.ped
    TriggerEvent('wasabi_ambulance:notify', Strings.assistance_title, Strings.assistance_desc, 'success', 'syringe')
    ClearPedTasks(ped)
    disableKeys = true
    if loadAnimDict('mini@cpr@char_b@cpr_def', 15000) then
        TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 8.0, 8.0, -1, 33, 0, 0, 0, 0)
    end
    FreezeEntityPosition(ped, true)
    Wait(Config.EMSItems.sedate.duration)
    FreezeEntityPosition(ped, false)
    disableKeys = false
    ClearPedTasks(ped)
    if HasAnimDictLoaded('mini@cpr@char_b@cpr_def') then
        RemoveAnimDict('mini@cpr@char_b@cpr_def')
    end
end)

RegisterNetEvent('wasabi_ambulance:intoVehicle', function()
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    if IsPedInAnyVehicle(ped) then
        coords = GetOffsetFromEntityInWorldCoords(ped, -2.0, 1.0, 0.0)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    else
        if IsAnyVehicleNearPoint(coords, 6.0) then
            local vehicle = GetClosestVehicle(coords, 6.0, 0, 71)
            if DoesEntityExist(vehicle) then
                local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
                for i=maxSeats - 1, 0, -1 do
                    if IsVehicleSeatFree(vehicle, i) then
                        freeSeat = i
                        break
                    end
                end
                if freeSeat then
                    TaskWarpPedIntoVehicle(ped, vehicle, freeSeat)
                end
            end
        end
    end
end)

RegisterNetEvent('wasabi_ambulance:syncObj', function(netObj)
    local obj = NetToObj(netObj)
    deleteObj(obj)
end)

RegisterNetEvent('wasabi_ambulance:useSedative', function()
    useSedative()
end)

RegisterNetEvent('wasabi_ambulance:useMedbag', function()
    useMedbag()
end)

RegisterNetEvent('wasabi_ambulance:treatPatient', function(injury)
    treatPatient(injury)
end)

AddEventHandler('wasabi_ambulance:buyItem', function(data)
    TriggerServerEvent('wasabi_ambulance:restock', data)
end)

RegisterNetEvent('wasabi_ambulance:placeOnStretcher', function()
    placeOnStretcher()
end)

AddEventHandler('wasabi_ambulance:openBossMenu', function()
	TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu)
		menu.close()
	end, {wash = false})
end)

AddEventHandler('wasabi_ambulance:spawnVehicle', function(data)
    inMenu = false
    local model = data.model
    local category = Config.Locations[data.hospital].Vehicles.Options[data.model].category
    local spawnLoc = Config.Locations[data.hospital].Vehicles.Spawn[category]
    if not IsModelInCdimage(GetHashKey(model)) then
        print('Vehicle model not found: '..model)
    else
        DoScreenFadeOut(800)
        while not IsScreenFadedOut() do
            Wait(100)
        end
        loadModel(model, 15000)
        local vehicle = CreateVehicle(GetHashKey(model), spawnLoc.coords.x, spawnLoc.coords.y, spawnLoc.coords.z, spawnLoc.heading, 1, 0)
        TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
        if Config.customCarlock then
            -- Leave like this if using wasabi_carlock OR change with your own!
            local plate = GetVehicleNumberPlateText(vehicle)
            TriggerServerEvent('wasabi_carlock:addKey', plate)
        end
        SetModelAsNoLongerNeeded(model)
        DoScreenFadeIn(800)
    end
end)

AddEventHandler('wasabi_ambulance:changeClothes', function(data) -- Change with your own code here if you want?
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        if data == 'civ_wear' then
            if Config.skinScript == 'appearance' then
                    skin.sex = nil
                    exports['fivem-appearance']:setPlayerAppearance(skin)
            else
               TriggerEvent('skinchanger:loadClothes', skin)
            end
        elseif skin.sex == 0 then
			TriggerEvent('skinchanger:loadClothes', skin, data.male)
		elseif skin.sex == 1 then
			TriggerEvent('skinchanger:loadClothes', skin, data.female)
		end
    end)
end)

AddEventHandler('wasabi_ambulance:billPatient', function()
    if ESX.PlayerData.job.name == 'ambulance' then
        local player, dist = ESX.Game.GetClosestPlayer()
        if player == -1 or dist > 4.0 then
            TriggerEvent('wasabi_ambulance:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
        else
            local targetId = GetPlayerServerId(player)
            local input = lib.inputDialog('Bill Patient', {'Amount'})
            if not input then return end
            local amount = math.floor(tonumber(input[1]))
            if amount < 1 then
                TriggerEvent('wasabi_ambulance:notify', Strings.invalid_entry, Strings.invalid_entry_desc, 'error')
            elseif Config.billingSystem == 'okok' then
                local data =  {
                    target = targetId,
                    invoice_value = amount,
                    invoice_item = Strings.medical_services,
                    society = 'society_ambulance',
                    society_name = 'Hospital',
                    invoice_notes = ''
                }
                TriggerServerEvent('okokBilling:CreateInvoice', data)
            else
                TriggerServerEvent('esx_billing:sendBill', targetId, 'society_ambulance', 'EMS', amount)
            end
        end
    end
end)

AddEventHandler('wasabi_ambulance:medicalSuppliesMenu', function(data)
    medicalSuppliesMenu(data.hospital)
end)

AddEventHandler('wasabi_ambulance:gItem', function(data)
    gItem(data)
end)

AddEventHandler('wasabi_ambulance:interactBag', function()
    interactBag()
end)

AddEventHandler('wasabi_ambulance:pickupBag', function()
    pickupBag()
end)

AddEventHandler('wasabi_ambulance:placeInVehicle', function()
    placeInVehicle()
end)

AddEventHandler('wasabi_ambulance:dispatchMenu', function()
    openDispatchMenu()
end)

AddEventHandler('wasabi_ambulance:setRoute', function(data)
    setRoute(data)
end)

AddEventHandler('wasabi_ambulance:diagnosePatient', function()
    diagnosePatient()
end)

AddEventHandler('wasabi_ambulance:loadStretcher', function()
    loadStretcher()
end)

RegisterNetEvent('wasabi_ambulance:useStretcher')
AddEventHandler('wasabi_ambulance:useStretcher', function()
    useStretcher()
end)

AddEventHandler('wasabi_ambulance:pickupStretcher', function()
    pickupStretcher()
end)

AddEventHandler('wasabi_ambulance:moveStretcher', function()
    moveStretcher()
end)

AddEventHandler('wasabi_ambulance:addTarget', function(d)
    addBoxZone(d.identifier, d.coords, d.width, d.length, {
        name=d.identifier,
        heading=d.heading,
        debugPoly=false,
        minZ=d.minZ,
        maxZ=d.maxZ
    }, {
        options = d.options,
        job = d.job,
        distance = d.distance
    })
end)

AddEventHandler('wasabi_ambulance:removeTarget', function(identifier)
    removeZone(identifier)
end)

RegisterNetEvent('wasabi_ambulance:reviveTarget')
AddEventHandler('wasabi_ambulance:reviveTarget', function()
    reviveTarget()
end)

RegisterNetEvent('wasabi_ambulance:healTarget')
AddEventHandler('wasabi_ambulance:healTarget', function()
    healTarget()
end)

RegisterCommand('emsJobMenu', function()
    openJobMenu()
end)

AddEventHandler('wasabi_ambulance:emsJobMenu', function()
    openJobMenu()
end)

TriggerEvent('chat:removeSuggestion', '/emsJobMenu')

RegisterKeyMapping('emsJobMenu', Strings.key_map_text, 'keyboard', Config.jobMenu)