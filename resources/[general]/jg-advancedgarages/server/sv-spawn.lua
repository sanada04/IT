local vehiclePropsRetryCount = {}
local MAX_SPAWN_DISTANCE = 10.0
local MAX_PROPS_RETRY = 3

local function createVehicleWithServerSetter(source, modelHash, vehicleType, plate, coords, warpIntoVehicle, vehicleData)
    if vehiclePropsRetryCount[source] then
        if vehiclePropsRetryCount[source] == MAX_PROPS_RETRY then
            print("^3[WARNING] Vehicle props failed to set after trying several times. First check if the plate within the vehicle props JSON does not match the plate column. If they match, and you see this message regularly, try setting Config.SpawnVehiclesWithServerSetter = false")
            vehiclePropsRetryCount[source] = 0
            return false
        end
    end
    
    vehiclePropsRetryCount[source] = (vehiclePropsRetryCount[source] or 0) + 1
    
    local vehicle = CreateVehicleServerSetter(modelHash, vehicleType, coords.x, coords.y, coords.z, coords.w)
    
    lib.waitFor(function()
        if DoesEntityExist(vehicle) then
            return true
        end
    end, "Timed out while trying to spawn in vehicle (server)", 10000)
    
    lib.waitFor(function()
        return GetVehicleNumberPlateText(vehicle) ~= ""
    end, "Vehicle number plate text is nil", 5000)
    
    SetEntityRoutingBucket(vehicle, GetPlayerRoutingBucket(source))
    
    for seatIndex = -1, 6 do
        local ped = GetPedInVehicleSeat(vehicle, seatIndex)
        if ped ~= 0 then
            DeleteEntity(ped)
        end
    end
    
    if warpIntoVehicle then
        local playerPed = GetPlayerPed(source)
        pcall(function()
            lib.waitFor(function()
                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    return true
                end
                SetPedIntoVehicle(playerPed, vehicle, -1)
            end, nil, 1000)
        end)
    end
    
    lib.waitFor(function()
        return NetworkGetEntityOwner(vehicle) ~= -1
    end, "Timed out waiting for server-setter entity to have an owner (owner is -1)", 5000)
    
    local vehicleState = Entity(vehicle).state
    vehicleState:set("vehInit", true, true)
    
    if vehicleData and type(vehicleData) == "table" then
        vehicleState:set("vehCreatedApplyProps", vehicleData, true)
    end
    
    local success = pcall(function()
        lib.waitFor(function()
            local state = Entity(vehicle).state
            if not state.vehCreatedApplyProps then
                if plate and plate ~= "" then
                    if Framework.Server.GetPlate(vehicle) == plate then
                        return true
                    end
                else
                    return true
                end
            end
        end, nil, 2000)
    end)
    
    if not success then
        DeleteEntity(vehicle)
        deleteVehicle(vehicle)
        return createVehicleWithServerSetter(source, modelHash, vehicleType, plate, coords, warpIntoVehicle, vehicleData)
    end
    
    vehiclePropsRetryCount[source] = 0
    
    return NetworkGetNetworkIdFromEntity(vehicle)
end

function spawnVehicleServer(source, vehicleId, model, plate, coords, warpIntoVehicle, vehicleData, garageType)
    local modelHash, vehicleType, hasSeats = lib.callback.await("jg-advancedgarages:client:req-vehicle-and-get-spawn-details", source, model)
    
    if not modelHash then
        return false
    end
    
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local shouldTeleport = false
    
    local distance = #(playerCoords - coords.xyz)
    if distance > MAX_SPAWN_DISTANCE then
        SetEntityCoords(playerPed, coords.x + 3.0, coords.y + 3.0, coords.z, false, false, false, false)
        shouldTeleport = true
    end
    
    local netId = createVehicleWithServerSetter(source, modelHash, vehicleType, plate, coords, hasSeats and warpIntoVehicle, vehicleData)
    
    if not netId then
        return false
    end
    
    local vehicleEntity = lib.callback.await(
        "jg-advancedgarages:client:on-server-vehicle-created",
        source,
        netId,
        shouldTeleport and playerCoords,
        hasSeats and warpIntoVehicle,
        modelHash,
        vehicleId,
        plate,
        vehicleData,
        garageType
    )
    
    if not vehicleEntity then
        if NetworkDoesEntityExistWithNetworkId(netId) then
            DeleteEntity(NetworkGetEntityFromNetworkId(netId))
            debugPrint("Failed to create vehicle, deleted entity.", "warning", netId)
        end
        return false
    end
    
    return vehicleEntity, netId
end
