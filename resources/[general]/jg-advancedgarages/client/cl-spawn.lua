local function getVehicleTypeFromModel(modelHash)
    local vehicleClass = GetVehicleClassFromName(modelHash)
    local vehicleType = nil
    
    if IsThisModelACar(modelHash) then
        vehicleType = "automobile"
    elseif IsThisModelABicycle(modelHash) then
        vehicleType = "bike"
    elseif IsThisModelABike(modelHash) then
        vehicleType = "bike"
    elseif IsThisModelABoat(modelHash) then
        vehicleType = "boat"
    elseif IsThisModelAHeli(modelHash) then
        vehicleType = "heli"
    elseif IsThisModelAPlane(modelHash) then
        vehicleType = "plane"
    elseif IsThisModelAQuadbike(modelHash) then
        vehicleType = "automobile"
    elseif IsThisModelATrain(modelHash) then
        vehicleType = "train"
    elseif vehicleClass == 5 then
        vehicleType = "automobile"
    elseif vehicleClass == 14 then
        vehicleType = "submarine"
    elseif vehicleClass == 16 then
        vehicleType = "heli"
    else
        vehicleType = "trailer"
    end
    
    return vehicleType
end

function applyVehicleData(vehicle, vehicleData)
    if not vehicleData or type(vehicleData) ~= "table" then
        return false
    end
    
    -- Apply vehicle properties first
    if vehicleData.props and type(vehicleData.props) == "table" then
        Framework.Client.SetVehicleProperties(vehicle, vehicleData.props)
    end
    
    -- Apply vehicle stats - check for both naming conventions
    local engineHealth = vehicleData.engineHealth or vehicleData.engine or 1000.0
    local bodyHealth = vehicleData.bodyHealth or vehicleData.body or 1000.0
    local fuelLevel = vehicleData.fuel or 100.0
    
    -- Set the actual damage values - DO NOT fix the vehicle after this!
    SetVehicleEngineHealth(vehicle, engineHealth + 0.0) -- Ensure float
    SetVehicleBodyHealth(vehicle, bodyHealth + 0.0) -- Ensure float
    Framework.Client.VehicleSetFuel(vehicle, fuelLevel)
    
    -- Apply deformation if configured
    if Config.AdvancedVehicleDamage and vehicleData.deformation then
        setVehicleDeformation(vehicle, vehicleData.deformation)
    end
    
    -- Apply other damage states
    if vehicleData.damage then
        setVehicleDamage(vehicle, vehicleData.damage)
    end
    
    -- Only fix the vehicle if it's meant to be in perfect condition
    if engineHealth >= 1000.0 and bodyHealth >= 1000.0 then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
    end
    
    -- Always ensure the engine can be started (but respect damage)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleModKit(vehicle, 0)
    
    -- Debug output
    if Config.Debug then
        print(string.format("^2[DEBUG] Applied vehicle stats - Engine: %.1f, Body: %.1f, Fuel: %.1f", 
            engineHealth, bodyHealth, fuelLevel))
    end
    
    local livery = vehicleData.livery
    if livery and type(livery) == "number" then
        SetVehicleMod(vehicle, 48, livery, false)
        SetVehicleLivery(vehicle, livery)
    end
    
    if vehicleData.extras and type(vehicleData.extras) == "table" then
        for extraIndex = 1, 14 do
            if DoesExtraExist(vehicle, extraIndex) then
                local extraState = isItemInList(vehicleData.extras, extraIndex) and 0 or 1
                SetVehicleExtra(vehicle, extraIndex, extraState)
                SetVehicleFixed(vehicle)
            end
        end
    end
    
    if vehicleData.clean then
        SetVehicleDirtLevel(vehicle, 0.0)
    end
    
    return not NetworkGetEntityIsNetworked(vehicle)
end

function getVehicleSpawnDetails(model)
    local modelHash = convertModelToHash(model)
    local vehicleType = getVehicleTypeFromModel(modelHash)
    local modelExists = IsModelInCdimage(modelHash)
    
    if not modelExists then
        Framework.Client.Notify("Vehicle model does not exist - contact an admin", "error")
        print(("^1Vehicle model %s does not exist"):format(model))
        return false
    end
    
    local hasSeats = GetVehicleModelNumberOfSeats(modelHash) > 0
    
    if plate and plate ~= "" then
        if not isValidGTAPlate(plate) then
            Framework.Client.Notify("This vehicle's plate is invalid (hit F8 for more details)", "error")
            print(("^1This vehicle is trying to spawn with the plate '%s' which is invalid for a GTA vehicle plate"):format(plate:upper()))
            print("^1Vehicle plates must be 8 characters long maximum, and can contain ONLY numbers, letters and spaces")
            return false
        end
    end
    
    lib.requestModel(modelHash, 60000)
    
    if IsPedRagdoll(cache.ped) then
        Framework.Client.Notify("You are currently in a ragdoll state", "error")
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end
    
    return modelHash, vehicleType, hasSeats
end

function finalizeVehicleSpawn(vehicle, vehicleId, warpIntoVehicle, plate, vehicleData, garageType)
    if not vehicle or vehicle == 0 then
        Framework.Client.Notify("Could not spawn vehicle - hit F8 for details", "error")
        print("^1Vehicle does not exist (vehicle = 0)")
        return false
    end
    
    if IsPedRagdoll(cache.ped) then
        Framework.Client.Notify("You are currently in a ragdoll state", "error")
        return false
    end
    
    if warpIntoVehicle then
        ClearPedTasks(cache.ped)
        local success = pcall(function()
            lib.waitFor(function()
                if GetPedInVehicleSeat(vehicle, -1) == cache.ped then
                    return true
                end
                TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
            end, nil, 5000)
        end)
        
        if not success then
            print("^1[ERROR] Could not warp you into the vehicle^0")
            return false
        end
    end
    
    if plate and plate ~= "" then
        SetVehicleNumberPlateText(vehicle, plate)
    end
    
    if vehicleData and type(vehicleData) == "table" then
        applyVehicleData(vehicle, vehicleData)
    end
    
    if GetResourceState("brazzers-fakeplates") == "started" then
        local fakePlate = lib.callback.await("brazzers-fakeplates:getFakePlateFromPlate", false, plate)
        if fakePlate then
            plate = fakePlate
            SetVehicleNumberPlateText(vehicle, fakePlate)
        end
    end
    
    if not plate or plate == "" then
        plate = Framework.Client.GetPlate(vehicle)
    end
    
    if not plate or plate == "" then
        print("^1[ERROR] The game thinks the vehicle has no plate - absolutely no idea how you've managed this")
        return false
    end
    
    local entityState = Entity(vehicle).state
    entityState:set("vehicleid", vehicleId, true)
    
    Framework.Client.VehicleGiveKeys(plate, vehicle, garageType)
    
    -- Ensure vehicle is unlocked and engine can start
    SetVehicleDoorsLocked(vehicle, 0) -- 0 = fully unlocked
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true, false)
    
    return true
end

function handleServerVehicleCreated(netId, playerCoords, warpIntoVehicle, modelHash, vehicleId, plate, vehicleData, garageType)
    SetModelAsNoLongerNeeded(modelHash)
    
    if not netId then
        Framework.Client.Notify("Could not spawn vehicle - hit F8 for details", "error")
        print("^1Server returned false for netId")
        return false
    end
    
    lib.waitFor(function()
        if NetworkDoesNetworkIdExist(netId) and NetworkDoesEntityExistWithNetworkId(netId) then
            return true
        end
    end, "Timed out while waiting for a server-setter netId to exist on client", 10000)
    
    local vehicle = NetToVeh(netId)
    
    lib.waitFor(function()
        if DoesEntityExist(vehicle) then
            return true
        end
    end, "Timed out while waiting for a server-setter vehicle to exist on client", 10000)
    
    if playerCoords then
        SetEntityCoords(cache.ped, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false, false)
    end
    
    local success = finalizeVehicleSpawn(vehicle, vehicleId, warpIntoVehicle, plate, vehicleData, garageType)
    if not success then
        DeleteEntity(vehicle)
        return false
    end
    
    return vehicle
end

function createClientVehicle(modelHash, coords, plate, isNetwork)
    lib.requestModel(modelHash, 60000)
    
    local x = coords.x or coords[1]
    local y = coords.y or coords[2]
    local z = coords.z or coords[3]
    local w = coords.w or coords[4] or 0.0
    
    local vehicle = CreateVehicle(modelHash, x, y, z, w, isNetwork or false, isNetwork or false)
    
    lib.waitFor(function()
        if DoesEntityExist(vehicle) then
            return true
        end
    end, "Timed out while trying to spawn in vehicle (client)", 10000)
    
    SetModelAsNoLongerNeeded(modelHash)
    
    if plate and plate ~= "" then
        SetVehicleNumberPlateText(vehicle, plate)
    end
    
    return vehicle
end

function spawnVehicleClient(vehicleId, model, plate, coords, warpIntoVehicle, vehicleData, garageType)
    if Config.SpawnVehiclesWithServerSetter then
        print("^1This function is disabled as server spawning is enabled")
        return false
    end
    
    local modelHash, vehicleType, hasSeats = getVehicleSpawnDetails(model)
    if not modelHash then
        return false
    end
    
    local vehicle = createClientVehicle(modelHash, coords, plate, true)
    if not vehicle then
        return false
    end
    
    local success = finalizeVehicleSpawn(vehicle, vehicleId, hasSeats and warpIntoVehicle, plate, vehicleData, garageType)
    if not success then
        DeleteEntity(vehicle)
        return false
    end
    
    return vehicle
end

AddStateBagChangeHandler("vehInit", "", function(bagName, key, value)
    if not value then
        return
    end
    
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then
        return
    end
    
    lib.waitFor(function()
        return not IsEntityWaitingForWorldCollision(entity)
    end)
    
    if NetworkGetEntityOwner(entity) ~= cache.playerId then
        return
    end
    
    local state = Entity(entity).state
    SetVehicleOnGroundProperly(entity)
    
    SetTimeout(0, function()
        state:set("vehInit", nil, true)
    end)
end)

AddStateBagChangeHandler("vehCreatedApplyProps", "", function(bagName, key, value)
    if not value then
        return
    end
    
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then
        return
    end
    
    SetTimeout(0, function()
        local state = Entity(entity).state
        local attempts = 0
        
        while attempts < 10 do
            if NetworkGetEntityOwner(entity) == cache.playerId then
                local success = applyVehicleData(entity, value)
                if success then
                    state:set("vehCreatedApplyProps", nil, true)
                    break
                end
            end
            attempts = attempts + 1
            Wait(100)
        end
    end)
end)

lib.callback.register("jg-advancedgarages:client:req-vehicle-and-get-spawn-details", getVehicleSpawnDetails)
lib.callback.register("jg-advancedgarages:client:on-server-vehicle-created", handleServerVehicleCreated)
