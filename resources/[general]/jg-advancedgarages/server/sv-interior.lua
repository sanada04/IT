local interiorSessions = {}

lib.callback.register("jg-advancedgarages:server:enter-interior", function(source, garageId, vehicles)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(source)
    
    if not playerIdentifier then
        if Config.Debug then
            print("^1[ERROR] No player identifier found for source: " .. source)
        end
        return false
    end
    
    if Config.Debug then
        print(string.format("^2[DEBUG] Player %s entering interior for garage: %s", playerIdentifier, garageId))
        print(string.format("^2[DEBUG] Vehicles count: %d", vehicles and #vehicles or 0))
    end
    
    local originalBucket = 0
    if Config.ReturnToPreviousRoutingBucket then
        originalBucket = GetPlayerRoutingBucket(source)
    end
    
    local newBucket = math.random(100, 999)
    SetPlayerRoutingBucket(source, newBucket)
    
    interiorSessions[playerIdentifier] = {
        garage = garageId,
        originalBucket = originalBucket,
        currentBucket = newBucket
    }
    
    if Config.Debug then
        print(string.format("^2[DEBUG] Player moved to routing bucket: %d", newBucket))
    end
    
    TriggerClientEvent("jg-advancedgarages:client:enter-interior", source, garageId, vehicles)
    
    return true
end)

lib.callback.register("jg-advancedgarages:server:exit-interior", function(source)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(source)
    
    if not playerIdentifier then
        return false
    end
    
    local session = interiorSessions[playerIdentifier]
    
    if session then
        if Config.ReturnToPreviousRoutingBucket then
            SetPlayerRoutingBucket(source, session.originalBucket)
        end
    else
        SetPlayerRoutingBucket(source, 0)
    end
    
    return true
end)
