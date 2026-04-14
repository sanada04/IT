-- Automatic key assignment for owned vehicles
local checkedVehicles = {}
local keysGiven = {} -- Track which vehicles we've already given keys for

-- Function to check if player owns the vehicle
local function isPlayerVehicle(plate)
    if not plate or plate == "" then
        return false
    end
    
    -- Check cache first
    if checkedVehicles[plate] ~= nil then
        return checkedVehicles[plate]
    end
    
    -- Query server for ownership
    local isOwned = lib.callback.await("jg-advancedgarages:server:check-vehicle-owner", false, plate)
    checkedVehicles[plate] = isOwned or false
    
    return isOwned
end

-- Monitor when player enters a vehicle
lib.onCache("vehicle", function(vehicle)
    if not vehicle or vehicle == 0 then
        -- Clear cache periodically when not in vehicle
        if next(checkedVehicles) then
            SetTimeout(60000, function()
                checkedVehicles = {}
                keysGiven = {}
            end)
        end
        return
    end
    
    -- Skip if we're in the interior (interior handles its own keys)
    if isInInterior then
        return
    end
    
    -- Get vehicle plate
    local plate = Framework.Client.GetPlate(vehicle)
    if not plate or plate == "" then
        return
    end
    
    -- Check if player is the driver
    if GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then
        return
    end
    
    -- Check if we've already given keys for this vehicle
    if keysGiven[plate] then
        return
    end
    
    -- Check if player owns this vehicle
    if isPlayerVehicle(plate) then
        -- Give keys automatically
        Framework.Client.VehicleGiveKeys(plate, vehicle, "personal")
        keysGiven[plate] = true
        
        if Config.Debug then
            print(string.format("^2[DEBUG] Auto-assigned keys for owned vehicle: %s", plate))
        end
        
        -- Keep vehicle unlocked and ensure engine can start
        SetVehicleDoorsLocked(vehicle, 0) -- 0 = fully unlocked
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true, false)
        
        -- Notify player only once
        Framework.Client.Notify("Keys received for your vehicle", "success")
    end
end)

-- Clear cache on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        checkedVehicles = {}
    end
end)
