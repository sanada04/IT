local function checkVehicleNeedsServicing(vehicleProps)
    if not vehicleProps then
        return false
    end
    
    if GetResourceState("jg-mechanic") ~= "started" then
        return false
    end
    
    if not Globals.MechanicConfig then
        local success = pcall(function()
            Globals.MechanicConfig = exports["jg-mechanic"]:config()
        end)
        
        if not success then
            print("^3[WARNING] You are running jg-mechanic, but you need to be using v1.0.10 or newer to use it with Advanced Garages v3. Some functionality may not work as expected.")
        end
    end
    
    if not (Globals.MechanicConfig and Globals.MechanicConfig.EnableVehicleServicing) then
        return false
    end
    
    local servicingData = vehicleProps.servicingData
    
    if not servicingData or type(servicingData) ~= "table" then
        return false
    end
    
    for _, value in pairs(servicingData) do
        if value <= Globals.MechanicConfig.ServiceRequiredThreshold then
            return true
        end
    end
    
    return false
end

doesVehicleNeedServicing = checkVehicleNeedsServicing

local function checkVehicleTransferBlacklisted(model)
    if not Config.PlayerTransferBlacklist then
        return false
    end
    
    local modelHash = convertModelToHash(model)
    
    for _, blacklistedModel in pairs(Config.PlayerTransferBlacklist) do
        if modelHash == joaat(blacklistedModel) then
            return true
        end
    end
    
    return false
end

isVehicleTransferBlacklisted = checkVehicleTransferBlacklisted

local function checkVehicleSpawned(plate)
    if not plate or plate == "" then
        return false
    end
    
    if GetResourceState("AdvancedParking") == "started" then
        if exports.AdvancedParking:GetVehiclePosition(plate) then
            return true
        end
    end
    
    local netId = Globals.OutsideVehicles[plate]
    
    if not netId then
        return false
    end
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    
    if DoesEntityExist(vehicle) and GetVehicleEngineHealth(vehicle) > 0 then
        return true
    end
    
    return false
end

isVehicleSpawned = checkVehicleSpawned

local function despawnVehicleByPlate(plate)
    local netId = Globals.OutsideVehicles[plate]
    
    if not netId then
        return
    end
    
    deleteVehicle(NetworkGetEntityFromNetworkId(netId), netId, plate)
end

local function registerVehicleOutside(plate, netId)
    Globals.OutsideVehicles[plate] = netId
end

local function updateVehiclePlate(source, oldPlate, newPlate)
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    
    if not vehicle then
        Framework.Server.Notify(source, Locale.notInsideVehicleError, "error")
        return false
    end
    
    if Framework.Server.GetPlate(vehicle) ~= oldPlate then
        debugPrint("Framework.Server.GetPlate does not match with original plate", "warning", Framework.Server.GetPlate(vehicle), oldPlate)
        return false
    end
    
    local plateExists = MySQL.scalar.await(
        Framework.Queries.GetVehiclePlateOnly:format(Framework.VehiclesTable),
        {newPlate}
    )
    
    if plateExists then
        Framework.Server.Notify(source, Locale.vehiclePlateExistsError, "error")
        return false
    end
    
    local vehicleData = getVehicleData(source, oldPlate)
    
    if not vehicleData then
        print("^1Error: could not get vehicle data before plate change")
        return false
    end
    
    local vehicleProps = vehicleData[Framework.VehProps] and json.decode(vehicleData[Framework.VehProps])
    
    if not vehicleProps then
        print("^1Error: could not get props before plate change")
        return false
    end
    
    vehicleProps.plate = newPlate
    
    MySQL.update.await(
        Framework.Queries.UpdateVehiclePlate:format(Framework.VehiclesTable, Framework.VehProps),
        {newPlate, json.encode(vehicleProps), oldPlate}
    )
    
    if GetResourceState("jg-mechanic") == "started" then
        local success = pcall(function()
            exports["jg-mechanic"]:vehiclePlateUpdated(oldPlate, newPlate)
        end)
        
        if not success then
            print("^1[WARNING] Update jg-mechanic to v1.0.11 or newer as it needs to update internal data to the updated plate!")
        end
    end
    
    Framework.Server.Notify(source, string.gsub(Locale.vehiclePlateUpdateSuccess, "%%{value}", newPlate), "success")
    return true
end

local function deleteVehicleFromDatabase(source)
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    
    if not vehicle then
        Framework.Server.Notify(source, Locale.notInsideVehicleError, "error")
        return
    end
    
    local plate = Framework.Server.GetPlate(vehicle)
    
    if not plate then
        return
    end
    
    local vehicleData = getVehicleData(source, plate)
    
    if not vehicleData then
        Framework.Server.Notify(source, Locale.vehicleNotOwnedByPlayerError, "error")
        return
    end
    
    MySQL.query.await(
        Framework.Queries.DeleteVehicle:format(Framework.VehiclesTable),
        {plate}
    )
    
    deleteVehicle(vehicle)
    
    Framework.Server.Notify(source, string.gsub(Locale.vehicleDeletedSuccess, "%%{value}", plate), "success")
end

local function returnVehicleToGarage(source, plate)
    plate = plate:upper()
    
    if not plate or not getVehicleData(source, plate) then
        Framework.Server.Notify(source, Locale.vehicleNotOwnedByPlayerError, "error")
        return false
    end
    
    local netId = Globals.OutsideVehicles[plate]
    
    if not netId then
        Framework.Server.Notify(source, Locale.vehicleParkedSuccess, "error")
        return true
    end
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    deleteVehicle(vehicle)
    
    Globals.OutsideVehicles[plate] = nil
    
    MySQL.update.await(
        Framework.Queries.SetInGarage:format(Framework.VehiclesTable),
        {plate}
    )
    
    Framework.Server.Notify(source, Locale.vehicleImpoundReturnedToOwnerSuccess, "success")
end

RegisterNetEvent("jg-advancedgarages:server:register-vehicle-outside", registerVehicleOutside)
RegisterNetEvent("jg-advancedgarages:server:RegisterVehicleOutside", registerVehicleOutside)

lib.callback.register("jg-advancedgarages:server:vehicle-update-plate", function(source, oldPlate, newPlate)
    if not Framework.Server.IsAdmin(source) then
        debugPrint("Framework.Server.IsAdmin", "warning", "Returned false")
        return false
    end
    
    return updateVehiclePlate(source, oldPlate, newPlate)
end)

lib.addCommand(Config.ChangeVehiclePlate or "vplate", false, function(source)
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        return
    end
    
    TriggerClientEvent("jg-advancedgarages:client:show-vplate-form", source)
end)

lib.addCommand(Config.DeleteVehicleFromDB or "dvdb", {
    help = Locale.cmdDeleteVeh
}, function(source)
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        return
    end
    
    deleteVehicleFromDatabase(source)
end)

lib.addCommand(Config.ReturnVehicleToGarage or "vreturn", {
    help = "Return vehicle back to garage (admin only)",
    params = {}
}, function(source, args)
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        return
    end
    
    returnVehicleToGarage(source, table.concat(args, " "))
end)
