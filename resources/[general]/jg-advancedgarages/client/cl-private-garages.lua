local function showPrivateGaragesDashboard()
    local canCreate = lib.callback.await("jg-advancedgarages:server:can-create-priv-garage")
    
    if not canCreate then
        return false
    end
    
    local garageData = lib.callback.await("jg-advancedgarages:server:get-all-private-garages")
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "showPrivGarages",
        garages = garageData.garages,
        allPlayers = garageData.allPlayers,
        locale = Locale,
        config = Config
    })
end
local function createPrivateGarage(garageData)
    local canCreate = lib.callback.await("jg-advancedgarages:server:can-create-priv-garage")
    
    if not canCreate then
        return false
    end
    
    return lib.callback.await("jg-advancedgarages:server:create-private-garage", false, garageData)
end
local function editPrivateGarage(garageData)
    local canCreate = lib.callback.await("jg-advancedgarages:server:can-create-priv-garage")
    
    if not canCreate then
        return false
    end
    
    return lib.callback.await("jg-advancedgarages:server:edit-private-garage", false, garageData)
end
local function deletePrivateGarage(garageData)
    local canCreate = lib.callback.await("jg-advancedgarages:server:can-create-priv-garage")
    
    if not canCreate then
        return false
    end
    
    return lib.callback.await("jg-advancedgarages:server:delete-private-garage", false, garageData)
end
RegisterNUICallback("is-garage-name-available", function(data, callback)
    callback(lib.callback.await("jg-advancedgarages:server:is-garage-name-available", false, data.name))
end)
RegisterNUICallback("create-private-garage", function(data, callback)
    local result = createPrivateGarage(data)
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNUICallback("edit-private-garage", function(data, callback)
    local result = editPrivateGarage(data)
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNUICallback("delete-private-garage", function(data, callback)
    local result = deletePrivateGarage(data)
    
    if not result then
        return callback({ error = true })
    end
    
    callback(result)
end)
RegisterNUICallback("get-current-coords", function(data, callback)
    local coords = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)
    
    callback({
        x = coords.x,
        y = coords.y,
        z = coords.z,
        h = heading
    })
end)
RegisterNetEvent("jg-advancedgarages:client:show-private-garages-dashboard", function()
    showPrivateGaragesDashboard()
end)
RegisterNetEvent("jg-advancedgarages:client:show-house-garage", function(garageId, vehicleType)
    openGarageMenu(garageId, vehicleType)
end)

RegisterNetEvent("jg-advancedgarages:client:ShowHouseGarage", function(garageId, vehicleType)
    openGarageMenu(garageId, vehicleType)
end)

RegisterNetEvent("jg-advancedgarages:client:ShowHouseGarage:qs-housing", function(garageId, vehicleType)
    openGarageMenu(garageId, vehicleType)
end)
