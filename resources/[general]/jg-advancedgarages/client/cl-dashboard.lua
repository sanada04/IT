-- Vehicle dashboard health display sync
local lastVehicle = nil
local updateInterval = 250 -- Update 4 times per second for more precision
local lastStats = {}

CreateThread(function()
    while true do
        local sleep = 1000
        
        if cache.vehicle and cache.vehicle ~= 0 then
            local vehicle = cache.vehicle
            
            -- Get current vehicle stats with high precision
            local engineHealth = GetVehicleEngineHealth(vehicle) + 0.0 -- Force float
            local bodyHealth = GetVehicleBodyHealth(vehicle) + 0.0 -- Force float
            local fuelLevel = Framework.Client.VehicleGetFuel(vehicle) or 0.0
            
            -- Ensure values are within valid ranges
            engineHealth = math.max(0.0, math.min(1000.0, engineHealth))
            bodyHealth = math.max(0.0, math.min(1000.0, bodyHealth))
            fuelLevel = math.max(0.0, math.min(100.0, fuelLevel))
            
            -- Convert to percentages with 2 decimal precision
            local enginePercent = math.floor((engineHealth / 1000.0) * 10000) / 100 -- 2 decimal places
            local bodyPercent = math.floor((bodyHealth / 1000.0) * 10000) / 100 -- 2 decimal places
            local fuelPercent = math.floor(fuelLevel * 100) / 100 -- 2 decimal places
            
            -- Only update if values have changed significantly (0.1% difference)
            local hasChanged = false
            if not lastStats.engine or math.abs(lastStats.engine - engineHealth) > 1.0 or
               not lastStats.body or math.abs(lastStats.body - bodyHealth) > 1.0 or
               not lastStats.fuel or math.abs(lastStats.fuel - fuelLevel) > 0.1 then
                hasChanged = true
                lastStats = {
                    engine = engineHealth,
                    body = bodyHealth,
                    fuel = fuelLevel
                }
            end
            
            -- Send to UI/HUD if values changed
            if hasChanged and Config.UpdateDashboard then
                SendNUIMessage({
                    type = "updateVehicleStats",
                    engineHealth = enginePercent,
                    engineHealthRaw = engineHealth,
                    bodyHealth = bodyPercent,
                    bodyHealthRaw = bodyHealth,
                    fuel = fuelPercent,
                    fuelRaw = fuelLevel
                })
            end
            
            -- Trigger event for other resources that might need this info
            if hasChanged then
                TriggerEvent("jg-advancedgarages:client:vehicleStatsUpdate", {
                    engine = engineHealth,
                    body = bodyHealth,
                    fuel = fuelLevel,
                    enginePercent = enginePercent,
                    bodyPercent = bodyPercent,
                    fuelPercent = fuelPercent
                })
            end
            
            if Config.Debug and (vehicle ~= lastVehicle or hasChanged) then
                print(string.format("^2[DEBUG] Vehicle Stats - Engine: %.2f%% (%.1f), Body: %.2f%% (%.1f), Fuel: %.2f%%", 
                    enginePercent, engineHealth, bodyPercent, bodyHealth, fuelPercent))
                if vehicle ~= lastVehicle then
                    lastVehicle = vehicle
                end
            end
            
            sleep = updateInterval
        else
            lastVehicle = nil
        end
        
        Wait(sleep)
    end
end)

-- Export function for other resources to get current vehicle stats
function GetCurrentVehicleStats()
    if not cache.vehicle or cache.vehicle == 0 then
        return nil
    end
    
    local vehicle = cache.vehicle
    
    -- Get precise values
    local engineHealth = GetVehicleEngineHealth(vehicle) + 0.0
    local bodyHealth = GetVehicleBodyHealth(vehicle) + 0.0
    local fuelLevel = Framework.Client.VehicleGetFuel(vehicle) or 0.0
    
    -- Clamp values
    engineHealth = math.max(0.0, math.min(1000.0, engineHealth))
    bodyHealth = math.max(0.0, math.min(1000.0, bodyHealth))
    fuelLevel = math.max(0.0, math.min(100.0, fuelLevel))
    
    -- Calculate precise percentages
    local enginePercent = math.floor((engineHealth / 1000.0) * 10000) / 100
    local bodyPercent = math.floor((bodyHealth / 1000.0) * 10000) / 100
    local fuelPercent = math.floor(fuelLevel * 100) / 100
    
    return {
        engine = engineHealth,
        body = bodyHealth,
        fuel = fuelLevel,
        enginePercent = enginePercent,
        bodyPercent = bodyPercent,
        fuelPercent = fuelPercent,
        -- Additional formatted strings for display
        engineDisplay = string.format("%.1f%%", enginePercent),
        bodyDisplay = string.format("%.1f%%", bodyPercent),
        fuelDisplay = string.format("%.1f%%", fuelPercent)
    }
end

exports("GetCurrentVehicleStats", GetCurrentVehicleStats)
