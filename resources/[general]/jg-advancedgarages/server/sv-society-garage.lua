local function setSocietyVehicle(source, societyType, societyName, minGrade)
    local societies = societyType == "gang" and Framework.Server.GetGangs() or Framework.Server.GetJobs()
    if not societies then
        societies = {}
    end
    
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    
    if not vehicle then
        Framework.Server.Notify(source, Locale.notInsideVehicleError, "error")
        return
    end
    
    local plate = Framework.Server.GetPlate(vehicle)
    
    if not plate then
        debugPrint("Framework.Server.GetPlate returned nil.", "warning")
        return
    end
    
    local vehicleData = getVehicleData(source, plate)
    
    if not vehicleData then
        Framework.Server.Notify(source, Locale.vehicleNotOwnedByPlayerError, "error")
        return
    end
    
    if not societyName or not societies[societyName] then
        local errorMessage = societyType == "job" and Locale.invalidJobError or Locale.invalidGangError
        Framework.Server.Notify(source, errorMessage, "error")
        return
    end
    
    local query = societyType == "gang" and Framework.Queries.SetGangVehicle or Framework.Queries.SetJobVehicle
    
    MySQL.update.await(
        query:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {societyName, minGrade, plate}
    )
    
    local successMessage = societyType == "gang" and Locale.vehicleAddedToGangGarageSuccess or Locale.vehicleAddedToJobGarageSuccess
    Framework.Server.Notify(source, string.gsub(successMessage, "%%{value}", societyName), "success")
end

local function removeSocietyVehicle(source, targetPlayerId)
    local targetPlayer = targetPlayerId
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    
    if not vehicle then
        Framework.Server.Notify(source, Locale.notInsideVehicleError, "error")
        return
    end
    
    local plate = Framework.Server.GetPlate(vehicle)
    
    if not plate then
        debugPrint("Framework.Server.GetPlate returned nil.", "warning")
        return
    end
    
    local vehicleData = getVehicleData(source, plate)
    
    if not vehicleData then
        Framework.Server.Notify(source, Locale.vehicleNotOwnedByPlayerError, "error")
        return
    end
    
    local targetIdentifier = Framework.Server.GetPlayerIdentifier(targetPlayer)
    
    if not targetIdentifier then
        Framework.Server.Notify(source, Locale.playerNotOnlineError, "error")
        return
    end
    
    MySQL.update.await(
        Framework.Queries.SetSocietyVehicleAsPlayerOwned:format(Framework.VehiclesTable, Framework.PlayerIdentifier),
        {targetIdentifier, plate}
    )
    
    local targetPlayerInfo = Framework.Server.GetPlayerInfo(targetPlayer)
    local targetName = targetPlayerInfo and targetPlayerInfo.name
    
    Framework.Server.Notify(source, string.gsub(Locale.vehicleTransferSuccess, "%%{value}", targetName), "success")
    Framework.Server.Notify(targetPlayer, string.gsub(Locale.vehicleReceived, "%%{value}", plate), "success")
end

lib.addCommand(Config.JobGarageSetVehicleCommand, {
    help = Locale.cmdSetJobVehicle,
    params = {
        { name = "job", type = "string", help = Locale.cmdArgJobName },
        { name = "grade", type = "number", help = Locale.cmgArgMinJobRank, optional = true }
    }
}, function(source, args)
    if not Framework.Server.IsAdmin(source) then
        return Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
    end
    
    setSocietyVehicle(source, "job", args.job, args.grade or 0)
end)

lib.addCommand(Config.GangGarageSetVehicleCommand, {
    help = Locale.cmdSetGangVehicle,
    params = {
        { name = "gang", type = "string", help = Locale.cmdArgGangName },
        { name = "grade", type = "number", help = Locale.cmgArgMinGangRank, optional = true }
    }
}, function(source, args)
    if not Framework.Server.IsAdmin(source) then
        return Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
    end
    
    local isQBCore = Config.Framework == "QBCore"
    local isRcoreGangs = Config.Gangs == "rcore_gangs"
    
    if not isQBCore and not isRcoreGangs then
        if not Config.GangEnableCustomESXIntegration then
            Framework.Server.Notify(source, "Gangs are only compatible with QBCore & Qbox", "error")
            return
        end
    end
    
    setSocietyVehicle(source, "gang", args.gang, args.grade or 0)
end)

lib.addCommand(Config.JobGarageRemoveVehicleCommand, {
    help = Locale.cmdRemoveJobVehicle,
    params = {
        { name = "id", type = "playerId", help = Locale.cmdArgPlayerId }
    }
}, function(source, args)
    if not Framework.Server.IsAdmin(source) then
        return Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
    end
    
    removeSocietyVehicle(source, tonumber(args.id) or 0)
end)

lib.addCommand(Config.GangGarageRemoveVehicleCommand, {
    help = Locale.cmdRemoveGangVehicle,
    params = {
        { name = "id", type = "playerId", help = Locale.cmdArgPlayerId }
    }
}, function(source, args)
    if not Framework.Server.IsAdmin(source) then
        return Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
    end
    
    removeSocietyVehicle(source, tonumber(args.id) or 0)
end)
