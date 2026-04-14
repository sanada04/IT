local previewCamera = nil
local previewVehicle = nil
local originalHeading = 0
local function showVehiclePlateForm()
    if not cache.vehicle then
        Framework.Client.Notify(Locale.notInsideVehicleError, "error")
        return false
    end
    
    local currentPlate = Framework.Client.GetPlate(cache.vehicle)
    local vehicleData = lib.callback.await("jg-advancedgarages:server:get-vehicle", false, currentPlate)
    
    if not vehicleData then
        return false
    end
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "show-vplate-form",
        plate = currentPlate,
        locale = Locale,
        config = Config
    })
end
local function changeVehiclePlate(newPlate)
    newPlate = newPlate:upper()
    
    if not cache.vehicle then
        Framework.Client.Notify(Locale.notInsideVehicleError, "error")
        return false
    end
    
    local currentPlate = Framework.Client.GetPlate(cache.vehicle)
    if not currentPlate then
        debugPrint("Framework.Client.GetPlate returned nil.", "warning", "Plate: " .. currentPlate)
        return false
    end
    local updateSuccess = lib.callback.await("jg-advancedgarages:server:vehicle-update-plate", false, currentPlate, newPlate)
    
    if not updateSuccess then
        debugPrint("jg-advancedgarages:server:vehicle-update-plate returned nil.", "warning", currentPlate, newPlate)
        return false
    end
    if GetResourceState("brazzers-fakeplates") == "started" then
        local fakePlate = lib.callback.await("brazzers-fakeplates:getFakePlateFromPlate", false, currentPlate)
        if fakePlate then
            currentPlate = fakePlate
        end
    end
    
    Framework.Client.VehicleRemoveKeys(currentPlate, cache.vehicle, "personal")
    setVehiclePlateText(cache.vehicle, newPlate)
    Framework.Client.VehicleGiveKeys(newPlate, cache.vehicle, "personal")
    
    return true
end
local function exitLiveriesExtrasMenu()
    if not previewVehicle or not DoesEntityExist(previewVehicle) then
        return false
    end
    
    SetEntityHeading(previewVehicle, originalHeading)
    SetEntityVisible(previewVehicle, true, false)
    FreezeEntityPosition(previewVehicle, false)
    if previewCamera and IsCamActive(previewCamera) then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(previewCamera, false)
        previewCamera = nil
    end
    
    return true
end
local function setVehicleLivery(liveryId)
    if not previewVehicle or not DoesEntityExist(previewVehicle) then
        return false
    end
    
    SetVehicleModKit(previewVehicle, 0)
    SetVehicleMod(previewVehicle, 48, liveryId, false)
    SetVehicleLivery(previewVehicle, liveryId)
    
    return true
end
local function toggleVehicleExtra(extraId, disabled)
    if not previewVehicle or not DoesEntityExist(previewVehicle) then
        return false
    end
    
    if not DoesExtraExist(previewVehicle, extraId) then
        Framework.Client.Notify("EXTRA_NOT_AVAILABLE", "error")
        return false
    end
    
    SetVehicleExtra(previewVehicle, extraId, disabled)
    SetVehicleFixed(previewVehicle)
    
    return true
end
function showLiveriesExtrasMenu(vehicle)
    previewVehicle = vehicle
    
    if not previewVehicle or not DoesEntityExist(previewVehicle) then
        return false
    end
    
    local vehicleCoords = GetEntityCoords(previewVehicle)
    local vehicleHeading = GetEntityHeading(previewVehicle)
    originalHeading = vehicleHeading
    
    local camDistance = 5.0
    local camHeight = 2.0
    local angleRad = math.rad(vehicleHeading + 45)
    
    local camX = vehicleCoords.x + (camDistance * math.cos(angleRad))
    local camY = vehicleCoords.y + (camDistance * math.sin(angleRad))
    local camZ = vehicleCoords.z + camHeight
    
    previewCamera = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        camX, camY, camZ,
        0.0, 0.0, 0.0, 60.0,
        false, 0
    )
    
    SetCamActive(previewCamera, true)
    SetCamFov(previewCamera, 60.0)
    PointCamAtEntity(previewCamera, previewVehicle, 0.0, 0.0, 0.0, true)
    RenderScriptCams(true, true, 500, true, true)
    local extras = {}
    for extraId = 1, 14 do
        table.insert(extras, {
            id = extraId,
            available = DoesExtraExist(previewVehicle, extraId),
            enabled = IsVehicleExtraTurnedOn(previewVehicle, extraId)
        })
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "show-liveries-extras-menu",
        extras = extras,
        currentLivery = GetVehicleLivery(previewVehicle),
        liveriesCount = GetVehicleLiveryCount(previewVehicle),
        locale = Locale,
        config = Config
    })
    CreateThread(function()
        Wait(500)
        local currentAngle = vehicleHeading + 45
        local currentRadius = camDistance
        local currentHeight = camHeight
        local isDragging = false
        local lastMouseX = 0
        local zoomSpeed = 0.5
        local minRadius = 3.0
        local maxRadius = 10.0
        local minHeight = 0.5
        local maxHeight = 5.0
        local helpShown = false
        
        while previewCamera do
            if not Config.DoNotSpawnInsideVehicle and cache.vehicle then
                break
            end
            
            -- Show help notification
            if not helpShown then
                helpShown = true
                Framework.Client.Notify("Hold Right Mouse to rotate camera | Scroll to zoom", "info", 5000)
            end
            
            -- Mouse controls for camera rotation
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            
            -- Check for right mouse button (aim button)
            if IsDisabledControlPressed(0, 25) then
                if not isDragging then
                    isDragging = true
                    lastMouseX = GetDisabledControlNormal(0, 1)
                end
                
                local mouseX = GetDisabledControlNormal(0, 1)
                local mouseY = GetDisabledControlNormal(0, 2)
                local deltaX = mouseX - lastMouseX
                
                -- Rotate camera around vehicle
                currentAngle = currentAngle - (deltaX * 5.0)
                
                -- Adjust camera height with vertical mouse movement
                currentHeight = currentHeight - (mouseY * 0.05)
                currentHeight = math.max(minHeight, math.min(maxHeight, currentHeight))
                
                lastMouseX = mouseX
            else
                isDragging = false
            end
            
            -- Mouse wheel zoom
            if IsDisabledControlJustPressed(0, 241) then -- Scroll wheel up
                currentRadius = math.max(minRadius, currentRadius - zoomSpeed)
            elseif IsDisabledControlJustPressed(0, 242) then -- Scroll wheel down
                currentRadius = math.min(maxRadius, currentRadius + zoomSpeed)
            end
            
            -- Update camera position
            local angleRad = math.rad(currentAngle)
            local newCamX = vehicleCoords.x + (currentRadius * math.cos(angleRad))
            local newCamY = vehicleCoords.y + (currentRadius * math.sin(angleRad))
            local newCamZ = vehicleCoords.z + currentHeight
            
            SetCamCoord(previewCamera, newCamX, newCamY, newCamZ)
            PointCamAtEntity(previewCamera, previewVehicle, 0.0, 0.0, 0.0, true)
            
            -- Ensure vehicle stays visible
            SetEntityVisible(previewVehicle, true, false)
            SetEntityAlpha(previewVehicle, 255, false)
            
            Wait(0)
        end
        
        if not Config.DoNotSpawnInsideVehicle and not cache.vehicle then
            exitLiveriesExtrasMenu()
        end
    end)
end
RegisterNUICallback("change-vehicle-plate", function(data, callback)
    local result = changeVehiclePlate(data.newPlate)
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNUICallback("exit-liveries-extras-menu", function(data, callback)
    local result = exitLiveriesExtrasMenu()
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNUICallback("toggle-livery", function(data, callback)
    local result = setVehicleLivery(data.livery_id)
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNUICallback("toggle-extra", function(data, callback)
    local result = toggleVehicleExtra(data.extra_id, data.disabled)
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNetEvent("jg-advancedgarages:client:show-vplate-form", showVehiclePlateForm)
