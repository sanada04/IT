local IMPOUND_VEHICLE_DISTANCE = 5.0
local targetVehicle = nil
local function getImpoundLocationsByType(vehicleType)
    local impoundLocations = {}
    local playerJob = Framework.Client.GetPlayerJob()
    
    if not playerJob then
        return {}
    end
    
    debugPrint("Player Job", "debug", playerJob)
    
    for impoundId, impoundData in pairs(Config.ImpoundLocations) do
        if not impoundData.job then
            print(("^1[WARNING] Heads up, %s does not have a job tied to it in the config"):format(impoundId))
        end
        
        if impoundData.job and isItemInList(impoundData.job, playerJob.name) then
            if impoundData.type == vehicleType then
                table.insert(impoundLocations, impoundId)
            end
        end
    end
    
    return impoundLocations
end
local function showImpoundForm()
    if Framework.Client.IsPlayerDead() then
        Framework.Client.Notify(Locale.playerIsDead, "error")
        return false
    end
    
    local playerCoords = GetEntityCoords(cache.ped)
    targetVehicle = lib.getClosestVehicle(playerCoords, IMPOUND_VEHICLE_DISTANCE, true)
    
    if not targetVehicle or targetVehicle == 0 then
        Framework.Client.Notify(Locale.moveCloserToVehicleError, "error")
        return false
    end
    
    debugPrint("Found target vehicle for impound", "debug", targetVehicle)
    
    local vehicleType = getVehicleType(GetEntityModel(targetVehicle))
    local impoundLocations = getImpoundLocationsByType(vehicleType)
    
    debugPrint("Vehicle type and impound locations", "debug", vehicleType, json.encode(impoundLocations))
    
    if not impoundLocations or #impoundLocations == 0 then
        Framework.Client.Notify(Locale.actionNotAllowedError, "error")
        return false
    end
    
    local plate = Framework.Client.GetPlate(targetVehicle)
    local vehicleData = lib.callback.await("jg-advancedgarages:server:get-vehicle", false, plate)
    
    debugPrint("Vehicle plate and data", "debug", plate, vehicleData and "Found" or "Not found (NPC)")
    
    if not vehicleData then
        deleteVehicle(targetVehicle)
        Framework.Client.Notify(Locale.vehicleImpoundSuccess .. " (NPC)", "success")
        return true
    end
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "show-impound-form",
        impoundLocations = impoundLocations,
        plate = plate,
        config = Config,
        locale = Locale
    })
    
    debugPrint("Sent impound form NUI message", "debug")
end
local function impoundVehicle(impoundData)
    if not targetVehicle or not DoesEntityExist(targetVehicle) then
        debugPrint("Target vehicle does not exist for impound", "error")
        return false
    end
    
    debugPrint("Impounding vehicle with data", "debug", json.encode(impoundData))
    
    local plate = Framework.Client.GetPlate(targetVehicle)
    local vehicleProps = Framework.Client.GetVehicleProperties(targetVehicle)
    local fuel = Framework.Client.VehicleGetFuel(targetVehicle)
    local bodyHealth, engineHealth, deformation = getVehicleDamage(targetVehicle)
    
    debugPrint("Vehicle details for impound", "debug", plate, fuel, engineHealth, bodyHealth)
    
    local success = lib.callback.await(
        "jg-advancedgarages:server:impound-vehicle",
        false,
        impoundData,
        VehToNet(targetVehicle),
        plate,
        vehicleProps,
        fuel,
        engineHealth,  -- engine parameter
        bodyHealth,    -- body parameter
        deformation
    )
    
    if not success then
        debugPrint("Server impound callback failed", "error")
        return false
    end
    
    TriggerEvent("jg-advancedgarages:client:ImpoundVehicle:config", targetVehicle)
    debugPrint("Vehicle impounded successfully", "success", plate)
    return true
end
local function driveVehicleFromImpound(impoundId, originalGarageId, plate)
    local success, vehicle, vehicleData, vehicleProps, coords = lib.callback.await(
        "jg-advancedgarages:server:impound-remove-vehicle",
        false,
        impoundId,
        originalGarageId,
        plate,
        true
    )
    if not success then
        return false
    end
    
    if Config.SpawnVehiclesWithServerSetter and not vehicle then
        print("^1There was a problem spawning in your vehicle")
        return false
    end
    
    if not vehicle and not Config.SpawnVehiclesWithServerSetter then
        local warpIntoVehicle = not Config.DoNotSpawnInsideVehicle
        vehicle = spawnVehicleClient(
            vehicleData and vehicleData.id or 0,
            vehicleData.model,
            plate,
            coords,
            warpIntoVehicle,
            vehicleProps,
            "personal"
        )
        
        if not vehicle then
            print("^1There was a problem spawning in your vehicle")
            return false
        end
        
        TriggerServerEvent("jg-advancedgarages:server:register-vehicle-outside", plate, NetworkGetNetworkIdFromEntity(vehicle))
    end
    
    return true
end
RegisterNUICallback("impound-vehicle", function(data, callback)
    local result = impoundVehicle(data)
    
    if not result then
        return callback({ success = false, error = true })
    end
    
    callback({ success = true })
end)
RegisterNUICallback("impound-return-vehicle", function(data, callback)
    local result = lib.callback.await(
        "jg-advancedgarages:server:impound-remove-vehicle",
        false,
        data.impoundId,
        data.originalGarageId,
        data.plate,
        false
    )
    
    if not result then
        return callback({ success = false, error = true })
    end
    
    callback({ success = true })
end)
RegisterNUICallback("impound-drive-vehicle", function(data, callback)
    local result = driveVehicleFromImpound(data.impoundId, data.originalGarageId, data.plate)
    
    if not result then
        return callback({ success = false, error = true })
    end
    
    callback({ success = true })
end)
RegisterNetEvent("jg-advancedgarages:client:show-impound-form", showImpoundForm)
RegisterNetEvent("jg-advancedgarages:client:ImpoundVehicle", showImpoundForm)
