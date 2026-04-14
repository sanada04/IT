local function getGarageOwnerIdentifier(source, garageId, garageLocations)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(source)
    local playerJob = Framework.Server.GetPlayerJob(source)
    local playerGang = nil
    
    if Config.Framework ~= "ESX" or Config.GangEnableCustomESXIntegration then
        playerGang = Framework.Server.GetPlayerGang(source)
    end
    
    debugPrint("Player Identifier", "debug", playerIdentifier)
    debugPrint("Player Gang", "debug", playerGang)
    debugPrint("Player Job", "debug", playerJob)
    
    local availableGarages = garageLocations or getPlayerAvailableGarageLocations(source)
    local garageData = availableGarages and availableGarages[garageId]
    
    if not garageData then
        return playerIdentifier
    end
    
    if playerJob and garageData.garageType == "job" and garageData.vehiclesType ~= "personal" then
        playerIdentifier = playerJob.name
    end
    
    if playerGang and garageData.garageType == "gang" and garageData.vehiclesType ~= "personal" then
        playerIdentifier = playerGang.name
    end
    
    return playerIdentifier
end

function getVehicleData(source, plate, garageId, ownerIdentifier)
    local vehicleData = nil
    
    if not garageId then
        -- Get vehicle without checking owner
        local query = Framework.Queries.GetVehicleNoIdentifier:format(Framework.VehiclesTable)
        vehicleData = MySQL.prepare.await(query, {plate}) or false
    else
        -- Get vehicle with owner check
        if not ownerIdentifier then
            ownerIdentifier = getGarageOwnerIdentifier(source, garageId)
        end
        
        local query = Framework.Queries.GetVehicle:format(Framework.VehiclesTable, Framework.PlayerIdentifier)
        vehicleData = MySQL.prepare.await(query, {ownerIdentifier, plate})
    end
    
    if not vehicleData then
        debugPrint("Vehicle data is nil", "warning", plate)
        return false
    end
    
    vehicleData.id = vehicleData.id or 0
    vehicleData.model = Framework.Server.GetModelColumn(vehicleData)
    local modelHash = convertModelToHash(vehicleData.model)
    vehicleData.hash = modelHash
    return vehicleData
end

lib.callback.register("jg-advancedgarages:server:get-vehicle", function(source, plate, garageId)
    return getVehicleData(source, plate, garageId)
end)

lib.callback.register("jg-advancedgarages:server:check-vehicle-owner", function(source, plate)
    if not plate or plate == "" then
        return false
    end
    
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(source)
    if not playerIdentifier then
        return false
    end
    
    -- Check personal vehicles
    local query = string.format("SELECT 1 FROM %s WHERE plate = ? AND %s = ? LIMIT 1", 
        Framework.VehiclesTable, Framework.PlayerIdentifier)
    local result = MySQL.rawExecute.await(query, {plate, playerIdentifier})
    
    if result and #result > 0 then
        return true
    end
    
    -- Check job vehicles if applicable
    local playerJob = Framework.Server.GetPlayerJob(source)
    if playerJob and playerJob.name then
        query = string.format("SELECT 1 FROM %s WHERE plate = ? AND %s = ? LIMIT 1", 
            Framework.VehiclesTable, Framework.PlayerIdentifier)
        result = MySQL.rawExecute.await(query, {plate, playerJob.name})
        
        if result and #result > 0 then
            return true
        end
    end
    
    -- Check gang vehicles if applicable
    if Config.Framework ~= "ESX" or Config.GangEnableCustomESXIntegration then
        local playerGang = Framework.Server.GetPlayerGang(source)
        if playerGang and playerGang.name then
            query = string.format("SELECT 1 FROM %s WHERE plate = ? AND %s = ? LIMIT 1", 
                Framework.VehiclesTable, Framework.PlayerIdentifier)
            result = MySQL.rawExecute.await(query, {plate, playerGang.name})
            
            if result and #result > 0 then
                return true
            end
        end
    end
    
    return false
end)

lib.callback.register("jg-advancedgarages:server:get-garage-vehicles", function(source, garageId)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(source)
    
    if not playerIdentifier then
        debugPrint("Player identifier is nil", "warning")
        return {}
    end
    
    local vehicles = {}
    local playerJob = Framework.Server.GetPlayerJob(source)
    local playerGang = nil
    
    if Config.Framework ~= "ESX" or Config.GangEnableCustomESXIntegration then
        playerGang = Framework.Server.GetPlayerGang(source)
    end
    
    debugPrint("Player Identifier", "debug", playerIdentifier)
    debugPrint("Player Gang", "debug", playerGang)
    debugPrint("Player Job", "debug", playerJob)
    
    local availableGarages = getPlayerAvailableGarageLocations(source)
    local garageData = availableGarages and availableGarages[garageId]
    
    if not garageData then
        garageData = {
            garageType = "personal",
            checkVehicleGarageId = Config.GarageUniqueLocations,
            enableInteriors = Config.PrivGarageEnableInteriors
        }
    end
    
    if playerJob and garageData.garageType == "job" and garageData.vehiclesType ~= "personal" then
        if garageData.vehiclesType == "owned" then
            local query = Framework.Queries.GetJobVehicles:format(Framework.VehiclesTable, Framework.PlayerIdentifier)
            vehicles = MySQL.rawExecute.await(query, {playerJob.name, playerJob.grade or 0}) or {}
        elseif garageData.vehiclesType == "spawner" and garageData.vehicles then
            for index, vehicle in ipairs(garageData.vehicles) do
                vehicle.spawnerModel = vehicle.model
                vehicle.spawnerIndex = index
                vehicle.spawner = true
                table.insert(vehicles, vehicle)
            end
        end
    elseif playerGang and garageData.garageType == "gang" and garageData.vehiclesType ~= "personal" then
        if garageData.vehiclesType == "owned" then
            local query = Framework.Queries.GetGangVehicles:format(Framework.VehiclesTable, Framework.PlayerIdentifier)
            vehicles = MySQL.rawExecute.await(query, {playerGang.name, playerGang.grade or 0}) or {}
        elseif garageData.vehiclesType == "spawner" and garageData.vehicles then
            for index, vehicle in ipairs(garageData.vehicles) do
                vehicle.spawnerModel = vehicle.model
                vehicle.spawnerIndex = index
                vehicle.spawner = true
                table.insert(vehicles, vehicle)
            end
        end
    elseif garageData.garageType == "impound" then
        if garageData.hasImpoundJob then
            local query = Framework.Queries.GetImpoundVehiclesWhitelist:format(Framework.VehiclesTable)
            vehicles = MySQL.rawExecute.await(query, {garageId}) or {}
        else
            local query = Framework.Queries.GetImpoundVehiclesPublic:format(
                Framework.VehiclesTable, 
                Framework.PlayerIdentifier, 
                Framework.PlayerIdentifier, 
                Framework.PlayerIdentifier
            )
            local jobName = playerJob and playerJob.name or "-"
            local gangName = playerGang and playerGang.name or "-"
            vehicles = MySQL.rawExecute.await(query, {garageId, playerIdentifier, jobName, gangName}) or {}
        end
    else
        local query = Framework.Queries.GetVehicles:format(Framework.VehiclesTable, Framework.PlayerIdentifier)
        vehicles = MySQL.rawExecute.await(query, {playerIdentifier}) or {}
    end
    
    local filteredVehicles = {}
    
    for _, vehicle in ipairs(vehicles) do
        local model = vehicle.spawnerModel or Framework.Server.GetModelColumn(vehicle)
        
        if model then
            local vehicleProps = false
            if vehicle[Framework.VehProps] then
                vehicleProps = json.decode(vehicle[Framework.VehProps] or "{}")
            end
            
            -- Check grade requirements
            local meetsRequirements = true
            
            if vehicle.minJobGrade and (not playerJob or playerJob.grade < vehicle.minJobGrade) then
                meetsRequirements = false
            elseif vehicle.minGangGrade and (not playerGang or playerGang.grade < vehicle.minGangGrade) then
                meetsRequirements = false
            end
            
            if meetsRequirements then
                local vehicleId = vehicle.id or 0
                local vehicleData = {
                    id = vehicleId,
                    hash = convertModelToHash(model),
                    model = model,
                    props = vehicleProps,
                    nickname = vehicle.nickname or false,
                    plate = vehicle.plate or false,
                    blacklisted = model and isVehicleTransferBlacklisted(model) or false,
                    impound = vehicle.impound == 1 or vehicle.impound,
                    impoundRetrievable = vehicle.impound_retrievable == 1 or vehicle.impound_retrievable,
                    impoundData = vehicle.impound_data,
                    mileage = vehicle.mileage,
                    needsServicing = vehicleProps and doesVehicleNeedServicing(vehicleProps) or false,
                    garageId = vehicle.garage_id,
                    inGarage = (vehicle.in_garage and vehicle.in_garage == 1) and true or false,
                    isSpawned = not garageData.infiniteSpawns and isVehicleSpawned(vehicle.plate),
                    fuel = math.floor((vehicle.fuel or 100.0) * 100) / 100,  -- Round to 2 decimal places
                    engine = vehicle.engine or 1000.0,
                    body = vehicle.body or 1000.0,
                    financed = vehicle.financed == 1 or vehicle.financed,
                    financeData = vehicle.financed == 1 and json.decode(vehicle.finance_data or "{}") or false,
                    spawnerIndex = vehicle.spawnerIndex or false
                }
                table.insert(filteredVehicles, vehicleData)
            end
        end
    end
    
    return filteredVehicles or {}
end)

lib.callback.register("jg-advancedgarages:server:store-vehicle", function(source, garageId, netId, plate, props, fuel, body, engine, damage)
    local availableGarages = getPlayerAvailableGarageLocations(source)
    local garageData = availableGarages and availableGarages[garageId]
    
    if garageData and garageData.vehiclesType == "spawner" then
        -- Spawner vehicles don't get stored in database, just delete them
        lib.callback.await("jg-advancedgarages:client:leave-vehicle", source, netId, garageData and garageData.type)
        deleteVehicle(NetworkGetEntityFromNetworkId(netId), netId, plate)
        return true
    end
    
    local ownerIdentifier = Framework.Server.GetPlayerIdentifier(source)
    
    if garageData then
        if not garageData or garageData.garageType == "impound" then
            return false
        end
        
        if garageData.garageType == "job" and garageData.vehiclesType ~= "personal" then
            ownerIdentifier = garageData.job
        end
        
        if garageData.garageType == "gang" and garageData.vehiclesType ~= "personal" then
            ownerIdentifier = garageData.gang
        end
    end
    
    Globals.OutsideVehicles[plate] = nil
    
    debugPrint("Storing vehicle ", "debug", 
        "Identifier:", ownerIdentifier or nil,
        "Plate:", plate or nil,
        "Engine:", engine or nil,
        "Body:", body or nil,
        "Fuel:", fuel or nil,
        "Damage:", damage or {}
    )
    
    MySQL.update.await(
        Framework.Queries.StoreVehicle:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {
            garageId,
            math.floor((fuel or 0) * 100) / 100,  -- Round fuel to 2 decimal places
            body or 0,
            engine or 0,
            damage and json.encode(damage) or nil,
            ownerIdentifier,
            plate
        }
    )
    
    sendWebhook(source, Webhooks.VehicleTakeOutAndInsert, "Vehicle stored in garage", "success", {
        {key = "Plate", value = plate},
        {key = "Garage", value = garageId}
    })
    
    if Config.SaveVehiclePropsOnInsert and props then
        MySQL.update.await(
            Framework.Queries.UpdateProps:format(Framework.VehiclesTable, Framework.VehProps),
            {json.encode(props), plate}
        )
    end
    
    lib.callback.await("jg-advancedgarages:client:leave-vehicle", source, netId, garageData and garageData.type)
    deleteVehicle(NetworkGetEntityFromNetworkId(netId), netId, plate)
    
    return true
end)

lib.callback.register("jg-advancedgarages:server:drive-vehicle-out", function(source, plate, garageId, spawnerIndex, spawnCoords)
    local vehicleData = nil
    local model = nil
    local vehicleInfo = nil
    local availableGarages = getPlayerAvailableGarageLocations(source)
    local ownerIdentifier = getGarageOwnerIdentifier(source, garageId, availableGarages)
    local garageData = availableGarages and availableGarages[garageId]
    local allowInfiniteSpawns = (garageData and garageData.infiniteSpawns) or Config.AllowInfiniteVehicleSpawns
    local vehiclesType = garageData and garageData.vehiclesType
    
    if not allowInfiniteSpawns and vehiclesType ~= "spawner" and plate then
        if isVehicleSpawned(plate) then
            Framework.Server.Notify(source, "Vehicle is already out", "error")
            return false
        end
    end
    
    if garageData then
        if garageData.coords then
            local maxDistance = garageData.distance or 15.0
            local playerPed = GetPlayerPed(source)
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - garageData.coords.xyz)
            
            if distance > maxDistance then
                Framework.Server.Notify(source, "You are too far away from the garage", "error")
                return false
            end
        end
    end
    
    local coords = (garageData and garageData.spawn) and findVehicleSpawnCoords(garageData.spawn) or spawnCoords
    
    if not coords then
        local playerPed = GetPlayerPed(source)
        local playerCoords = GetEntityCoords(playerPed)
        coords = vector4(playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(playerPed))
    end
    
    if vehiclesType == "spawner" then
        local spawnerVehicle = garageData and garageData.vehicles and garageData.vehicles[spawnerIndex]
        
        if not spawnerIndex or not spawnerVehicle then
            return false
        end
        
        model = spawnerVehicle.model
        
        if plate == "" then
            plate = false
        end
        
        if plate then
            plate = plate:upper()
        end
        
        local props = {}
        if plate then
            props.plate = plate
        end
        
        if spawnerVehicle.maxMods then
            props.modEngine = 3
            props.modBrakes = 2
            props.modTransmission = 2
            props.modSuspension = 3
            props.modTurbo = true
        end
        
        vehicleInfo = {
            props = props,
            fuel = 100.0,
            engine = 1000.0,
            body = 1000.0,
            damage = false,
            livery = spawnerVehicle.livery,
            extras = spawnerVehicle.extras,
            clean = true
        }
    else
        if not plate then
            Framework.Server.Notify(source, "Vehicle plate is nil", "error")
            return
        end
        
        vehicleData = getVehicleData(source, plate, garageId, ownerIdentifier)
        
        if not vehicleData then
            Framework.Server.Notify(source, "Could not get the vehicle's data, see console", "error")
            print("^1[ERROR] Could not get vehicle data - plate does not exist on lookup, it does not belong to you or is corrupted?")
            return false
        end
        
        model = vehicleData.model
        
        vehicleInfo = {
            props = vehicleData[Framework.VehProps] and json.decode(vehicleData[Framework.VehProps]) or false,
            fuel = vehicleData.fuel or 100.0,
            engine = vehicleData.engine or 1000.0,
            body = vehicleData.body or 1000.0,
            damage = vehicleData.damage and json.decode(vehicleData.damage) or false
        }
    end
    
    local verified = lib.callback.await("jg-advancedgarages:client:takeout-vehicle-verification", source, plate, vehicleData or {}, garageId)
    
    if not verified then
        debugPrint("jg-advancedgarages:client:takeout-vehicle-verification returned false", "debug")
        return false
    end
    
    if Config.SpawnVehiclesWithServerSetter then
        local warpIntoVehicle = not Config.DoNotSpawnInsideVehicle
        local vehicle = spawnVehicleServer(
            source,
            vehicleData and vehicleData.id or 0,
            model,
            plate,
            coords,
            warpIntoVehicle,
            vehicleInfo,
            garageData and garageData.garageType
        )
        
        if not vehicle then
            Framework.Server.Notify(source, "Could not spawn vehicle with Config.SpawnVehiclesWithServerSetter", "error")
            return false
        end
    end
    
    return true, vehicle, model, vehicleData, vehicleInfo, coords
end)

lib.callback.register("jg-advancedgarages:server:vehicle-driven-out", function(source, garageId, netId, plate, shouldPay)
    local ownerIdentifier = getGarageOwnerIdentifier(source, garageId)
    
    if shouldPay then
        local paid = Framework.Server.PlayerRemoveMoney(source, Config.GarageVehicleReturnCost, "bank")
        if not paid then
            return false
        end
        
        if Config.GarageVehicleReturnCostSocietyFund then
            Framework.Server.PayIntoSocietyFund(Config.GarageVehicleReturnCostSocietyFund, Config.GarageVehicleReturnCost)
        end
    end
    
    Globals.OutsideVehicles[plate] = netId
    
    MySQL.update.await(
        Framework.Queries.VehicleDriveOut:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {ownerIdentifier, plate}
    )
    
    if GetResourceState("jpr-housingsystem") == "started" then
        MySQL.query.await("DELETE FROM jpr_housingsystem_houses_garages WHERE plate = ?", {plate})
    end
    
    sendWebhook(source, Webhooks.VehicleTakeOutAndInsert, "Vehicle taken out of garage", "success", {
        {key = "Plate", value = plate},
        {key = "Garage", value = garageId}
    })
    
    return true
end)

lib.callback.register("jg-advancedgarages:server:transfer-vehicle-to-player", function(source, plate, fromGarageId, targetPlayerId)
    local verified = lib.callback.await("jg-advancedgarages:client:transfer-vehicle-verification", source, targetPlayerId, plate)
    
    if not verified then
        return false
    end
    
    local ownerIdentifier = getGarageOwnerIdentifier(source, fromGarageId)
    local targetIdentifier = Framework.Server.GetPlayerIdentifier(targetPlayerId)
    
    if not targetIdentifier then
        Framework.Server.Notify(source, Locale.playerNotOnlineError, "error")
        return false
    end
    
    local targetInfo = Framework.Server.GetPlayerInfo(targetPlayerId)
    local targetName = targetInfo and targetInfo.name
    
    MySQL.update.await(
        Framework.Queries.UpdatePlayerId:format(Framework.VehiclesTable, Framework.PlayerIdentifier, Framework.PlayerIdentifier),
        {targetIdentifier, ownerIdentifier, plate}
    )
    
    if GetResourceState("jpr-housingsystem") == "started" then
        MySQL.query.await("DELETE FROM jpr_housingsystem_houses_garages WHERE plate = ?", {plate})
    end
    
    sendWebhook(source, Webhooks.VehiclePlayerTransfer, "Vehicle transferred to another player", "warning", {
        {key = "Plate", value = plate},
        {key = "Recipient", value = targetName}
    })
    
    return true
end)

lib.callback.register("jg-advancedgarages:server:transfer-vehicle-garage", function(source, plate, fromGarageId, toGarageId, toGarageName)
    local verified = lib.callback.await("jg-advancedgarages:client:transfer-garage-verification", source, fromGarageId, toGarageId, toGarageName, plate)
    
    if not verified then
        return false
    end
    
    local ownerIdentifier = getGarageOwnerIdentifier(source, toGarageId)
    local availableGarages = getPlayerAvailableGarageLocations(source)
    local targetGarage = availableGarages and availableGarages[toGarageName]
    
    if not targetGarage and Config.DisableTransfersToUnregisteredGarages then
        Framework.Server.Notify(source, "Transfers to this garage are disabled, please contact an admin", "error")
        return false
    end
    
    if Config.GarageVehicleTransferCost then
        local paid = Framework.Server.PlayerRemoveMoney(source, Config.GarageVehicleTransferCost, "bank")
        if not paid then
            print("^1[ERROR] Could not remove player money. Attempted to remove amount:", Config.GarageVehicleTransferCost)
            return false
        end
    end
    
    MySQL.update.await(
        Framework.Queries.UpdateGarageId:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {toGarageName, ownerIdentifier, plate}
    )
    
    sendWebhook(source, Webhooks.VehicleGarageTransfer, "Vehicle transferred to another garage", "warning", {
        {key = "Plate", value = plate},
        {key = "From Garage", value = fromGarageId},
        {key = "To Garage", value = toGarageName}
    })
    
    return true
end)

lib.callback.register("jg-advancedgarages:server:vehicle-set-nickname", function(source, plate, nickname, garageId)
    local ownerIdentifier = getGarageOwnerIdentifier(source, garageId)
    
    MySQL.update.await(
        Framework.Queries.UpdateVehicleNickname:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {nickname, ownerIdentifier, plate}
    )
    
    return true
end)

exports("getAllGarages", function()
    local garages = {}
    
    for garageName, garageData in pairs(getAllGaragesAndImpounds()) do
        table.insert(garages, {
            name = garageName,
            label = garageName,
            type = garageData.type,
            takeVehicle = garageData.coords,
            putVehicle = garageData.coords,
            spawnPoint = garageData.spawn,
            showBlip = not garageData.hideBlip,
            blipName = garageName,
            blipNumber = garageData.blip.id,
            blipColor = garageData.blip.color,
            vehicle = garageData.type
        })
    end
    
    return garages
end)
