function OnEnteredVehicle(vehicle)
    SendNUIMessage({
        type = "enteredVehicle",
        vehicleType = GetVehicleType(vehicle)
    })
    
    DisplayRadar(true)
end

function OnExitedVehicle()
    SendNUIMessage({
        type = "exitedVehicle"
    })
    
    if Config.ShowMinimapOnFoot then
        if UserSettingsData and UserSettingsData.showMinimapOnFoot then
            DisplayRadar(true)
        else
            DisplayRadar(false)
        end
    else
        DisplayRadar(false)
    end
end

local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning
local GetEntitySpeed = GetEntitySpeed
local GetVehicleCurrentGear = GetVehicleCurrentGear
local GetEntityVelocity = GetEntityVelocity
local GetEntityForwardVector = GetEntityForwardVector
local GetVehicleCurrentRpm = GetVehicleCurrentRpm
local GetEntityCoords = GetEntityCoords
local GetEntityRotation = GetEntityRotation
local GetVehicleLightsState = GetVehicleLightsState
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetLandingGearState = GetLandingGearState
local GetTrainDoorCount = GetTrainDoorCount
local GetTrainDoorOpenRatio = GetTrainDoorOpenRatio
local IsBoatAnchored = IsBoatAnchored
local GetEntityModel = GetEntityModel

function GetTelemetryUpdateInterval()
    local performanceMode = UserSettingsData and UserSettingsData.performanceMode
    
    if performanceMode == "ultra" then
        return 50
    elseif performanceMode == "performance" then
        return 75
    elseif performanceMode == "lowResmon" then
        return 150
    end
    
    return 100
end

local isTelemetryThreadRunning = false

function StartVehicleTelemetryThread(vehicle)
    local vehicleType = GetVehicleType(vehicle)
    local isElectric = (vehicleType == "land") and (IsVehicleElectric and IsVehicleElectric(vehicle) or false)
    local updateInterval = GetTelemetryUpdateInterval()
    
    CreateThread(function()
        if isTelemetryThreadRunning then
            return
        end
        
        isTelemetryThreadRunning = true
        
        while true do
            if not cache or not cache.vehicle or not IsHudRunning then
                break
            end
            
            local currentVehicle = cache.vehicle
            local isEngineOn = GetIsVehicleEngineRunning(currentVehicle)
            local speed = GetEntitySpeed(currentVehicle)
            local telemetryData = {}
            
            local convertedSpeed = Framework.Client.ConvertSpeed and Framework.Client.ConvertSpeed(speed, UserSettingsData and UserSettingsData.speedMeasurement) or speed
            telemetryData.speed = convertedSpeed
            telemetryData.isElectric = isElectric
            
            if vehicleType == "land" then
                local currentGear = GetVehicleCurrentGear(currentVehicle)
                local velocity = GetEntityVelocity(currentVehicle)
                local forwardVector = GetEntityForwardVector(currentVehicle)
                local dotProduct = velocity.x * forwardVector.x + velocity.y * forwardVector.y
                
                if currentGear == 0 then
                    currentGear = "N"
                else
                    if isElectric then
                        currentGear = "D"
                    end
                end
                
                if dotProduct < 0 then
                    currentGear = "R"
                end
                
                local isBraking = false
                if isElectric and dotProduct > 0 then
                    isBraking = IsControlPressed and IsControlPressed(0, 72) or false
                end
                
                local rpmData = {}
                if isEngineOn then
                    local rpm = math.floor(math.min(1.0, GetVehicleCurrentRpm(currentVehicle) - 0.05) * 8500)
                    rpmData.currentRpm = rpm
                else
                    rpmData.currentRpm = 0
                end
                rpmData.redline = 6000
                rpmData.maxRpm = 8000
                
                telemetryData.rpm = rpmData
                telemetryData.gear = currentGear
                telemetryData.isBraking = isBraking
                
            elseif vehicleType == "bicycle" then
                local coords = GetEntityCoords(currentVehicle)
                local altitude = Framework.Client.ConvertDistance and Framework.Client.ConvertDistance(coords.z, UserSettingsData and UserSettingsData.distanceMeasurement) or coords.z
                telemetryData.altitude = altitude
                
            elseif vehicleType == "sea" then
                local currentGear = GetVehicleCurrentGear(currentVehicle)
                local velocity = GetEntityVelocity(currentVehicle)
                local forwardVector = GetEntityForwardVector(currentVehicle)
                local dotProduct = velocity.x * forwardVector.x + velocity.y * forwardVector.y
                
                if currentGear == 0 then
                    currentGear = "N"
                else
                    currentGear = "D"
                end
                
                if dotProduct < 0 then
                    currentGear = "R"
                end
                
                telemetryData.gear = currentGear
                
            elseif vehicleType == "air" then
                local coords = GetEntityCoords(currentVehicle)
                local altitude = Framework.Client.ConvertDistance and Framework.Client.ConvertDistance(coords.z, UserSettingsData and UserSettingsData.distanceMeasurement) or coords.z
                local rotation = GetEntityRotation(currentVehicle, 0)
                local heading = GetEntityHeading and GetEntityHeading(currentVehicle) or 0
                
                telemetryData.altitude = altitude
                telemetryData.rotation = rotation
                telemetryData.heading = heading
            end
            
            SendNUIMessage({
                type = "vehicleTelemetryData",
                data = telemetryData
            })
            
            Wait(updateInterval)
        end
        
        isTelemetryThreadRunning = false
    end)
end

function GetStatusUpdateInterval()
    local performanceMode = UserSettingsData and UserSettingsData.performanceMode
    
    if performanceMode == "ultra" then
        return 100
    elseif performanceMode == "performance" then
        return 200
    elseif performanceMode == "lowResmon" then
        return 700
    end
    
    return 300
end

function SendVehicleStatusUpdate(statusData)
    SendNUIMessage({
        type = "vehicleStatusUpdate",
        data = statusData
    })
end

local isStatusThreadRunning = false

function StartVehicleStatusThread(vehicle)
    local vehicleType = GetVehicleType(vehicle)
    local updateInterval = GetStatusUpdateInterval()
    
    CreateThread(function()
        if isStatusThreadRunning then
            return
        end
        
        isStatusThreadRunning = true
        
        while true do
            if not cache.vehicle or not IsHudRunning then
                break
            end
            
            local currentVehicle = cache.vehicle
            local isEngineOn = GetIsVehicleEngineRunning(currentVehicle)
            local lightsState, highBeamsOn = GetVehicleLightsState(currentVehicle)
            
            local engineHealth = 0
            if isEngineOn then
                engineHealth = (GetVehicleEngineHealth(currentVehicle) / 1000) * 100
            end
            
            local isAirVehicle = (vehicleType == "air")
            local fuel = Framework.Client.VehicleGetFuel(currentVehicle)
            local mileageKm = Framework.Client.GetVehicleMileageInKm(currentVehicle)
            
            local mileage = false
            if mileageKm then
                local convertedMileage = mileageKm
                if UserSettingsData and UserSettingsData.speedMeasurement == "mph" then
                    convertedMileage = Framework.Client.ConvertKmToMiles and Framework.Client.ConvertKmToMiles(mileageKm) or mileageKm
                end
                mileage = math.floor(convertedMileage)
            end
            
            local doorsOpen = false
            if vehicleType == "train" then
                for doorIndex = 0, GetTrainDoorCount(currentVehicle) - 1 do
                    if GetTrainDoorOpenRatio(currentVehicle, doorIndex) > 0.1 then
                        doorsOpen = true
                        break
                    end
                end
            end
            
            local isMetroTrain = false
            if vehicleType == "train" or GetEntityModel(currentVehicle) == 868868440 then
                isMetroTrain = true
            end
            
            SendVehicleStatusUpdate({
                engineOn = isEngineOn,
                headlights = lightsState,
                highBeams = highBeamsOn,
                anchored = IsBoatAnchored(currentVehicle),
                engineHealth = engineHealth,
                fuel = fuel,
                indicators = GetIndicatingState(currentVehicle),
                gear = isAirVehicle,
                isMetroTrain = isMetroTrain,
                doorsOpen = doorsOpen,
                cruiseControl = IsCruiseControlEnabled,
                seatbelt = IsSeatbeltOn,
                mileage = mileage or false
            })
            
            Wait(updateInterval)
        end
        
        isStatusThreadRunning = false
    end)
end

function HandleVehicleChange(vehicle)
    if not vehicle or vehicle == 0 then
        OnExitedVehicle()
        return
    end
    
    StartVehicleStatusThread(vehicle)
    Wait(100)
    OnEnteredVehicle(vehicle)
    StartVehicleTelemetryThread(vehicle)
end

lib.onCache("vehicle", HandleVehicleChange)

function CheckVehicleOnLoad()
    if cache.vehicle then
        HandleVehicleChange(cache.vehicle)
    end
end

CreateThread(function()
    while true do
        if cache and cache.vehicle and IsHudRunning then
            if DisplayRadarConditionally then
                DisplayRadarConditionally()
            else
                DisplayRadar(true)
            end
        end
        Wait(100)
    end
end)