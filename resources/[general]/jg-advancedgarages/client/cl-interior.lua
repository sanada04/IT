local CAMERA_FOV = 40.0
local INTERACTION_DISTANCE = 3.0
local interiorCameras = {}
local spawnedVehicles = {}
local isInInterior = false
local interiorPoints = {}
local previousCoords = nil
local cameraActive = false
local currentGarageType = nil
local function destroyInteriorCameras()
    if not #interiorCameras then
        return
    end
    
    for _, camera in ipairs(interiorCameras) do
        DestroyCam(camera, true)
    end
    
    RenderScriptCams(false, true, 1000, true, true)
    cameraActive = false
end
local function startInteriorCameraCutscene()
    if not Config.GarageInteriorCameraCutscene then
        return
    end
    
    local startPos = Config.GarageInteriorCameraCutscene[1]
    local endPos = Config.GarageInteriorCameraCutscene[2]
    
    local cameras = {
        CreateCamWithParams(
            "DEFAULT_SCRIPTED_CAMERA",
            startPos.x, startPos.y, startPos.z,
            0.0, 0.0, startPos.w,
            CAMERA_FOV, true, 2
        ),
        CreateCamWithParams(
            "DEFAULT_SCRIPTED_CAMERA",
            endPos.x, endPos.y, endPos.z,
            0.0, 0.0, endPos.w,
            CAMERA_FOV, true, 2
        )
    }
    
    interiorCameras = cameras
    cameraActive = true
    
    SetCamActive(interiorCameras[1], true)
    RenderScriptCams(true, false, 0, true, true)
    SetCamActiveWithInterp(interiorCameras[2], interiorCameras[1], 3000, 0, 0)
    Wait(3000)
    destroyInteriorCameras()
end
local function exitInterior(callback)
    isInInterior = false
    currentGarageType = nil
    
    SendNUIMessage({ type = "hide" })
    DoScreenFadeOut(500)
    Wait(500)
    for _, vehicleData in ipairs(spawnedVehicles) do
        if vehicleData.vehicle then
            DeleteEntity(vehicleData.vehicle)
        end
    end
    spawnedVehicles = {}
    
    for _, point in ipairs(interiorPoints) do
        point:remove()
    end
    interiorPoints = {}
    Framework.Client.HideTextUI()
    
    if previousCoords then
        SetEntityCoords(cache.ped, previousCoords.x, previousCoords.y, previousCoords.z, false, false, false, false)
        previousCoords = nil
    end
    
    lib.callback.await("jg-advancedgarages:server:exit-interior")
    
    if callback then
        callback()
    end
    
    Wait(500)
    DoScreenFadeIn(500)
end
local function setupInteriorExitPoint(garageId)
    local exitPoint = lib.points.new({
        coords = Config.GarageInteriorEntrance,
        distance = INTERACTION_DISTANCE
    })
    function exitPoint.onEnter(self)
        local currentVehicle = cache.vehicle
        
        if not currentVehicle then
            Framework.Client.ShowTextUI(Config.ExitInteriorPrompt)
        else
            local vehicleModel = GetEntityModel(currentVehicle)
            local vehiclePlate = Framework.Client.GetPlate(currentVehicle)
            
            if not vehicleModel or not vehiclePlate then
                return
            end
            CreateThread(function()
                while currentVehicle == cache.vehicle do
                    SetVehicleForwardSpeed(currentVehicle, 0)
                    Wait(0)
                end
            end)
            local spawnerIndex = nil
            for _, vehicleData in ipairs(spawnedVehicles) do
                if vehicleData.vehicle == currentVehicle then
                    spawnerIndex = vehicleData.spawnerIndex
                    break
                end
            end
            
            exitInterior(function()
                driveVehicleOut(vehiclePlate, garageId, spawnerIndex, nil)
            end)
        end
    end
    function exitPoint.onExit(self)
        Framework.Client.HideTextUI()
    end
    function exitPoint.nearby(self)
        if cameraActive then
            if IsControlJustPressed(0, Config.ExitInteriorKeyBind) then
                destroyInteriorCameras()
            end
        end
        
        if not cache.vehicle then
            if IsControlJustPressed(0, Config.ExitInteriorKeyBind) then
                if not cameraActive then
                    exitInterior()
                end
            end
        end
    end
    table.insert(interiorPoints, exitPoint)
    
    local markerPoint = lib.points.new({
        coords = Config.GarageInteriorEntrance,
        distance = 20.0
    })
    function markerPoint.nearby(self)
        drawMarkerOnFrame(Config.GarageInteriorEntrance, {
            id = 21,
            size = { x = 0.3, y = 0.3, z = 0.3 },
            color = { r = 255, g = 255, b = 255, a = 120 },
            bobUpAndDown = 0,
            faceCamera = 0,
            rotate = 1,
            drawOnEnts = 0
        })
    end
    
    table.insert(interiorPoints, markerPoint)
end
local function enterInterior(garageId, vehicles)
    if Config.Debug then
        print(string.format("^2[DEBUG] enterInterior called - Garage: %s, Vehicles: %d", garageId, vehicles and #vehicles or 0))
    end
    
    isInInterior = true
    
    local garageLocations = getAvailableGarageLocations()
    local garageData = garageLocations and garageLocations[garageId]
    
    if not garageData then
        if Config.Debug then
            print("^3[WARNING] Garage data not found, using defaults")
        end
        garageData = {
            garageType = "personal",
            checkVehicleGarageId = Config.GarageUniqueLocations,
            enableInteriors = Config.PrivGarageEnableInteriors
        }
    end
    
    currentGarageType = garageData.garageType
    local availableVehicles = {}
    
    for _, vehicle in ipairs(vehicles) do
        if Config.Debug then
            print(string.format("^2[DEBUG] Checking vehicle: %s", vehicle.plate or "unknown"))
            print(string.format("  - Hash: %s, InGarage: %s, Impound: %s, IsSpawned: %s, GarageId: %s", 
                tostring(vehicle.hash), 
                tostring(vehicle.inGarage), 
                tostring(vehicle.impound), 
                tostring(vehicle.isSpawned),
                tostring(vehicle.garageId)))
        end
        
        local modelInCdimage = IsModelInCdimage(vehicle.hash)
        if Config.Debug then
            print(string.format("  - Model in CDimage: %s", tostring(modelInCdimage)))
            print(string.format("  - Check garage ID: %s (vehicle: %s, target: %s)", 
                tostring(garageData.checkVehicleGarageId), 
                tostring(vehicle.garageId), 
                tostring(garageId)))
        end
        
        if modelInCdimage then
            local garageIdMatch = not garageData.checkVehicleGarageId or vehicle.garageId == garageId
            local notImpounded = not vehicle.impound or vehicle.impound == 0 or vehicle.impound == false
            local isInGarage = vehicle.inGarage == true or vehicle.inGarage == 1
            local notSpawned = not vehicle.isSpawned
            
            if Config.Debug then
                print(string.format("  - Garage ID match: %s", tostring(garageIdMatch)))
                print(string.format("  - Not impounded: %s", tostring(notImpounded)))
                print(string.format("  - Is in garage: %s", tostring(isInGarage)))
                print(string.format("  - Not spawned: %s", tostring(notSpawned)))
            end
            
            if garageIdMatch and notImpounded and isInGarage and notSpawned then
                table.insert(availableVehicles, vehicle)
                if Config.Debug then
                    print(string.format("^2[DEBUG] Vehicle %s added to available list", vehicle.plate))
                end
            else
                if Config.Debug then
                    print(string.format("^3[DEBUG] Vehicle %s not added (failed checks)", vehicle.plate))
                end
            end
        else
            if Config.Debug then
                print(string.format("^1[WARNING] Model not in CDimage: %s", tostring(vehicle.hash)))
            end
        end
    end
    
    if Config.Debug then
        print(string.format("^2[DEBUG] Total available vehicles: %d", #availableVehicles))
    end
    
    if #availableVehicles == 0 then
        Framework.Client.Notify(Locale.noVehiclesAvailableToDrive, "error")
        exitInterior()
        return
    end
    CreateThread(function()
        DoScreenFadeOut(500)
        Wait(500)
        
        -- Store all vehicle plates for key giving
        local allInteriorVehicles = {}
        
        for index, position in ipairs(Config.GarageInteriorVehiclePositions) do
            local vehicleData = availableVehicles[index]
            if not vehicleData then
                break
            end
            
            local spawnedVehicle = createClientVehicle(vehicleData.hash, position, vehicleData.plate, false)
            
            -- Apply all vehicle data including damage states
            if spawnedVehicle and spawnedVehicle ~= 0 then
                -- Ensure plate is set correctly
                if vehicleData.plate and vehicleData.plate ~= "" then
                    SetVehicleNumberPlateText(spawnedVehicle, vehicleData.plate)
                end
                
                -- Create a complete vehicle data object with all stats
                local completeVehicleData = {
                    props = vehicleData.props,
                    fuel = tonumber(vehicleData.fuel) or 100.0,
                    engine = vehicleData.engine or vehicleData.engineHealth,
                    body = vehicleData.body or vehicleData.bodyHealth,
                    engineHealth = vehicleData.engine or vehicleData.engineHealth,
                    bodyHealth = vehicleData.body or vehicleData.bodyHealth,
                    damage = vehicleData.damage,
                    deformation = vehicleData.deformation
                }
                
                -- Apply all vehicle data including damage
                applyVehicleData(spawnedVehicle, completeVehicleData)
                
                -- Store vehicle info for key giving
                table.insert(allInteriorVehicles, {
                    vehicle = spawnedVehicle,
                    plate = vehicleData.plate
                })
                
                -- Fully unlock the vehicle and ensure engine can start
                SetVehicleDoorsLocked(spawnedVehicle, 0) -- 0 = fully unlocked
                SetVehicleNeedsToBeHotwired(spawnedVehicle, false)
                SetVehicleEngineOn(spawnedVehicle, true, true, false)
                
                if Config.Debug then
                    print(string.format("^2[DEBUG] Interior vehicle spawned - Plate: %s, Hash: %s", 
                        vehicleData.plate or "unknown", vehicleData.hash))
                end
            end
            
            table.insert(spawnedVehicles, {
                vehicle = spawnedVehicle,
                spawnerIndex = vehicleData.spawnerIndex
            })
        end
        
        -- Give keys for ALL vehicles in the interior after spawning them
        Wait(100) -- Small delay to ensure all vehicles are properly spawned
        local keysGivenCount = 0
        for _, vehData in ipairs(allInteriorVehicles) do
            if vehData.vehicle and DoesEntityExist(vehData.vehicle) and vehData.plate then
                Framework.Client.VehicleGiveKeys(vehData.plate, vehData.vehicle, currentGarageType or "personal")
                -- Ensure vehicle stays unlocked
                SetVehicleDoorsLocked(vehData.vehicle, 0)
                SetVehicleNeedsToBeHotwired(vehData.vehicle, false)
                keysGivenCount = keysGivenCount + 1
            end
        end
        
        -- Notify player they have keys for all vehicles
        if keysGivenCount > 0 then
            Framework.Client.Notify(string.format("Keys received for %d vehicle%s", keysGivenCount, keysGivenCount > 1 and "s" or ""), "success")
        end
        
        -- Keep all vehicles unlocked while in interior
        CreateThread(function()
            while isInInterior do
                for _, vehData in ipairs(allInteriorVehicles) do
                    if vehData.vehicle and DoesEntityExist(vehData.vehicle) then
                        if GetVehicleDoorLockStatus(vehData.vehicle) ~= 0 then
                            SetVehicleDoorsLocked(vehData.vehicle, 0)
                            SetVehicleNeedsToBeHotwired(vehData.vehicle, false)
                        end
                    end
                end
                Wait(500) -- Check every half second
            end
        end)
        
        previousCoords = GetEntityCoords(cache.ped)
        
        SetEntityCoords(
            cache.ped,
            Config.GarageInteriorEntrance.x,
            Config.GarageInteriorEntrance.y,
            Config.GarageInteriorEntrance.z,
            false, false, false, false
        )
        
        SetEntityHeading(cache.ped, Config.GarageInteriorEntrance.w)
        
        setupInteriorExitPoint(garageId)
        
        DoScreenFadeIn(500)
        startInteriorCameraCutscene()
    end)
end
lib.onCache("vehicle", function(vehicle)
    if not isInInterior then
        return
    end
    
    if not vehicle or vehicle == 0 then
        SendNUIMessage({ type = "hide" })
        return
    end
    
    -- Small delay to ensure vehicle is fully loaded
    Wait(100)
    
    local plate = Framework.Client.GetPlate(vehicle)
    if not plate or plate == "" then
        -- Try again with a delay
        Wait(500)
        plate = Framework.Client.GetPlate(vehicle)
        if not plate or plate == "" then
            if Config.Debug then
                print("^1[ERROR] Could not get plate for interior vehicle")
            end
            return
        end
    end
    
    -- Keys are already given when spawning the vehicle, just ensure doors are unlocked
    -- Keep vehicle fully unlocked in interior
    SetVehicleDoorsLocked(vehicle, 0) -- 0 = fully unlocked
    SetVehicleNeedsToBeHotwired(vehicle, false)
    
    -- Ensure engine can be started
    SetVehicleEngineOn(vehicle, true, true, false)
    local vehicleData = lib.callback.await("jg-advancedgarages:server:get-vehicle", false, plate)
    if not vehicleData then
        return false
    end
    
    vehicleData.model = type(vehicleData.model) == "string" and vehicleData.model or getModelNameFromHash(vehicleData.hash)
    vehicleData.vehicleLabel = Framework.Client.GetVehicleLabel(vehicleData.model)
    
    SendNUIMessage({
        type = "show-interior-vehicle",
        vehicle = vehicleData,
        config = Config,
        locale = Locale
    })
end)
RegisterNetEvent("jg-advancedgarages:client:enter-interior", enterInterior)

-- Debug command to test interior functionality
if Config.Debug then
    RegisterCommand("testgarageinterior", function(source, args)
        -- Join all args to handle garage names with spaces
        local garageId = table.concat(args, " ")
        if garageId == "" then
            garageId = "Legion Square"
        end
        
        print(string.format("^2[DEBUG] Testing interior for garage: %s", garageId))
        
        -- Refresh cache and get garage data
        local garageLocations = refreshGarageLocationsCache()
        local garageData = garageLocations[garageId]
        
        if not garageData then
            print("^1[ERROR] Garage not found: " .. garageId)
            print("^3[INFO] Available garages:")
            for garageName, _ in pairs(garageLocations) do
                print("  - " .. garageName)
            end
            return
        end
        
        print(string.format("^2[DEBUG] Garage Data:"))
        print(string.format("  - Type: %s", garageData.type or "unknown"))
        print(string.format("  - Enable Interiors: %s", tostring(garageData.enableInteriors)))
        print(string.format("  - Garage Type: %s", garageData.garageType or "unknown"))
        
        -- Fetch vehicles and try to enter interior
        local vehicles = fetchGarageVehicles(garageId, garageData.type or "car")
        
        if vehicles and #vehicles > 0 then
            print(string.format("^2[DEBUG] Found %d vehicles, attempting to enter interior", #vehicles))
            local result = lib.callback.await(
                "jg-advancedgarages:server:enter-interior", false,
                garageId, vehicles
            )
            
            if result then
                print("^2[SUCCESS] Interior entry initiated")
            else
                print("^1[ERROR] Failed to enter interior")
            end
        else
            print("^3[WARNING] No vehicles found in garage")
            print("^3[INFO] Make sure you have vehicles stored in this garage")
        end
    end, false)
    
    print("^2[DEBUG] Test command registered: /testgarageinterior [garageName]")
    print("^3[INFO] Example: /testgarageinterior Legion Square")
end
