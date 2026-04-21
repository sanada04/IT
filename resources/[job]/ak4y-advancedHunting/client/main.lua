if AK4Y.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif AK4Y.Framework == "oldqb" then 
    QBCore = nil
end

local currentXP = 0
local currentLevel = 1
local bicakkullan = GetGameTimer()

local function applyLevelFromDbXp(totalXp)
    totalXp = tonumber(totalXp) or 0
    local needed = tonumber(AK4Y.NeededEXP) or 1000
    if needed < 1 then needed = 1000 end
    local maxLv = tonumber(AK4Y.MaxLevel) or 99
    currentLevel = math.min(maxLv, math.max(1, math.floor(totalXp / needed) + 1))
    currentXP = totalXp % needed
end

Citizen.CreateThread(function()
    if AK4Y.Framework == "oldqb" then 
        while QBCore == nil do
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
	elseif AK4Y.Framework == "qb" then
		while QBCore == nil do
            Citizen.Wait(200)
        end
    end	
    Wait(5000)
    for k, v in pairs(AK4Y.NPCAreas) do 
        RequestModel(v.pedHash)
        while not HasModelLoaded(v.pedHash) do
            Wait(1)
        end
        local ped = CreatePed(0, v.pedHash, v.pedCoord.x, v.pedCoord.y, v.pedCoord.z, v.h + 0.0, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        if v.blipSettings.blip then 
            local blip = AddBlipForCoord(v.pedCoord)
            SetBlipSprite(blip, v.blipSettings.blipIcon)
            SetBlipDisplay(blip, 2)
            SetBlipScale(blip, 0.75)
            SetBlipColour(blip, v.blipSettings.blipColour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blipSettings.blipName)
            EndTextCommandSetBlipName(blip)
        end
    end
    -- Wait(5000)

    girdim = true
    QBCore.Functions.TriggerCallback('ak4y-advancedHunting:getLevelData', function(result)
        applyLevelFromDbXp(result and result.currentXP or 0)
        tavukspawn()
    end)
    SendNUIMessage({
        type = 'setJsTranslate',
        jsTranslate = AK4Y.HTMLTranslate
    })
end)

function getLevelFromServer()
    local returned = false
    local tolerance = 0
    QBCore.Functions.TriggerCallback('ak4y-advancedHunting:getLevelData', function(result)
        applyLevelFromDbXp(result and result.currentXP or 0)
        returned = true
    end)
    while not returned do
        Wait(100)
        tolerance = tolerance + 1
        if tolerance > 50 then break end
    end
    return currentLevel
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    girdim = true
    QBCore.Functions.TriggerCallback('ak4y-advancedHunting:getLevelData', function(result)
        applyLevelFromDbXp(result and result.currentXP or 0)
        tavukspawn()
    end)
    SendNUIMessage({
        type = 'setJsTranslate',
        jsTranslate = AK4Y.HTMLTranslate
    })
end)

local performansCd = 1000
Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        for k, v in pairs(AK4Y.NPCAreas) do 
            if #(v.pedCoord - pos) < 3 then 
                performansCd = 1
                DrawText3D(v.pedCoord.x, v.pedCoord.y, v.pedCoord.z+2, v.drawText)
                if #(v.pedCoord - pos) < 2 then 
                    if IsControlJustReleased(0, 38) then 
                        openMenu()
                    end
                end
            end
        end
        Citizen.Wait(performansCd)
    end
end)

menuOpenSpamProtection = 0
function openMenu()
    if menuOpenSpamProtection < GetGameTimer() then 
		menuOpenSpamProtection = menuOpenSpamProtection + 1000
        PlayerData = QBCore.Functions.GetPlayerData()
		QBCore.Functions.TriggerCallback("ak4y-advancedHunting:getPlayerDetails", function(result)
			SetNuiFocus(true,true)
            local steamID = 'null'
            if result.avatarUrl and result.avatarUrl ~= '' then
                steamID = result.avatarUrl
            end
            local taskResetTimes = "-"
            if result.expiredHour ~= nil then 
                taskResetTimes = disp_time(result.expiredHour - result.osTime)
            end
            local firstname = PlayerData.charinfo.firstname
            local lastname = PlayerData.charinfo.lastname
			SendNUIMessage({
				type = 'openUi',
                wikiPage = AK4Y.WikiPage,   
                marketPage = AK4Y.MarketPage,    
                salesPage = AK4Y.SellItems,   
                tasksPage = AK4Y.Tasks,
                levelPackages = AK4Y.LevelPackages,
                jsTranslate = AK4Y.HTMLTranslate,
                neededEXP = AK4Y.NeededEXP,
                maxLevel = AK4Y.MaxLevel,
                currentXP = result.currentXP,
                playerTasks = result.tasks,
                taskResetTime = result.taskResetTime,  
                steamid = steamID,
                avatarUrl = result.avatarUrl or '',
                firstname = firstname,
                lastname = lastname,
                taskResetTimes = taskResetTimes,
			})	

            
		end)
	end
end

function disp_time(time)
    local days = math.floor(time/86400)
    local remaining = time % 86400
    local hours = math.floor(remaining/3600)
    remaining = remaining % 3600
    local minutes = math.floor(remaining/60)
    remaining = remaining % 60
    local seconds = remaining
    if (hours < 10) then
        hours = "0" .. tostring(hours)
    end
    if (minutes < 10) then
        minutes = "0" .. tostring(minutes)
    end
    if (seconds < 10) then
        seconds = "0" .. tostring(seconds)
    end
    if days > 0 then 
        answer = tostring(days)..'d '..hours..'h '..minutes..'m'
    else
        if tonumber(hours) > 0 then 
            answer = hours..'h '..minutes..'m'
        else
            answer = minutes..'m'
        end
    end
    return answer
end

local taskSpam = 0
RegisterNUICallback('taskDone', function(data, cb)
	if taskSpam < GetGameTimer() then 
		taskSpam = GetGameTimer() + 1000
		QBCore.Functions.TriggerCallback("ak4y-advancedHunting:taskDone", function(result)
			if result then 
				cb(true)
			else
				cb(false)
			end
		end, data)
	else
		cb(false)
	end
end)

local buySpam = 0
RegisterNUICallback('buyItem', function(data, cb)
	if taskSpam < GetGameTimer() then 
		taskSpam = GetGameTimer() + 100
		QBCore.Functions.TriggerCallback("ak4y-advancedHunting:buyItem", function(result)
			if result then 
				cb(true)
			else
				cb(false)
			end
		end, data)
	else
		cb(false)
	end
end)

local sellItemSpamProtectx = 0
RegisterNUICallback('sellItem', function(data, cb)
    if sellItemSpamProtectx < GetGameTimer() then 
		sellItemSpamProtectx = GetGameTimer() + 150
        QBCore.Functions.TriggerCallback("ak4y-advancedHunting:sellItem", function(result)
            cb(result)
        end, data)

    end
end)

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    local coord = json.decode(data.waypointCoord)
    SetNewWaypoint(coord.x, coord.y)
end)

local elleyakala = false
DecorRegister("SpawnedAnimal", 2)


function tavukspawn()
    -- local havyan = CreatePed(28, "a_c_hen", AK4Y.CatchChicken.location, true, false, true)
    hayvanspawn("a_c_hen", vector3(1447.7864, 1066.3145, 114.33869), false)
    -- yakalanacakhayvan = havyan
end

Citizen.CreateThread(function()
    for k,v in pairs(AK4Y.HuntLocations) do
        if v.blipactive == true then
            blipamk = AddBlipForRadius(v.location.x,v.location.y, v.location.z, v.radius)
            SetBlipHighDetail(blipamk, true)
            SetBlipColour(blipamk, v.blipColour)
            SetBlipAlpha (blipamk, v.blipAlpha)
        end
    end
    for k,v in pairs(AK4Y.HuntLocations) do
        if v.blipactive == true then
            blipamk = AddBlipForCoord(v.location)
            SetBlipSprite(blipamk, v.BlipSprite)
            SetBlipDisplay(blipamk, 2)
            SetBlipScale(blipamk, v.BlipScale)
            SetBlipColour(blipamk, v.blipColour)
            SetBlipAsShortRange(blipamk, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.BlipName)
            EndTextCommandSetBlipName(blipamk)
        end
    end
        blipamk = AddBlipForCoord(AK4Y.CatchChicken.location)
        SetBlipSprite(blipamk, AK4Y.CatchChicken.BlipSprite)
        SetBlipDisplay(blipamk, 2)
        SetBlipScale(blipamk, AK4Y.CatchChicken.BlipScale)
        SetBlipColour(blipamk, AK4Y.CatchChicken.blipColour)
        SetBlipAsShortRange(blipamk, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(AK4Y.CatchChicken.BlipName)
        EndTextCommandSetBlipName(blipamk)
end)

local beklemecd = false

-- ox_inventory の client event からでも既存処理へ接続できるようにする
RegisterNetEvent('ak4y-advancedHunting:useDeerBait')
AddEventHandler('ak4y-advancedHunting:useDeerBait', function()
    TriggerEvent('ak4y-advancedHunting:clientBait', 'a_c_deer', 'bad', 'deer_bait')
end)

RegisterNetEvent('ak4y-advancedHunting:useDeerBaitHigh')
AddEventHandler('ak4y-advancedHunting:useDeerBaitHigh', function()
    TriggerEvent('ak4y-advancedHunting:clientBait', 'a_c_deer', 'good', 'deer_bait2')
end)

RegisterNetEvent('ak4y-advancedHunting:usePigBait')
AddEventHandler('ak4y-advancedHunting:usePigBait', function()
    TriggerEvent('ak4y-advancedHunting:clientBait', 'a_c_pig', 'bad', 'pig_bait')
end)

RegisterNetEvent('ak4y-advancedHunting:usePigBaitHigh')
AddEventHandler('ak4y-advancedHunting:usePigBaitHigh', function()
    TriggerEvent('ak4y-advancedHunting:clientBait', 'a_c_pig', 'good', 'pig_bait2')
end)

RegisterNetEvent('ak4y-advancedHunting:useChickenBait')
AddEventHandler('ak4y-advancedHunting:useChickenBait', function()
    TriggerEvent('ak4y-advancedHunting:clientBait', 'a_c_hen', 'bad', 'chicken_bait')
end)

RegisterNetEvent('ak4y-advancedHunting:useChickenBaitHigh')
AddEventHandler('ak4y-advancedHunting:useChickenBaitHigh', function()
    TriggerEvent('ak4y-advancedHunting:clientBait', 'a_c_hen', 'good', 'chicken_bait2')
end)

RegisterNetEvent('ak4y-advancedHunting:useHuntingKnife')
AddEventHandler('ak4y-advancedHunting:useHuntingKnife', function()
    TriggerEvent('ak4y-advancedHunting:clientKnife')
end)

RegisterNetEvent('ak4y-advancedHunting:clientBait')
AddEventHandler('ak4y-advancedHunting:clientBait', function(hayvan, kalite, itemname)
    if beklemecd ~= false then
        NOTIFY(AK4Y.Languages["wait"])
        return
    end

    local neededLevel = 1
    local inCorrectZone = false
    local pedCoords = GetEntityCoords(PlayerPedId())

    if hayvan == 'a_c_hen' then
        neededLevel = AK4Y.CatchChicken.NeededLevel or 1
        local loc = AK4Y.CatchChicken.location
        local r = AK4Y.CatchChicken.radius or 100.0
        if #(pedCoords - loc) < r then
            inCorrectZone = true
        end
    else
        local zone = AK4Y.HuntLocations[hayvan]
        if not zone then return end
        neededLevel = zone.NeededLevel or 1
        if #(pedCoords - zone.location) < (zone.radius or 100.0) then
            inCorrectZone = true
        end
    end

    if currentLevel < neededLevel then
        NOTIFY(AK4Y.Languages["need_level"])
        return
    end
    if not inCorrectZone then
        NOTIFY(AK4Y.Languages["not_in_zone"])
        return
    end
    if hayvan ~= 'a_c_hen' then
        if #(pedCoords - AK4Y.HuntLocations[hayvan].location) >= (AK4Y.HuntLocations[hayvan].radius or 100.0) then
            NOTIFY(AK4Y.Languages["not_in_zone_bait"])
            return
        end
    end

    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
    FreezeEntityPosition(PlayerPedId(), true)
    local sure = AK4Y.ProgressTime['place_bait'] or 10000
    Citizen.Wait(sure)
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasksImmediately(PlayerPedId())
    beklemecd = true
    NOTIFY(AK4Y.Languages['bait_placed'])
    local placeCoord = GetEntityCoords(PlayerPedId())
    PlaceBait(hayvan)
    TriggerServerEvent('hunting:RemoveItem', itemname)
    CreateThread(function()
        bait(hayvan, kalite, placeCoord)
        Citizen.Wait(5000)
        beklemecd = false
    end)
end)

local autoSpawnCd = {}

local function hasNearbyAliveAnimal(animalName, aroundCoord, radius)
    local modelHash = GetHashKey(animalName)
    local peds = GetGamePool('CPed')
    for i = 1, #peds do
        local ped = peds[i]
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) and GetEntityModel(ped) == modelHash then
            if #(GetEntityCoords(ped) - aroundCoord) < radius then
                return true
            end
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        local cfg = AK4Y.AutoSpawnNoBait
        if not cfg or not cfg.enabled then
            Citizen.Wait(3000)
        else
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local now = GetGameTimer()
            for animalName, zone in pairs(AK4Y.HuntLocations) do
                local neededLevel = zone.NeededLevel or 1
                local zoneRadius = zone.radius or 100.0
                local nextAllowed = autoSpawnCd[animalName] or 0
                if currentLevel >= neededLevel and #(pedCoords - zone.location) < zoneRadius and now >= nextAllowed then
                    local checkRadius = math.min(zoneRadius + 40.0, 160.0)
                    if not hasNearbyAliveAnimal(animalName, zone.location, checkRadius) then
                        hayvanspawn(animalName, zone.location, true)
                    end
                    autoSpawnCd[animalName] = now + (cfg.cooldownMs or 60000)
                end
            end
            Citizen.Wait(5000)
        end
    end
end)

function bait(hayvan, kalite, coord)
    local chance = (kalite == 'good') and 30 or 10
    Citizen.Wait(5000)
    local bekleme = 1000
    for _ = 1, 90 do
        if math.random(1, 100) <= chance then
            hayvanspawn(hayvan, coord, true)
            return
        end
        Citizen.Wait(bekleme)
    end
end

local hayvanlar = {
    "a_c_boar",
    "a_c_cat_01",
    "a_c_chickenhawk",
    "a_c_chimp",
    "a_c_chop",
    "a_c_cow",
    "a_c_coyote",
    "a_c_crow",
    "a_c_deer",
    "a_c_dolphin",
    "a_c_fish",
    "a_c_hen",
    "a_c_humpback",
    "a_c_husky",
    "a_c_killerwhale",
    "a_c_mtlion",
    "a_c_pig",
    "a_c_pigeon",
    "a_c_poodle",
    "a_c_pug",
    "a_c_rabbit_01",
    "a_c_rat",
    "a_c_retriever",
    "a_c_rhesus",
    "a_c_rottweiler",
    "a_c_seagull",
    "a_c_sharkhammer",
    "a_c_sharktiger",
    "a_c_shepherd",
    "a_c_stingray",
    "a_c_westy"
}

RegisterNetEvent('ak4y-advancedHunting:clientKnife')
AddEventHandler('ak4y-advancedHunting:clientKnife', function()
    if bicakkullan < GetGameTimer() then
        bicakkullan = GetGameTimer() + 2000
        if targetedEntity ~= nil then
            for k,v in pairs(AK4Y.HuntLocations) do
                model = GetEntityModel(targetedEntity)
                hayvan = GetHashKey(k)
                if hayvan == model then
                    dogruhayvan = true
                    suankihayvan = hayvan
                    for k,v in pairs(AK4Y.AnimalItems) do
                        if v.hash == hayvan then
                            items = {
                                ["BasicItem"] = v.BasicItem,
                                ["RareItem"] = v.RareItem,
                            }
                            hayvanaq = k
                            hayvan = GetHashKey(k)
                        end
                    end
                end
            end
            if dogruhayvan then
                if AK4Y.HuntLocations[hayvanaq].NeededLevel <= currentLevel then
                    hayvansil = targetedEntity
                    for k,v in pairs(AK4Y.HuntLocations) do
                        if GetHashKey(k) == suankihayvan then
                            allowedweapons = v["Allowed Weapons"]
                        end
                    end
                    for k,v in pairs(allowedweapons) do
                        weapon = GetHashKey(v)
                        if HasPedBeenDamagedByWeapon(targetedEntity, weapon, 0) then
                            dogrusilah = true
                        end
                    end
                    if dogrusilah then
                        dogrusilah = false
                        if #(targetedEntityCoord - GetEntityCoords(PlayerPedId())) > 3 then
                            QBCore.Functions.Notify(AK4Y.Languages["far_from_animal"], "error")
                            return
                        end
                        local found, player = GetClosestPlayerMenu()
                        if found then
                            QBCore.Functions.Notify(AK4Y.Languages["player_in_close"], "error")
                            return
                        end
                        TaskTurnPedToFaceEntity(PlayerPedId(), targetedEntity, -1)
                        Citizen.Wait(1500)
                        ClearPedTasksImmediately(PlayerPedId())
                        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                        FreezeEntityPosition(PlayerPedId(), true)
                        sureamk = AK4Y.ProgressTime[hayvanaq]
                        if hayvanaq == "a_c_deer" then
                            progresshayvan = "deer"
                        elseif hayvanaq == "a_c_pig" then
                            progresshayvan = "pig"
                        end
                        SendNUIMessage({
                            type = 'openProgress',
                            animal = progresshayvan, 
                            time = sureamk,
                        })
                        dogruhayvan = false
                        Citizen.Wait(sureamk)
                        FreezeEntityPosition(PlayerPedId(), false)
                        ClearPedTasksImmediately(PlayerPedId())
                        NOTIFY(AK4Y.Languages["cut_animal"])
                        CutAnimal(GetHashKey(hayvanaq))
                        DeletePed(hayvansil)
                        TriggerServerEvent('hunting:updatexp')
                        TriggerServerEvent('hunting:itemver', items, hayvan)
                        QBCore.Functions.TriggerCallback('ak4y-advancedHunting:getLevelData', function(result)
                            applyLevelFromDbXp(result and result.currentXP or 0)
                        end)
                    else
                        NOTIFY(AK4Y.Languages["shredded_meat"])
                    end 
                else
                    NOTIFY(AK4Y.Languages["need_level"])
                end
            else
                NOTIFY(AK4Y.Languages["cant_cut_this_animal"])
            end
        else
            NOTIFY(AK4Y.Languages["not_look_animal"])
        end
    else
        NOTIFY(AK4Y.Languages["spam"])
    end
end)

RegisterNetEvent('ak4y-advancedHunting:rareItem')
AddEventHandler('ak4y-advancedHunting:rareItem', function(hayvan)
    EarnRareItem(hayvan)
end)

local beklemeamk = 1500
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(beklemeamk)
        if GetDistanceBetweenCoords(AK4Y.CatchChicken.location, GetEntityCoords(PlayerPedId()), true) < 35 then
            if elleyakala then
                beklemeamk = 1
                if GetDistanceBetweenCoords(GetEntityCoords(yakalanacakhayvan), GetEntityCoords(PlayerPedId()), true) < 2.5 then
                    QBCore.Functions.DrawText3D(GetEntityCoords(yakalanacakhayvan).x, GetEntityCoords(yakalanacakhayvan).y, GetEntityCoords(yakalanacakhayvan).z, AK4Y.Languages["cath_chicken"])
                    if IsControlJustPressed(0, 38) then
                        RequestAnimDict('move_jump')
                        while not HasAnimDictLoaded('move_jump') do
                            Citizen.Wait(10)
                        end
                        TaskPlayAnim(GetPlayerPed(-1), 'move_jump', 'dive_start_run', 8.0, -8.0, -1, 0, 0.0, 0, 0, 0)
                        Citizen.Wait(700)
                        if GetDistanceBetweenCoords(GetEntityCoords(yakalanacakhayvan), GetEntityCoords(PlayerPedId()), true) < 1.5 then
                            elleyakala = false
                            FreezeEntityPosition(yakalanacakhayvan, true)
                            SetEntityCoords(yakalanacakhayvan, GetEntityCoords(PlayerPedId()).x,GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z - 1)
                            TaskTurnPedToFaceEntity(PlayerPedId(), yakalanacakhayvan, -1)
                            Citizen.Wait(1500)
                            TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                            FreezeEntityPosition(PlayerPedId(), true)
                            sureamk = AK4Y.ProgressTime["a_c_hen"]
                            SendNUIMessage({
                                type = 'openProgress',
                                animal = "chicken", 
                                time = sureamk,
                            })	
                            Citizen.Wait(sureamk)
                            FreezeEntityPosition(PlayerPedId(), false)
                            items = {
                                ["BasicItem"] = AK4Y.AnimalItems["a_c_hen"].BasicItem,
                                ["RareItem"] = AK4Y.AnimalItems["a_c_hen"].RareItem,
                            }
                            ClearPedTasksImmediately(PlayerPedId())
                            NOTIFY(AK4Y.Languages["cut_animal"])
                            DeletePed(yakalanacakhayvan)
                            CutAnimal(1794449327)
                            TriggerServerEvent('hunting:updatexp')
                            TriggerServerEvent('hunting:itemver', items, GetHashKey("a_c_hen"))
                            QBCore.Functions.TriggerCallback('ak4y-advancedHunting:getLevelData', function(result)
                                applyLevelFromDbXp(result and result.currentXP or 0)
                            end)
                            yakalanacakhayvan = nil
                            Citizen.Wait(500)
                            tavukspawn()
                        else
                            NOTIFY(AK4Y.Languages["you_couldnt_catch"], "error")
                        end
                    end
                end
            end
        else
            beklemeamk = 1
        end
    end
end)

function hayvanspawn(hayvan, coord, localamk)
    local modelHash = type(hayvan) == 'string' and joaat(hayvan) or hayvan
    RequestModel(modelHash)
    local timeout = GetGameTimer() + 20000
    while not HasModelLoaded(modelHash) do
        if GetGameTimer() > timeout then
            NOTIFY('動物モデルの読み込みに失敗しました（リスタートや距離を確認）')
            return
        end
        Citizen.Wait(0)
    end
    local spawnLoc
    if localamk == false then
        spawnLoc = AK4Y.CatchChicken.location
    else
        local radius = 100.0
        if hayvan == 'a_c_hen' then
            radius = AK4Y.CatchChicken.radius or 100.0
        else
            local zone = AK4Y.HuntLocations[hayvan]
            if not zone then
                SetModelAsNoLongerNeeded(modelHash)
                return
            end
            radius = zone.radius or 100.0
        end
        spawnLoc = getSpawnLoc(coord, radius)
    end
    local x, y, z = spawnLoc.x, spawnLoc.y, spawnLoc.z
    RequestCollisionAtCoord(x, y, z)
    for _ = 1, 20 do
        if HasCollisionLoadedAroundEntity(PlayerPedId()) then break end
        Citizen.Wait(50)
    end
    local spawnedAnimal = CreatePed(28, modelHash, x, y, z, 0.0, true, false)
    if not spawnedAnimal or spawnedAnimal == 0 or not DoesEntityExist(spawnedAnimal) then
        SetModelAsNoLongerNeeded(modelHash)
        NOTIFY('動物の生成に失敗しました')
        return
    end
    SetEntityAsMissionEntity(spawnedAnimal, true, true)
    SetEntityHeading(spawnedAnimal, math.random(0, 360) + 0.0)
    SetBlockingOfNonTemporaryEvents(spawnedAnimal, true)
    if localamk == false then
        yakalanacakhayvan = spawnedAnimal
        elleyakala = true
    end
    DecorSetBool(spawnedAnimal, 'SpawnedAnimal', true)
    SetModelAsNoLongerNeeded(modelHash)
    TaskGoStraightToCoord(spawnedAnimal, coord.x, coord.y, coord.z, 1.0, -1, 0.0, 0.0)
    local spawnAt = GetGameTimer()
    Citizen.CreateThread(function()
        local finished = false
        while DoesEntityExist(spawnedAnimal) and not IsPedDeadOrDying(spawnedAnimal) and not finished do
            local spawnedAnimalCoords = GetEntityCoords(spawnedAnimal)
            if #(coord - spawnedAnimalCoords) < 0.5 then
                ClearPedTasks(spawnedAnimal)
                Citizen.Wait(1500)
                TaskStartScenarioInPlace(spawnedAnimal, 'WORLD_DEER_GRAZING', 0, true)
                Citizen.SetTimeout(7500, function()
                    finished = true
                end)
            end
            -- スポーン直後はプレイヤー近接で即逃走しない（従来は15mで一瞬で消えたように見える）
            if (GetGameTimer() - spawnAt) > 12000 and #(spawnedAnimalCoords - GetEntityCoords(PlayerPedId())) < 6.0 then
                ClearPedTasks(spawnedAnimal)
                TaskSmartFleePed(spawnedAnimal, PlayerPedId(), 600.0, -1)
                finished = true
            end
            Citizen.Wait(1000)
        end
        if DoesEntityExist(spawnedAnimal) and not IsPedDeadOrDying(spawnedAnimal) then
            TaskSmartFleePed(spawnedAnimal, PlayerPedId(), 600.0, -1)
        end
    end)
end

function getSpawnLoc(coord, radius)
    if radius >= 50 then
        radius = 50
    end
    NegativeRadius = -radius
    local playerCoords = GetEntityCoords(PlayerPedId())
    local spawnCoords = nil
    while spawnCoords == nil do
        local spawnX = math.random(NegativeRadius, radius)
        local spawnY = math.random(NegativeRadius, radius)
        local spawnZ = coord.z
        local vec = vector3(coord.x + spawnX, coord.y + spawnY, spawnZ)
        -- if #(playerCoords - vec) > radius then
            spawnCoords = vec
        -- end
        Citizen.Wait(0)
    end
    local worked, groundZ, normal = GetGroundZAndNormalFor_3dCoord(spawnCoords.x, spawnCoords.y, 1023.9)
    spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ)
    return spawnCoords
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 245)
    SetTextOutline(true)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

Citizen.CreateThread(function()
    while true do
        local idle = 250
        local PlayerPed = PlayerPedId()
        local entity, entityType, entityCoords = GetEntityPlayerIsLookingAt(3.0, 0.2, 286, PlayerPed)

        if entity and entityType ~= 0 then
            if entity ~= CurrentTarget then
                CurrentTarget = entity
                TriggerEvent('hayvan:bul', CurrentTarget, entityType, entityCoords)
            end
        elseif CurrentTarget then
            CurrentTarget = nil
            TriggerEvent('hayvan:bul', CurrentTarget)
        end

        Citizen.Wait(idle)
    end
end)

function GetEntityPlayerIsLookingAt(pDistance, pRadius, pFlag, pIgnore)
    local distance = pDistance or 3.0
    local originCoords = GetPedBoneCoords(PlayerPedId(), 31086)
    local forwardVectors = GetForwardVector(GetGameplayCamRot(2))
    local forwardCoords = originCoords + (forwardVectors * (IsInVehicle and distance + 1.5 or distance))

    if not forwardVectors then return end

    local _, hit, targetCoords, _, targetEntity = RayCast(originCoords, forwardCoords, pFlag or 286, pIgnore, pRadius or 0.2)

    if not hit and targetEntity == 0 then return end

    local entityType = GetEntityType(targetEntity)

    return targetEntity, entityType, targetCoords
end

function GetForwardVector(rotation)
    local rot = (math.pi / 180.0) * rotation
    return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
end

function RayCast(origin, target, options, ignoreEntity, radius)
    local handle = StartShapeTestSweptSphere(origin.x, origin.y, origin.z, target.x, target.y, target.z, radius, options, ignoreEntity, 0)
    return GetShapeTestResult(handle)
end

RegisterNetEvent("hayvan:bul")
AddEventHandler("hayvan:bul", function(pEntity, type, coords)
    targetedEntity = pEntity
    targetedEntityCoord = coords
end)

function GetClosestPlayerMenu()
	local player, distance = QBCore.Functions.GetClosestPlayer()
	if distance ~= -1 and distance <= 5.0 then
		return true, GetPlayerServerId(player)
	else
		return false
	end
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 245)
    SetTextOutline(true)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end


local sendInputSpamProtect = 0
RegisterNUICallback('sendInput', function(data, cb)
	if sendInputSpamProtect <= GetGameTimer() then
		sendInputSpamProtect = GetGameTimer() + 2000 
		QBCore.Functions.TriggerCallback("ak4y-advancedHunting:sendInput", function(result)
			if result then 	
				cb(tonumber(result))
			else
				cb(false)
			end
		end, data)
    else
        cb(false)
	end
end)

RegisterNetEvent('hunting-level:up')
AddEventHandler('hunting-level:up', function(level)
    currentLevel = level
end)

Citizen.CreateThread(function()
    UnlimitedAmmoWeapons = AK4Y.UnlimitedAmmoWeapons
    zones = AK4Y.HuntLocations
    while true do
        pedaq = PlayerPedId()
        for k,v in pairs(zones) do
            if GetDistanceBetweenCoords(GetEntityCoords(pedaq), v.location, false) < v.radius then
                for k,v in pairs(UnlimitedAmmoWeapons) do
                    silah = GetSelectedPedWeapon(pedaq)
                    if silah == GetHashKey(k) then
                        if GetAmmoInPedWeapon(pedaq, silah) < 5 then
                            SetPedAmmo(pedaq, k, 5)
                        end
                    end
                end
            end
        end
        Citizen.Wait(3000)
    end
end)