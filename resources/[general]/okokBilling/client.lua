local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

local function notify(message, nType, length)
	local duration = length or 10000
	local alertType = nType or 'primary'
	if GetResourceState('okokNotify') == 'started' and (Config.UseOKOKNotify == nil or Config.UseOKOKNotify) then
		exports['okokNotify']:Alert("請求書", message, duration, alertType)
	else
		QBCore.Functions.Notify(message, alertType, duration)
	end
end

CreateThread(function()
	while not LocalPlayer.state.isLoggedIn do
		Wait(10)
	end
	PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
	PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate", function(job)
	PlayerData.job = job
end)

local function MyInvoices()
	QBCore.Functions.TriggerCallback("okokBilling:GetInvoices", function(invoices)
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'myinvoices',
			invoices = invoices or {},
			VAT = Config.VATPercentage or 0
		})
	end)
end

local function SocietyInvoices(society)
	QBCore.Functions.TriggerCallback("okokBilling:GetSocietyInvoices", function(list, totalInvoices, totalIncome, totalUnpaid, awaitedIncome)
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = 'societyinvoices',
			invoices = list or {},
			totalInvoices = totalInvoices or 0,
			totalIncome = totalIncome or 0,
			totalUnpaid = totalUnpaid or 0,
			awaitedIncome = awaitedIncome or 0,
			VAT = Config.VATPercentage or 0
		})
	end, society)
end

local function getNearbyPlayers()
	local players = {}
	local myPed = PlayerPedId()
	local myCoords = GetEntityCoords(myPed)
	local maxDistance = Config.InvoiceDistance or 3.0

	for _, player in ipairs(GetActivePlayers()) do
		if player ~= PlayerId() then
			local targetPed = GetPlayerPed(player)
			if DoesEntityExist(targetPed) then
				local targetCoords = GetEntityCoords(targetPed)
				local distance = #(myCoords - targetCoords)
				if distance <= maxDistance then
					players[#players + 1] = {
						id = GetPlayerServerId(player),
						name = GetPlayerName(player) or ('ID ' .. tostring(GetPlayerServerId(player))),
						distance = math.floor(distance * 10) / 10
					}
				end
			end
		end
	end

	table.sort(players, function(a, b)
		return (a.distance or 999) < (b.distance or 999)
	end)

	return players
end

local function CreateInvoice(society)
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'createinvoice',
		society = society,
		nearPlayers = getNearbyPlayers()
	})
end

RegisterCommand(Config.OpenMenuCommand or Config.InvoicesCommand or 'invoices', function()
	if not PlayerData or not PlayerData.job then return end
	local isAllowed = false
	for _, v in pairs(Config.AllowedSocieties or {}) do
		if v == PlayerData.job.name then
			isAllowed = true
			break
		end
	end

	local canSociety = false
	if isAllowed then
		if Config.OnlyBossCanAccessSocietyInvoices then
			canSociety = PlayerData.job.isboss == true
		else
			canSociety = true
		end
	end

	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'mainmenu',
		society = canSociety,
		create = true
	})
end, false)

RegisterNUICallback("action", function(data, cb)
	if data.action == "close" then
		SetNuiFocus(false, false)

	elseif data.action == "payInvoice" then
		TriggerServerEvent("okokBilling:PayInvoice", data.invoice_id)
		SetNuiFocus(false, false)

	elseif data.action == "cancelInvoice" then
		TriggerServerEvent("okokBilling:CancelInvoice", data.invoice_id)
		SetNuiFocus(false, false)

	elseif data.action == "createInvoice" then
		local targetIds = {}
		if type(data.targets) == 'table' then
			for i = 1, #data.targets do
				local sid = tonumber(data.targets[i])
				if sid and sid > 0 then
					targetIds[#targetIds + 1] = sid
				end
			end
			if #targetIds == 0 then
				notify("送信先を1人以上選択してください。", 'error', 10000)
				cb('ok')
				return
			end
		else
			local closestPlayer, playerDistance = QBCore.Functions.GetClosestPlayer()
			if closestPlayer == -1 or playerDistance > (Config.InvoiceDistance or 3.0) then
				notify("請求書の送信に失敗しました。近くにプレイヤーがいません。", 'error', 10000)
				cb('ok')
				return
			end
			targetIds = { GetPlayerServerId(closestPlayer) }
		end

		data.invoice_type = data.invoice_type or "society"

		if data.invoice_type == "personal" then
			data.society = ""
			data.society_name = "個人請求"
		else
			data.society = "society_" .. (PlayerData.job and PlayerData.job.name or "")
			data.society_name = PlayerData.job and PlayerData.job.label or "組織請求"
		end

		local sentCount = 0
		for i = 1, #targetIds do
			local sid = targetIds[i]
			local targetPlayer = GetPlayerFromServerId(sid)
			if targetPlayer and targetPlayer ~= -1 then
				local targetPed = GetPlayerPed(targetPlayer)
				if DoesEntityExist(targetPed) then
					local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(targetPed))
					if distance <= (Config.InvoiceDistance or 3.0) then
						data.target = sid
						TriggerServerEvent("okokBilling:CreateInvoice", data)
						sentCount = sentCount + 1
					end
				end
			end
		end

		if sentCount > 0 then
			notify(("請求書を %s 人に送信しました。"):format(sentCount), 'success', 10000)
		else
			notify("請求書の送信に失敗しました。送信対象が範囲外か無効です。", 'error', 10000)
		end
		SetNuiFocus(false, false)

	elseif data.action == "missingInfo" then
		notify("請求書を送信する前に必須項目を入力してください。", 'error', 10000)

	elseif data.action == "noTargets" then
		notify("送信先を1人以上選択してください。", 'error', 10000)

	elseif data.action == "negativeAmount" then
		notify("金額は1以上で入力してください。", 'error', 10000)

	elseif data.action == "mainMenuOpenMyInvoices" then
		MyInvoices()

	elseif data.action == "mainMenuOpenSocietyInvoices" then
		if not PlayerData.job then cb('ok') return end
		if Config.OnlyBossCanAccessSocietyInvoices and not PlayerData.job.isboss then
			notify("組織請求書はボスのみ閲覧できます。", 'error', 10000)
			cb('ok')
			return
		end
		SocietyInvoices("society_" .. PlayerData.job.name)

	elseif data.action == "mainMenuOpenCreateInvoice" then
		if PlayerData.job then
			CreateInvoice(PlayerData.job.label)
		end

	elseif data.action == "requestNearbyPlayers" then
		SendNUIMessage({
			action = 'updateNearbyPlayers',
			nearPlayers = getNearbyPlayers()
		})
	end

	cb('ok')
end)
