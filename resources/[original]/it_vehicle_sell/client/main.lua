local QBCore = exports['qb-core']:GetCoreObject()
local isUIOpen      = false
local isHintShowing = false
local sellPed       = 0

-- ブリップ作成
CreateThread(function()
    if not Config.Blip.show then return end
    local blip = AddBlipForCoord(Config.SellLocation.x, Config.SellLocation.y, Config.SellLocation.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)
end)

-- NPC スポーン
CreateThread(function()
    local model = GetHashKey(Config.Ped.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(100) end

    sellPed = CreatePed(4, model,
        Config.SellLocation.x, Config.SellLocation.y, Config.SellLocation.z - 1.0,
        Config.Ped.heading, false, false)

    SetEntityAsMissionEntity(sellPed, true, true)
    SetBlockingOfNonTemporaryEvents(sellPed, true)
    SetPedDiesWhenInjured(sellPed, false)
    SetPedCanRagdoll(sellPed, false)
    SetEntityInvincible(sellPed, true)
    SetEntityProofs(sellPed, true, true, true, true, true, true, true, true)
    SetPedCanBeTargetted(sellPed, false)
    FreezeEntityPosition(sellPed, true)
    SetPedFleeAttributes(sellPed, 0, false)
    SetPedCombatAttributes(sellPed, 46, true)
    TaskStartScenarioInPlace(sellPed, Config.Ped.scenario, 0, true)

    SetModelAsNoLongerNeeded(model)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and DoesEntityExist(sellPed) then
        DeleteEntity(sellPed)
    end
end)

-- 近接インタラクション ループ
CreateThread(function()
    while true do
        local sleep = 500
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - Config.SellLocation)

        if dist < 30.0 then
            sleep = 0
            local shouldShow = dist < Config.InteractRange and not isUIOpen

            if shouldShow and not isHintShowing then
                isHintShowing = true
                SendNUIMessage({ action = 'showHint' })
                PlaySoundFrontend(-1, 'WAYPOINT_SET', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            elseif not shouldShow and isHintShowing then
                isHintShowing = false
                SendNUIMessage({ action = 'hideHint' })
            end

            if shouldShow and IsControlJustReleased(0, 38) then
                openVehicleSell()
            end
        else
            if isHintShowing then
                isHintShowing = false
                SendNUIMessage({ action = 'hideHint' })
            end
        end

        Wait(sleep)
    end
end)

function openVehicleSell()
    QBCore.Functions.TriggerCallback('it-vehiclesell:server:getPlayerVehicles', function(vehicles)
        if not vehicles or #vehicles == 0 then
            QBCore.Functions.Notify('売却できる車両がありません（ガレージ保管中の車両が対象です）', 'error', 4000)
            return
        end

        isUIOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action   = 'openUI',
            vehicles = vehicles,
            sellRate = Config.SellPriceRate,
        })
    end)
end

RegisterNUICallback('closeUI', function(_, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellVehicles', function(data, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    TriggerServerEvent('it-vehiclesell:server:sellVehicles', data.plates)
    cb('ok')
end)

RegisterNetEvent('it-vehiclesell:client:sellResult', function(success, message)
    if success then
        QBCore.Functions.Notify(message, 'success', 5000)
    else
        QBCore.Functions.Notify(message, 'error', 5000)
    end
end)
