local function getPlayerPrivateGarages(source)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(source)
    
    if not playerIdentifier then
        return {}
    end
    
    local privateGarages = MySQL.query.await(Framework.Queries.GetPrivateGarages, {"%" .. playerIdentifier .. "%"})
    
    return privateGarages or {}
end

function getPlayerAvailableGarageLocations(source)
    local locations = {}
    
    for garageId, garageData in pairs(Config.GarageLocations) do
        locations[garageId] = garageData
        locations[garageId].checkVehicleGarageId = Config.GarageUniqueLocations
        locations[garageId].enableInteriors = garageData.type == "car" and Config.GarageEnableInteriors
        locations[garageId].uniqueBlips = Config.GarageUniqueBlips
        locations[garageId].infiniteSpawns = Config.AllowInfiniteVehicleSpawns
        locations[garageId].garageType = "personal"
    end
    
    for _, privateGarage in ipairs(getPlayerPrivateGarages(source)) do
        local garageName = privateGarage.name
        locations[garageName] = {
            coords = vector3(privateGarage.x, privateGarage.y, privateGarage.z),
            spawn = vector4(privateGarage.x, privateGarage.y, privateGarage.z, privateGarage.h),
            distance = privateGarage.distance,
            type = privateGarage.type,
            hideBlip = Config.PrivGarageHideBlips,
            blip = Config.PrivGarageBlip,
            uniqueBlips = Config.GarageUniqueBlips,
            checkVehicleGarageId = Config.GarageUniqueLocations,
            enableInteriors = privateGarage.type == "car" and Config.PrivGarageEnableInteriors,
            infiniteSpawns = Config.AllowInfiniteVehicleSpawns,
            garageType = "personal"
        }
    end
    
    local playerJob = Framework.Server.GetPlayerJob(source)
    
    for garageId, garageData in pairs(Config.JobGarageLocations) do
        if playerJob then
            local hasAccess = false
            
            if type(garageData.job) == "table" then
                hasAccess = isItemInList(garageData.job, playerJob.name)
            else
                hasAccess = garageData.job == playerJob.name
            end
            
            if hasAccess then
                locations[garageId] = garageData
                locations[garageId].checkVehicleGarageId = Config.JobGarageUniqueLocations and garageData.vehiclesType ~= "spawner"
                locations[garageId].enableInteriors = garageData.type == "car" and Config.JobGarageEnableInteriors
                locations[garageId].uniqueBlips = Config.JobGarageUniqueBlips
                locations[garageId].infiniteSpawns = Config.JobGaragesAllowInfiniteVehicleSpawns
                locations[garageId].garageType = "job"
            end
        end
    end
    
    local isRcoreGangs = Config.Gangs == "rcore_gangs"
    local playerGang = nil
    
    if Config.Framework == "QBCore" or Config.Framework == "Qbox" or Config.GangEnableCustomESXIntegration or isRcoreGangs then
        playerGang = Framework.Server.GetPlayerGang(source)
    end
    
    for garageId, garageData in pairs(Config.GangGarageLocations) do
        if playerGang then
            local hasAccess = false
            
            if type(garageData.gang) == "table" then
                hasAccess = isItemInList(garageData.gang, playerGang.name)
            else
                hasAccess = garageData.gang == playerGang.name
            end
            
            if hasAccess then
                locations[garageId] = garageData
                locations[garageId].checkVehicleGarageId = Config.GangGarageUniqueLocations and garageData.vehiclesType ~= "spawner"
                locations[garageId].enableInteriors = garageData.type == "car" and Config.GangGarageEnableInteriors
                locations[garageId].uniqueBlips = Config.GangGarageUniqueBlips
                locations[garageId].infiniteSpawns = Config.GangGaragesAllowInfiniteVehicleSpawns
                locations[garageId].garageType = "gang"
            end
        end
    end
    
    for impoundId, impoundData in pairs(Config.ImpoundLocations) do
        locations[impoundId] = impoundData
        locations[impoundId].uniqueBlips = Config.ImpoundUniqueBlips
        locations[impoundId].garageType = "impound"
        
        local hasImpoundJob = false
        if impoundData.job and playerJob then
            if type(impoundData.job) == "table" then
                hasImpoundJob = isItemInList(impoundData.job, playerJob.name)
            else
                hasImpoundJob = impoundData.job == playerJob.name
            end
        end
        
        locations[impoundId].hasImpoundJob = hasImpoundJob
    end
    
    return locations
end

lib.callback.register("jg-advancedgarages:server:get-available-garage-locations", getPlayerAvailableGarageLocations)
