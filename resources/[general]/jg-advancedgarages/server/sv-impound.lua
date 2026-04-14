local function hasImpoundJobAccess(source, impoundId)
    local garageLocations = getPlayerAvailableGarageLocations(source)
    local impoundData = garageLocations and garageLocations[impoundId]
    
    if not impoundData then
        return false
    end
    
    return impoundData.hasImpoundJob or false
end

local function formatRetrievalDate(hours)
    local timestamp = os.time() + (hours * 3600)
    return os.date("%a %b %d %Y %H:%M:%S GMT%z", timestamp)
end

local function impoundVehicle(source, plate, impoundId, reason, retrievable, retrievalDate, retrievalCost, vehicleProps, fuel, engine, body, damage)
    if not plate then
        debugPrint("No plate provided for impound", "error")
        return false
    end
    
    if type(retrievalDate) == "number" then
        retrievalDate = formatRetrievalDate(retrievalDate)
    end
    
    debugPrint("Getting vehicle data for impound", "debug", plate)
    local vehicleData = getVehicleData(source, plate)
    if not vehicleData then
        debugPrint("Could not find vehicle data for plate", "error", plate)
        Framework.Server.Notify(source, "Vehicle not found in database", "error")
        return false
    end
    
    local playerInfo = Framework.Server.GetPlayerInfo(source)
    if not playerInfo then
        return false
    end
    
    local impoundData = json.encode({
        charname = playerInfo.name,
        reason = reason,
        retrieval_date = retrievalDate,
        retrieval_cost = retrievalCost,
        original_garage_id = vehicleData.garage_id
    })
    
    Globals.OutsideVehicles[plate] = nil
    
    debugPrint("Executing impound query", "debug", impoundId, plate)
    debugPrint("Query params", "debug", {
        retrievable = retrievable,
        impoundData = impoundData,
        impoundId = impoundId,
        fuel = fuel,
        engine = engine,
        body = body,
        damage = damage and "has damage" or "no damage",
        plate = plate
    })
    
    local query = Framework.Queries.ImpoundVehicle:format(Framework.VehiclesTable)
    debugPrint("Formatted query", "debug", query)
    
    local updateResult = MySQL.update.await(
        query,
        {
            retrievable and 1 or 0,  -- Convert boolean to integer
            impoundData,
            impoundId,
            fuel,
            body,  -- body comes before engine in the query
            engine,
            damage and json.encode(damage) or nil,
            plate
        }
    )
    
    if not updateResult or updateResult == 0 then
        debugPrint("Failed to update vehicle impound status in database", "error", plate)
        Framework.Server.Notify(source, "Failed to impound vehicle", "error")
        return false
    end
    
    if Config.SaveVehiclePropsOnInsert and vehicleProps then
        MySQL.update.await(
            Framework.Queries.UpdateProps:format(Framework.VehiclesTable, Framework.VehProps),
            {json.encode(vehicleProps), plate}
        )
    end
    
    Framework.Server.Notify(source, Locale.vehicleImpoundSuccess, "success")
    
    sendWebhook(source, Webhooks.Impound, "Vehicle Impounded", "success", {
        { key = "Plate", value = plate },
        { key = "Impounded by", value = playerInfo.name },
        { key = "Reason", value = reason },
        { key = "Retrievable by owner?", value = retrievable and "Yes" or "No" },
        { key = "Retrieval Date", value = (retrievable and retrievalDate) or "N/A" },
        { key = "Retrieval Cost", value = (retrievable and retrievalCost) or "N/A" }
    })
    
    return true
end

print("^2[IMPOUND] Registering impound-vehicle callback")
lib.callback.register("jg-advancedgarages:server:impound-vehicle", function(source, impoundFormData, netId, plate, vehicleProps, fuel, engine, body, damage)
    print("^3[IMPOUND] Callback triggered for plate:", plate, "by player:", source)
    debugPrint("Impound vehicle callback triggered", "debug", source, plate, impoundFormData.impoundId)
    
    local hasAccess = hasImpoundJobAccess(source, impoundFormData.impoundId)
    print("^3[IMPOUND] Has access check:", hasAccess, "for impound:", impoundFormData.impoundId)
    
    if not hasAccess then
        debugPrint("Player does not have access to impound", "error", source, impoundFormData.impoundId)
        Framework.Server.Notify(source, "You don't have permission to use this impound", "error")
        return false
    end
    
    local reason = impoundFormData.reason
    local retrievalDate = impoundFormData.retrievalDate
    local retrievalCost = impoundFormData.retrievalCost
    local retrievable = impoundFormData.retrievable
    local impoundId = impoundFormData.impoundId
    
    debugPrint("Impound details", "debug", reason, retrievalDate, retrievalCost, retrievable)
    
    local success = impoundVehicle(source, plate, impoundId, reason, retrievable, retrievalDate, retrievalCost, vehicleProps, fuel, engine, body, damage)
    
    if not success then
        debugPrint("Failed to impound vehicle", "error", plate)
        return false
    end
    
    deleteVehicle(NetworkGetEntityFromNetworkId(netId), netId, plate)
    
    debugPrint("Vehicle impounded successfully", "success", plate, impoundId)
    return true
end)

lib.callback.register("jg-advancedgarages:server:impound-remove-vehicle", function(source, impoundId, garageId, plate, spawnVehicle)
    local vehicleEntity = nil
    local garageLocations = getPlayerAvailableGarageLocations(source)
    local impoundData = garageLocations and garageLocations[impoundId]
    
    if not impoundData then
        return false
    end
    
    local vehicleData = getVehicleData(source, plate)
    if not vehicleData then
        Framework.Server.Notify(source, "Could not get vehicle data from database", "error")
        return false
    end
    
    local spawnCoords = nil
    local vehicleDataToSpawn = {
        props = vehicleData[Framework.VehProps] and json.decode(vehicleData[Framework.VehProps]) or false,
        fuel = vehicleData.fuel or 100.0,
        engine = vehicleData.engine or 1000.0,
        body = vehicleData.body or 1000.0,
        damage = vehicleData.damage and json.decode(vehicleData.damage) or false
    }
    
    local hasAccess = hasImpoundJobAccess(source, impoundId)
    
    if not hasAccess then
        if vehicleData.impound == true or vehicleData.impound == 1 then
            if vehicleData.impound_retrievable == true or vehicleData.impound_retrievable == 1 then
                local impoundInfo = json.decode(vehicleData.impound_data or "{}")
                local retrievalDate = impoundInfo.retrieval_date
                local retrievalCost = impoundInfo.retrieval_cost or 0
                
                if retrievalCost > 0 then
                    local paymentSuccess = Framework.Server.PlayerRemoveMoney(source, retrievalCost, "bank")
                    if not paymentSuccess then
                        return false
                    end
                    
                    if Config.ImpoundFeesSocietyFund then
                        Framework.Server.PayIntoSocietyFund(Config.ImpoundFeesSocietyFund, retrievalCost)
                    end
                end
            end
        end
    end
    
    if spawnVehicle then
        if impoundData then
            if impoundData.coords then
                local maxDistance = impoundData.distance or 15.0
                local playerCoords = GetEntityCoords(GetPlayerPed(source))
                local distance = #(playerCoords - impoundData.coords.xyz)
                
                if distance > maxDistance then
                    Framework.Server.Notify(source, "You are too far away from the impound", "error")
                    return false
                end
            end
        end
        
        spawnCoords = findVehicleSpawnCoords(impoundData.spawn)
        
        if not spawnCoords then
            Framework.Server.Notify(source, "Impound location is missing/has no valid spawn coords", "error")
            print("^1[ERROR] Impound is missing/has no valid spawn coords", impoundId)
            return false
        end
        
        if Config.SpawnVehiclesWithServerSetter then
            local warpIntoVehicle = not Config.DoNotSpawnInsideVehicle
            vehicleEntity, netId = spawnVehicleServer(
                source,
                vehicleData.id or 0,
                vehicleData.model,
                plate,
                spawnCoords,
                warpIntoVehicle,
                vehicleDataToSpawn,
                "personal"
            )
            
            if not vehicleEntity or not netId then
                Framework.Server.Notify(source, "Could not spawn vehicle - vehicle was not not removed from impound", "error")
                return false
            end
            
            Globals.OutsideVehicles[plate] = netId
        end
    end
    
    MySQL.update.await(
        Framework.Queries.ImpoundReturnToGarage:format(Framework.VehiclesTable),
        {garageId, spawnVehicle and 0 or 1, plate}
    )
    
    if not spawnVehicle then
        Framework.Server.Notify(source, Locale.vehicleImpoundReturnedToOwnerSuccess, "success")
    end
    
    return true, vehicleEntity, vehicleData, vehicleDataToSpawn, spawnCoords
end)

lib.addCommand(Config.ImpoundCommand, {
    help = "Impound a vehicle",
    restricted = false
}, function(source, args, raw)
    debugPrint("Impound command triggered by player", "debug", source)
    TriggerClientEvent("jg-advancedgarages:client:show-impound-form", source)
end)

exports("impoundVehicle", function(...)
    return impoundVehicle(...)
end)
