local isGarageOpen = false
garageVehicles = {} -- Make it global so cl-interior.lua can access it
local function getTransferGarageList(vehicleType, garageType, vehiclesType)
    local transferGarages = {}
    local availableGarages = getAvailableGarageLocations()
    
    for garageId, garage in pairs(availableGarages) do
        if garage.type == vehicleType then
            if garageType == "job" or garageType == "gang" then
                if garage.vehiclesType == vehiclesType then
                    if garage.garageType == "personal" then
                        transferGarages[#transferGarages + 1] = garageId
                    end
                end
            elseif garageType == "personal" then
                if garage.garageType == "personal" then
                    transferGarages[#transferGarages + 1] = garageId
                end
            end
        end
    end
    
    return transferGarages
end
function fetchGarageVehicles(garageId, vehicleType)
    local vehicles = lib.callback.await("jg-advancedgarages:server:get-garage-vehicles", 2000, garageId)
    if not vehicles then
        vehicles = garageVehicles
    end
    
    garageVehicles = filterVehiclesByType(vehicles, vehicleType)
    
    for index, vehicleData in ipairs(garageVehicles) do
        if vehicleData.model then
            local modelName
            if type(vehicleData.model) == "string" and vehicleData.model then
                modelName = vehicleData.model
            else
                modelName = getModelNameFromHash(vehicleData.hash)
            end
            
            garageVehicles[index].model = modelName
            garageVehicles[index].vehicleLabel = Framework.Client.GetVehicleLabel(vehicleData.model)
        else
            print(("^1Vehicle with plate %s does not have a model."):format(vehicleData.plate))
        end
    end
    
    return garageVehicles
end
function openGarageMenu(garageId, vehicleType, spawnCoords)
    if not vehicleType then
        vehicleType = "car"
    end
    
    local isPlayerDead = Framework.Client.IsPlayerDead()
    if isPlayerDead then
        Framework.Client.Notify(Locale.playerIsDead, "error")
        return
    end
    local availableGarages = getAvailableGarageLocations()
    local garageData = availableGarages and availableGarages[garageId]
    
    if garageData and garageData.coords then
        local maxDistance = garageData.distance or 15.0
        local playerCoords = GetEntityCoords(cache.ped)
        local distance = #(playerCoords - garageData.coords.xyz)
        
        if distance > maxDistance then
            print(("^1The garage you are trying to open '%s' is a registered garage, and you are not at it's registered location."):format(garageId))
            print("^1If you were expecting to open a location via housing or another third-party integration, please note that this script is trying to open a garage with a name that is already registered.")
            print("^1Therefore, you will need to use a unique garageId in order to be able to open this garage.^0")
            Framework.Client.Notify("You are too far away from the garage", "error")
            return false
        end
    end
    if not garageData then
        garageData = {
            garageType = "personal",
            checkVehicleGarageId = Config.GarageUniqueLocations,
            enableInteriors = Config.PrivGarageEnableInteriors,
            unknown = true
        }
    end
    local nearbyPlayers = lib.callback.await("jg-advancedgarages:server:nearby-players", false, GetEntityCoords(cache.ped), 20.0, false)
    local transferGarages = getTransferGarageList(vehicleType, garageData.garageType, garageData.vehiclesType)
    
    if garageData.unknown then
        transferGarages[#transferGarages + 1] = garageId
    end
    fetchGarageVehicles(garageId, vehicleType)
    if GetResourceState("jg-vehiclemileage") == "started" then
        Config.MileageUnit = exports["jg-vehiclemileage"]:GetUnit()
    end
    if GetResourceState("jg-dealerships") == "started" then
        local success = pcall(function()
            local dealershipLocale = exports["jg-dealerships"]:locale() or {}
            Locale = lib.table.merge(dealershipLocale, Locale, false)
        end)
        
        if not success then
            print("^3[WARNING] You are running jg-dealerships, but you need to be using v1.2 or newer to use it with Advanced Garages v3. Some functionality may not work as expected.")
        end
    end
    SetNuiFocus(true, true)
    
    -- Debug print to check interior settings
    if Config.Debug then
        print(string.format("^2[DEBUG] Opening garage: %s", garageId))
        print(string.format("^2[DEBUG] Garage Type: %s", garageData.type or "unknown"))
        print(string.format("^2[DEBUG] Enable Interiors: %s", tostring(garageData.enableInteriors)))
        print(string.format("^2[DEBUG] Vehicle Type: %s", vehicleType))
    end
    
    SendNUIMessage({
        type = "show-garage",
        garageId = garageId,
        vehicleType = vehicleType,
        vehicles = garageVehicles,
        checkVehicleGarageId = garageData.checkVehicleGarageId,
        enableInteriors = garageData.enableInteriors or false,
        isSpawnerGarage = garageData.vehiclesType == "spawner",
        isJobGarage = garageData.garageType == "job",
        transferGarages = transferGarages,
        onlinePlayers = nearbyPlayers,
        isImpound = garageData.garageType == "impound",
        hasWhitelistedJob = garageData.hasImpoundJob,
        spawnCoords = spawnCoords,
        config = Config,
        locale = Locale
    })
end
function driveVehicleOut(vehiclePlate, garageId, coords, interiorId)
    local garageLocations = getAvailableGarageLocations()
    local garageData = garageLocations and garageLocations[garageId] or {}
    local success, vehicle, vehicleProps, vehicleData, fuelLevel, spawnCoords = lib.callback.await(
        "jg-advancedgarages:server:drive-vehicle-out", false, vehiclePlate, garageId, coords, interiorId
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
        local vehicleId = vehicleData and vehicleData.id or 0
        local garageType = garageData and garageData.garageType
        
        vehicle = spawnVehicleClient(vehicleId, vehicleProps, vehiclePlate, spawnCoords, warpIntoVehicle, fuelLevel, garageType)
        
        if not vehicle then
            return false
        end
    end
    if garageData.vehiclesType ~= "spawner" then
        local isFromImpound = vehicleData and vehicleData.in_garage == 0
        success = lib.callback.await(
            "jg-advancedgarages:server:vehicle-driven-out", false, 
            garageId, VehToNet(vehicle), vehiclePlate, isFromImpound
        )
        
        if not success then
            deleteVehicle(vehicle)
        end
    end
    TriggerEvent("jg-advancedgarages:client:TakeOutVehicle:config", vehicle, vehicleData, garageData and garageData.garageType)
    if garageData.showLiveriesExtrasMenu then
        showLiveriesExtrasMenu(vehicle)
        return { noClose = true }
    end
    
    return true
end
function insertVehicle(garageId, vehicleType)
    if isGarageOpen then
        return false
    end
    
    if not vehicleType then
        vehicleType = "car"
    end
    if Framework.Client.IsPlayerDead() then
        Framework.Client.Notify(Locale.playerIsDead, "error")
        return false
    end
    local vehicle = cache.vehicle
    local plate = Framework.Client.GetPlate(vehicle)
    
    if not vehicle or not plate then
        Framework.Client.Notify(Locale.notInsideVehicleError, "error")
        return false
    end
    local currentVehicleType = getVehicleType(GetEntityModel(vehicle))
    if currentVehicleType ~= vehicleType then
        local errorMessage = string.gsub(Locale.insertVehicleTypeError, "%%{value}", vehicleType)
        return Framework.Client.Notify(errorMessage, "error")
    end
    local availableGarages = getAvailableGarageLocations()
    local garageData = availableGarages and availableGarages[garageId]
    local garageType = garageData and garageData.garageType
    
    if garageType == "impound" then
        return false
    end
    
    isGarageOpen = true
    local vehiclesType = garageData and garageData.vehiclesType
    local vehicleGarageId = (vehiclesType == "spawner") and nil or garageId
    local vehicleData = lib.callback.await("jg-advancedgarages:server:get-vehicle", false, plate, vehicleGarageId)
    
    -- For spawner vehicles, we don't need vehicle data (they're not owned)
    -- For owned vehicles, we need vehicle data to exist
    if vehiclesType ~= "spawner" and not vehicleData then
        Framework.Client.Notify(Locale.vehicleStoreError, "error")
        isGarageOpen = false
        return false
    end
    local vehicleProps = Framework.Client.GetVehicleProperties(vehicle)
    vehicleProps.plate = plate
    
    local fuelLevel = Framework.Client.VehicleGetFuel(vehicle)
    local bodyHealth, engineHealth, deformation = getVehicleDamage(vehicle)
    
    -- Skip verification for spawner vehicles or make it optional
    if vehiclesType ~= "spawner" then
        local verificationResult = false
        local success, errorMsg = pcall(function()
            TriggerEvent(
                "jg-advancedgarages:client:insert-vehicle-verification",
                vehicle, plate, garageId, vehicleData, vehicleProps, fuelLevel,
                bodyHealth, engineHealth, deformation,
                function(result)
                    verificationResult = result
                end
            )
        end)
        
        if not success or not verificationResult then
            isGarageOpen = false
            debugPrint("jg-advancedgarages:client:insert-vehicle-verification returned false or pcall failed: " .. (errorMsg or ""), "debug")
            return false
        end
    end
    local storeSuccess = lib.callback.await(
        "jg-advancedgarages:server:store-vehicle", false,
        garageId, VehToNet(vehicle), plate, vehicleProps, fuelLevel,
        bodyHealth, engineHealth, deformation
    )
    
    if not storeSuccess then
        isGarageOpen = false
        return false
    end
    Framework.Client.VehicleRemoveKeys(plate, vehicle, garageType)
    if garageData then
        local vehicleCoords = GetEntityCoords(vehicle)
        local garageCoords = garageData.coords
        
        if garageCoords and (vehicleType == "air" or vehicleType == "sea") then
            local distance = #(garageCoords.xyz - vehicleCoords.xyz)
            if distance > 0.5 then
                SetEntityCoords(cache.ped, garageCoords.x, garageCoords.y, garageCoords.z, false, false, false, false)
            end
        end
    end
    TriggerEvent("jg-advancedgarages:client:InsertVehicle:config", vehicle, vehicleData, garageType)
    if GetResourceState("wasabi_ambulance") == "started" and garageType == "job" then
        pcall(function()
            exports.wasabi_ambulance:deleteStretcherFromVehicle(vehicle)
        end)
    end
    Framework.Client.Notify(Locale.vehicleParkedSuccess, "success")
    isGarageOpen = false
    return true
end
local function transferVehicle(transferType, garageId, plate, transferPlayerId, transferGarageId, fromGarageId)
    if transferType == "garage" and transferGarageId then
        return lib.callback.await(
            "jg-advancedgarages:server:transfer-vehicle-garage", false,
            plate, garageId, fromGarageId, transferGarageId
        )
    elseif transferType == "player" and transferPlayerId then
        local success = lib.callback.await(
            "jg-advancedgarages:server:transfer-vehicle-to-player", false,
            plate, garageId, transferPlayerId
        )
        if not success then
            return false
        end
        
        TriggerEvent("jg-advancedgarages:client:TransferVehicle:config", plate, transferPlayerId)
        return true
    end
    
    print("^1[ERROR] invalid transfer type or invalid playerId/garageId")
    return false
end
lib.callback.register("jg-advancedgarages:client:leave-vehicle", function(vehicleNetId, vehicleType)
    local vehicle = NetToVeh(vehicleNetId)
    SetVehicleDoorsLocked(vehicle, 2)
    
    for seatIndex = -1, 5 do
        local ped = GetPedInVehicleSeat(vehicle, seatIndex)
        if ped then
            TaskLeaveVehicle(ped, vehicle, 0)
        end
    end
    
    if vehicleType == "air" then
        Wait(2500)
    else
        Wait(1500)
    end
end)
RegisterNUICallback("drive-vehicle", function(data, callback)
    local spawnCoords = nil
    if data.spawnCoords then
        spawnCoords = vec(
            data.spawnCoords.x or 0,
            data.spawnCoords.y or 0,
            data.spawnCoords.z or 0,
            data.spawnCoords.w or 0
        )
    end
    
    local result = driveVehicleOut(data.plate, data.garageId, data.spawnerIndex, spawnCoords)
    
    if not result then
        return callback({ error = true })
    end

    if result ~= nil and type(result) == "table" and result.noClose then
        return callback(result)
    end

    -- Close the garage menu after successful drive out.
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "hide" })
    
    callback(result)
end)
RegisterNUICallback("garage-transfer-vehicle", function(data, callback)
    local result = transferVehicle(
        data.transferType,
        data.garageId,
        data.plate,
        data.transferPlayerId,
        data.transferGarageId,
        data.fromGarageId
    )
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNUICallback("vehicle-set-nickname", function(data, callback)
    local result = lib.callback.await(
        "jg-advancedgarages:server:vehicle-set-nickname", false,
        data.plate, data.nickname, data.garageId
    )
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNUICallback("enter-garage-interior", function(data, callback)
    fetchGarageVehicles(data.garageId, data.vehicleType)
    
    local result = lib.callback.await(
        "jg-advancedgarages:server:enter-interior", false,
        data.garageId, garageVehicles
    )
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNetEvent("jg-advancedgarages:client:open-garage", openGarageMenu)
RegisterNetEvent("jg-advancedgarages:client:store-vehicle", insertVehicle)
RegisterNetEvent("jg-advancedgarages:client:ShowGarage", function(garageId, _, vehicleType)
    openGarageMenu(garageId, vehicleType)
end)
RegisterNetEvent("jg-advancedgarages:client:ShowGangGarage", function(garageId)
    openGarageMenu(garageId, "car")
end)
RegisterNetEvent("jg-advancedgarages:client:ShowJobGarage", function(garageId)
    openGarageMenu(garageId, "car")
end)

-- Debug command to manually open garage with interior enabled
if Config.Debug then
    RegisterCommand("testgaragemenu", function(source, args)
        local garageId = table.concat(args, " ")
        if garageId == "" then
            garageId = "Legion Square"
        end
        
        print(string.format("^2[DEBUG] Opening garage menu for: %s", garageId))
        openGarageMenu(garageId, "car")
    end, false)
    
    print("^2[DEBUG] Test command registered: /testgaragemenu [garageName]")
end
RegisterNetEvent("jg-advancedgarages:client:InsertVehicle", function(garageId, _, vehicleType)
    insertVehicle(garageId, vehicleType)
end)
