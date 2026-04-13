local QBCore = nil
pcall(function()
	QBCore = exports['qb-core']:GetCoreObject()
end)

local function isQbPlayerLoaded()
	if not QBCore then return false end
	local ok, v = pcall(function()
		return LocalPlayer.state['isLoggedIn'] == true
	end)
	return ok and v
end

local function shouldHideForCharacterSelect()
	if Config.HideDuringCharacterSelect ~= true then return false end
	if not QBCore then return false end
	return not isQbPlayerLoaded()
end

local function pad2(n)
	if n < 10 then return '0' .. tostring(n) end
	return tostring(n)
end

local function getGameDateStr()
	-- FiveM client では `os` が無いことがあるため、GetClock* だけで日付を作る
	local day = 1
	local month = 1
	local year = 1970

	-- ネイティブが利用できない環境でも落ちないよう保険
	local ok, v = pcall(function() return GetClockDayOfMonth() end)
	if ok and v then day = tonumber(v) or day end
	ok, v = pcall(function() return GetClockMonth() end)
	if ok and v then month = tonumber(v) or month end
	ok, v = pcall(function() return GetClockYear() end)
	if ok and v then year = tonumber(v) or year end

	local d = pad2(day)
	local m = pad2(month)
	local y = tostring(year)

	if Config.DayMonthYear then
		return d .. '-' .. m .. '-' .. y
	elseif Config.MonthDayYear then
		return m .. '-' .. d .. '-' .. y
	elseif Config.YearMonthDay then
		return y .. '-' .. m .. '-' .. d
	elseif Config.YearDayMonth then
		return y .. '-' .. d .. '-' .. m
	else
		return d .. '-' .. m .. '-' .. y
	end
end

local function getGameTimeStr()
	local h = GetClockHours()
	local m = GetClockMinutes()
	return pad2(h) .. ':' .. pad2(m)
end

local function buildDatetimeStr()
	local showDate = (Config.ShowDateAndTime == true) or (Config.ShowOnlyDate == true)
	local showTime = (Config.ShowDateAndTime == true) or (Config.ShowOnlyTime == true)

	local timeStr = getGameTimeStr()
	local dateStr = showDate and getGameDateStr() or ''

	if showDate and showTime then
		return dateStr .. ' at ' .. timeStr
	elseif showTime then
		return timeStr
	elseif showDate then
		return dateStr
	end

	-- fallback
	return timeStr
end

local function getMoney()
	local okAll, cash, bank = pcall(function()
		local _cash = nil
		local _bank = nil

		if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
			local ok, pdata = pcall(function()
				return QBCore.Functions.GetPlayerData()
			end)
			if ok and pdata and pdata.money then
				local m = pdata.money
				_cash = m.cash or m['cash']
				_bank = m.bank or m['bank']
			end
		end

		return _cash or 0, _bank or 0
	end)

	if not okAll then
		return 0, 0, 0
	end

	return cash, bank, cash + bank
end

local function updateNui()
	local ok, _ = pcall(function()
		local serverName = (Config.ShowServerName and Config.ServerName) and Config.ServerName or nil
		local serverId = (Config.ShowServerID and GetPlayerServerId(PlayerId())) or nil

		local cash, bank = getMoney()
		local showCash = (Config.ShowCash == true)
		local showBank = (Config.ShowBank == true)

		SendNUIMessage({
			action = 'setTimeAndDate',
			datetime = buildDatetimeStr(),
			serverName = serverName,
			serverId = serverId,
			cash = showCash and cash or nil,
			bank = showBank and bank or nil,
		})
	end)

	if not ok then
		-- qb-core restart 直後などの一時的な参照エラーは次ループで再試行
		return
	end
end

-- server から来るイベントは受け取るだけ（UI はクライアント側で更新する）
RegisterNetEvent('TimeAndDateDisplay-FiveM')
AddEventHandler('TimeAndDateDisplay-FiveM', function(_)
	updateNui()
end)

local started = false
local function startUiLoop()
	if started then return end
	started = true

	CreateThread(function()
		updateNui()
		while true do
			Wait(1000)
			updateNui()
		end
	end)

	-- マップ/ポーズ・QBCore 未ロード（マルチキャラ等）のとき HUD を隠す
	CreateThread(function()
		local lastVisible = true
		while true do
			Wait(200)
			local visible = not IsPauseMenuActive() and not shouldHideForCharacterSelect()
			if visible ~= lastVisible then
				lastVisible = visible
				SendNUIMessage({
					action = 'setHudVisible',
					visible = visible
				})
			end
		end
	end)
end

AddEventHandler('onClientResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end

	CreateThread(function()
		Wait(400)
		TriggerServerEvent('TimeAndDateDisplay-FiveM:request')
		startUiLoop()
	end)
end)

CreateThread(function()
	while not NetworkIsSessionStarted() do
		Wait(200)
	end
	Wait(800)
	TriggerServerEvent('TimeAndDateDisplay-FiveM:request')
	startUiLoop()
end)