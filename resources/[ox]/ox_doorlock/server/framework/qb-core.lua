local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayer(playerId)
	return QBCore.Functions.GetPlayer(tonumber(playerId))
end

function GetCharacterId(player)
	return player.PlayerData.citizenid
end

---@param player table QBCore player
---@param filter string|string[]|table<string, number>
function IsPlayerInGroup(player, filter)
	if not player or not player.PlayerData or not player.PlayerData.job then
		return
	end

	local job = player.PlayerData.job
	local gradeLevel = job.grade and (job.grade.level or job.grade) or 0
	local filterType = type(filter)

	if filterType == 'string' then
		if job.name == filter then
			return job.name, gradeLevel
		end
		return
	end

	local t = table.type(filter)
	if t == 'hash' then
		local need = filter[job.name]
		if need ~= nil and gradeLevel >= need then
			return job.name, gradeLevel
		end
	elseif t == 'array' then
		for i = 1, #filter do
			if job.name == filter[i] then
				return job.name, gradeLevel
			end
		end
	end
end
