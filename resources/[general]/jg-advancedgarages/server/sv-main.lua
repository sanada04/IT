function findVehicleSpawnCoords(coords)
    local coordType = type(coords)
    
    if coordType == "table" then
        if coordType ~= "vector4" and coordType ~= "vector3" then
            -- Handle array of coordinates
            for _, coord in pairs(coords) do
                local nearbyVehicle = lib.getClosestVehicle(coord.xyz, 2.5)
                if not nearbyVehicle then
                    return coord
                end
            end
            return findVehicleSpawnCoords(coords[1])
        end
    else
        -- Handle single coordinate
        local attempt = 1
        local currentCoords = coords
        
        while attempt <= 10 do
            local nearbyVehicle = lib.getClosestVehicle(currentCoords.xyz, 2.5)
            if not nearbyVehicle then
                return currentCoords
            end
            
            local x = currentCoords.x
            local y = currentCoords.y
            local heading = currentCoords.w
            
            -- Adjust position based on heading
            if (heading >= 0 and heading <= 45) or (heading >= 315 and heading <= 360) then
                y = y + 5  -- North
            elseif heading >= 46 and heading <= 135 then
                x = x - 5  -- West
            elseif heading >= 136 and heading <= 225 then
                y = y - 5  -- South
            elseif heading >= 226 and heading <= 314 then
                x = x + 5  -- East
            end
            
            currentCoords = vector4(x, y, currentCoords.z, currentCoords.w)
            attempt = attempt + 1
        end
        
        return currentCoords
    end
end
function deleteVehicle(vehicle, plate, vin)
    local advancedParkingState = GetResourceState("AdvancedParking")
    
    if advancedParkingState == "started" then
        if plate or vin then
            exports.AdvancedParking:DeleteVehicleUsingData(nil, plate, vin, false)
        else
            exports.AdvancedParking:DeleteVehicle(vehicle, false)
        end
    else
        DeleteEntity(vehicle)
    end
end
function getNearbyPlayers(sourcePlayer, coords, distance, includeSelf)
    local nearbyPlayers = lib.getNearbyPlayers(coords, distance)
    local playerList = {}
    
    for _, player in ipairs(nearbyPlayers) do
        if includeSelf or player.id ~= sourcePlayer then
            local playerInfo = Framework.Server.GetPlayerInfo(player.id)
            
            table.insert(playerList, {
                id = player.id,
                identifier = Framework.Server.GetPlayerIdentifier(player.id),
                name = playerInfo and playerInfo.name
            })
        end
    end
    
    return playerList
end
function getAllGaragesAndImpounds()
    local publicGarages = lib.table.deepclone(Config.GarageLocations)
    local jobGarages = lib.table.deepclone(Config.JobGarageLocations)
    local gangGarages = lib.table.deepclone(Config.GangGarageLocations)
    local impoundLocations = lib.table.deepclone(Config.ImpoundLocations)
    local privateGarages = {}
    local privateGarageData = MySQL.query.await("SELECT * FROM player_priv_garages")
    
    for _, garage in ipairs(privateGarageData) do
        privateGarages[garage.name] = {
            coords = vector3(garage.x, garage.y, garage.z),
            spawn = vector4(garage.x, garage.y, garage.z, garage.h),
            distance = garage.distance,
            type = garage.type,
            hideBlip = Config.PrivGarageHideBlips,
            blip = Config.PrivGarageBlip
        }
    end
    local allLocations = lib.table.merge(
        lib.table.merge(
            lib.table.merge(
                lib.table.merge(impoundLocations, privateGarages),
                gangGarages
            ),
            jobGarages
        ),
        publicGarages
    )
    
    return allLocations or {}
end
lib.callback.register("jg-advancedgarages:server:nearby-players", function(...)
    return getNearbyPlayers(...)
end)
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    initSQL()
end)
