local function isGarageNameAvailable(source, garageName)
    local existingGarages = tableKeys(getAllGaragesAndImpounds())
    
    if lib.table.contains(existingGarages, garageName) then
        Framework.Server.Notify(source, "GARAGE_NAME_TAKEN", "error")
        print("^1[ERROR] Garage name has already been taken. Every garage name, including public, job, gang in the config have to be uniquely named")
        return false
    end
    
    return true
end

local function canCreatePrivateGarage(source)
    local playerJob = Framework.Server.GetPlayerJob(source)
    
    if not playerJob then
        return false
    end
    
    if not isItemInList(Config.PrivGarageCreateJobRestriction, playerJob.name) then
        if not Framework.Server.IsAdmin(source) then
            Framework.Server.Notify(source, Locale.actionNotAllowedError, "error")
            return false
        end
    end
    
    return true
end

lib.callback.register("jg-advancedgarages:server:is-garage-name-available", isGarageNameAvailable)
lib.callback.register("jg-advancedgarages:server:can-create-priv-garage", canCreatePrivateGarage)

lib.callback.register("jg-advancedgarages:server:create-private-garage", function(source, garageData)
    if not canCreatePrivateGarage(source) then
        return false
    end
    
    if not isGarageNameAvailable(source, garageData.name) then
        return false
    end
    
    local insertId = MySQL.insert.await(
        "INSERT INTO player_priv_garages SET owners = ?, name = ?, type = ?, x = ?, y = ?, z = ?, h = ?, distance = ?",
        {
            json.encode(garageData.owners),
            garageData.name,
            garageData.type,
            garageData.x,
            garageData.y,
            garageData.z,
            garageData.h,
            garageData.distance
        }
    )
    
    for _, owner in pairs(garageData.owners) do
        local ownerSource = Framework.Server.GetSrcFromIdentifier(owner.identifier)
        if ownerSource then
            TriggerClientEvent("jg-advancedgarages:client:update-blips-text-uis", ownerSource)
        end
    end
    
    Framework.Server.Notify(source, Locale.garageCreatedSuccess, "success")
    
    sendWebhook(source, Webhooks.PrivateGarages, "Private Garage Created", "success", {
        { key = "Name", value = garageData.name },
        { key = "Type", value = garageData.type },
        { key = "Owners", value = json.encode(garageData.owners) },
        { 
            key = "Location", 
            value = table.concat({
                math.ceil(garageData.x),
                math.ceil(garageData.y),
                math.ceil(garageData.z),
                math.ceil(garageData.h)
            }, ", ") .. " / dist: " .. garageData.distance
        }
    })
    
    return { id = insertId }
end)

lib.callback.register("jg-advancedgarages:server:edit-private-garage", function(source, garageData)
    if not canCreatePrivateGarage(source) then
        return false
    end
    
    local existingGarage = MySQL.single.await(
        "SELECT * FROM player_priv_garages WHERE id = ?",
        {garageData.id}
    )
    
    if not existingGarage then
        return false
    end
    
    MySQL.update.await(
        "UPDATE player_priv_garages SET owners = ?, type = ?, x = ?, y = ?, z = ?, h = ?, distance = ? WHERE id = ?",
        {
            json.encode(garageData.owners),
            garageData.type,
            garageData.x,
            garageData.y,
            garageData.z,
            garageData.h,
            garageData.distance,
            garageData.id
        }
    )
    
    local allOwners = lib.table.merge(json.decode(existingGarage.owners), garageData.owners)
    
    for _, owner in pairs(allOwners) do
        local ownerSource = Framework.Server.GetSrcFromIdentifier(owner.identifier)
        if ownerSource then
            TriggerClientEvent("jg-advancedgarages:client:update-blips-text-uis", ownerSource)
        end
    end
    
    Framework.Server.Notify(source, Locale.garageUpdatedSuccess, "success")
    
    sendWebhook(source, Webhooks.PrivateGarages, "Private Garage Edited", "warn", {
        { key = "Name", value = garageData.name },
        { key = "Type", value = garageData.type },
        { key = "Owners", value = json.encode(garageData.owners) },
        { 
            key = "Location", 
            value = table.concat({
                math.ceil(garageData.x),
                math.ceil(garageData.y),
                math.ceil(garageData.z),
                math.ceil(garageData.h)
            }, ", ") .. " / dist: " .. garageData.distance
        }
    })
    
    return true
end)

lib.callback.register("jg-advancedgarages:server:delete-private-garage", function(source, garageData)
    if not canCreatePrivateGarage(source) then
        return false
    end
    
    MySQL.update.await(
        "DELETE FROM player_priv_garages WHERE id = ?",
        {garageData.id}
    )
    
    for _, owner in pairs(garageData.owners) do
        local ownerSource = Framework.Server.GetSrcFromIdentifier(owner.identifier)
        if ownerSource then
            TriggerClientEvent("jg-advancedgarages:client:update-blips-text-uis", ownerSource)
        end
    end
    
    sendWebhook(source, Webhooks.PrivateGarages, "Private Garage Deleted", "danger", {
        { key = "Name", value = garageData.name }
    })
    
    return true
end)

lib.callback.register("jg-advancedgarages:server:get-all-private-garages", function(source, data)
    if not canCreatePrivateGarage(source) then
        return false
    end
    
    local privateGarages = MySQL.query.await("SELECT * FROM player_priv_garages ORDER BY id DESC")
    local allPlayers = Framework.Server.GetPlayers()
    
    return {
        garages = privateGarages,
        allPlayers = allPlayers
    }
end)

lib.addCommand(Config.PrivGarageCreateCommand, false, function(source)
    if not canCreatePrivateGarage(source) then
        return
    end
    
    TriggerClientEvent("jg-advancedgarages:client:show-private-garages-dashboard", source)
end)
