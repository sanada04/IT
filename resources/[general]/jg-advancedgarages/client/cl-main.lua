function deleteVehicle(vehicle)
    local advancedParkingState = GetResourceState("AdvancedParking")
    if advancedParkingState == "started" then
        exports.AdvancedParking:DeleteVehicle(vehicle, false)
    else
        DeleteEntity(vehicle)
    end
end
function getModelNameFromHash(modelHash)
    local displayName = GetDisplayNameFromVehicleModel(modelHash)
    local labelText = GetLabelText(displayName)
    local lowerLabelText = labelText:lower()
    local modelName = lowerLabelText
    
    if not IsModelInCdimage(lowerLabelText) or not lowerLabelText then
        modelName = displayName:lower()
    end
    
    return modelName
end
function createPedForTarget(coords)
    lib.requestModel(Config.TargetPed)
    
    local pedHash = joaat(Config.TargetPed)
    local pedType = GetPedType(pedHash)
    local heading = coords.w or 0
    
    local ped = CreatePed(pedType, pedHash, coords.x, coords.y, coords.z, heading, false, false)
    
    lib.waitFor(function()
        if not DoesEntityExist(ped) then
            return nil
        end
        return true
    end)
    
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)
    FreezeEntityPosition(ped, true)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, false)
    SetPedCanRagdoll(ped, false)
    SetEntityProofs(ped, true, true, true, true, true, true, true, true)
    SetModelAsNoLongerNeeded(Config.TargetPed)
    
    return ped
end
function getVehicleType(model)
    local modelHash = convertModelToHash(model)
    local vehicleClass = GetVehicleClassFromName(modelHash)
    local vehicleType = "car"
    
    if IsThisModelABoat(modelHash) then
        vehicleType = "sea"
    elseif IsThisModelAHeli(modelHash) then
        vehicleType = "air"
    elseif IsThisModelAPlane(modelHash) then
        vehicleType = "air"
    elseif vehicleClass == 14 then
        vehicleType = "sea"
    elseif vehicleClass == 16 then
        vehicleType = "air"
    end
    
    return vehicleType
end
function filterVehiclesByType(vehicles, vehicleType)
    local filteredVehicles = {}
    
    for _, vehicle in ipairs(vehicles) do
        local currentVehicleType = getVehicleType(vehicle.hash)
        if currentVehicleType == vehicleType then
            filteredVehicles[#filteredVehicles + 1] = vehicle
        end
    end
    
    return filteredVehicles
end
function getVehicleDamage(vehicle)
    if not vehicle or vehicle == 0 then
        return false
    end
    
    local bodyHealth = 1000
    local engineHealth = 1000
    local deformation = nil
    
    if Config.SaveVehicleDamage then
        bodyHealth = math.ceil(GetVehicleBodyHealth(vehicle))
        if not bodyHealth or type(bodyHealth) ~= "number" or bodyHealth < 0 then
            bodyHealth = 0
        end
        
        engineHealth = math.ceil(GetVehicleEngineHealth(vehicle))
        if not engineHealth or type(engineHealth) ~= "number" or engineHealth < 0 then
            engineHealth = 0
        end
        
        if Config.AdvancedVehicleDamage then
            deformation = getVehicleDeformation(vehicle)
        end
    end
    
    return bodyHealth, engineHealth, deformation
end
RegisterNUICallback("close", function(data, callback)
    SetNuiFocus(false, false)
    callback(true)
end)
