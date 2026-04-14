local QBCore = exports['qb-core']:GetCoreObject()

local Webhook = ''
local tableName = Config.DatabaseTable or 'okokBilling'
local limitDays = tonumber(Config.LimitDateDays or Config.DefaultLimitDate or 7) or 7
local whenToAddFees = {}

for i = 1, limitDays, 1 do
	whenToAddFees[#whenToAddFees + 1] = (limitDays - i) * 24
end

local function notifyPlayer(target, message, nType, length)
	if not target then return end
	if GetResourceState('okokNotify') == 'started' and (Config.UseOKOKNotify == nil or Config.UseOKOKNotify) then
		TriggerClientEvent('okokNotify:Alert', target, "請求書", message, length or 10000, nType or 'primary')
	else
		TriggerClientEvent('QBCore:Notify', target, message, nType or 'primary', length or 10000)
	end
end

local function getPlayerFullName(player)
	if not player or not player.PlayerData then return 'Unknown' end
	local charinfo = player.PlayerData.charinfo or {}
	local firstname = charinfo.firstname or ''
	local lastname = charinfo.lastname or ''
	local fullname = (firstname .. ' ' .. lastname):gsub('^%s*(.-)%s*$', '%1')
	if fullname ~= '' then return fullname end
	return GetPlayerName(player.PlayerData.source) or 'Unknown'
end

local function getOnlinePlayerByName(name)
	local targetName = tostring(name or ''):gsub('^%s*(.-)%s*$', '%1')
	if targetName == '' then return nil end
	local players = QBCore.Functions.GetQBPlayers() or {}
	for _, player in pairs(players) do
		local fullName = getPlayerFullName(player)
		if fullName == targetName or GetPlayerName(player.PlayerData.source) == targetName then
			return player
		end
	end
	return nil
end

local function addSocietyMoney(societyAccount, amount)
	local jobName = tostring(societyAccount or ''):gsub('^society_', '')
	if jobName == '' then return false end
	if GetResourceState('qb-management') ~= 'started' then return false end
	local ok = pcall(function()
		exports['qb-management']:AddMoney(jobName, amount)
	end)
	return ok
end

local function addMoneyToCitizen(citizenId, amount, reason, cb, fallbackName)
	local identifier = tostring(citizenId or ''):gsub('^%s*(.-)%s*$', '%1')
	if identifier == '' then
		local fallbackPlayer = getOnlinePlayerByName(fallbackName)
		if fallbackPlayer then
			fallbackPlayer.Functions.AddMoney('bank', amount, reason or 'billing-income')
			cb(true, fallbackPlayer.PlayerData.source)
			return
		end
		cb(false)
		return
	end

	local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
	if not player and QBCore.Functions.GetPlayerByLicense then
		player = QBCore.Functions.GetPlayerByLicense(identifier)
	end
	if not player and fallbackName then
		player = getOnlinePlayerByName(fallbackName)
	end
	if player then
		player.Functions.AddMoney('bank', amount, reason or 'billing-income')
		cb(true, player.PlayerData.source)
		return
	end

	MySQL.Async.fetchAll('SELECT citizenid, money FROM players WHERE citizenid = @id OR license = @id LIMIT 1', {
		['@id'] = identifier
	}, function(result)
		if not result or not result[1] or not result[1].money then
			cb(false)
			return
		end
		local money = json.decode(result[1].money) or {}
		money.bank = (money.bank or 0) + amount
		MySQL.Async.execute('UPDATE players SET money = @money WHERE citizenid = @id', {
			['@money'] = json.encode(money),
			['@id'] = result[1].citizenid
		}, function(changed)
			cb((changed or 0) > 0)
		end)
	end)
end

local function removeMoneyFromCitizen(citizenId, amount, cb)
	local identifier = tostring(citizenId or ''):gsub('^%s*(.-)%s*$', '%1')
	if identifier == '' then
		cb(false)
		return
	end

	local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
	if not player and QBCore.Functions.GetPlayerByLicense then
		player = QBCore.Functions.GetPlayerByLicense(identifier)
	end
	if player then
		cb(player.Functions.RemoveMoney('bank', amount, 'billing-revert') == true)
		return
	end

	MySQL.Async.fetchAll('SELECT citizenid, money FROM players WHERE citizenid = @id OR license = @id LIMIT 1', {
		['@id'] = identifier
	}, function(result)
		if not result or not result[1] or not result[1].money then
			cb(false)
			return
		end
		local money = json.decode(result[1].money) or {}
		local bank = tonumber(money.bank) or 0
		if bank < amount then
			cb(false)
			return
		end
		money.bank = bank - amount
		MySQL.Async.execute('UPDATE players SET money = @money WHERE citizenid = @id', {
			['@money'] = json.encode(money),
			['@id'] = result[1].citizenid
		}, function(changed)
			cb((changed or 0) > 0)
		end)
	end)
end

local function distributePayment(invoice, amount, cb)
	local total = math.ceil(tonumber(amount) or 0)
	if total <= 0 then
		cb(false)
		return
	end

	local invoiceType = tostring(invoice.invoice_type or '')
	local isSocietyInvoice = invoiceType == 'society' or tostring(invoice.society or ''):match('^society_') ~= nil

	if not isSocietyInvoice then
		addMoneyToCitizen(invoice.author_identifier, total, 'billing-personal-income', function(ok, authorSource)
			if ok and authorSource then
				notifyPlayer(authorSource, ("個人請求の入金: %s￥"):format(total), 'success', 8000)
			end
			cb(ok)
		end, invoice.author_name)
		return
	end

	local authorShare = math.floor(total * 0.6)
	local societyShare = total - authorShare

	addMoneyToCitizen(invoice.author_identifier, authorShare, 'billing-author-share', function(authorOk, authorSource)
		if not authorOk then
			cb(false)
			return
		end

		local societyOk = true
		if societyShare > 0 then
			societyOk = addSocietyMoney(invoice.society, societyShare)
		end

		if not societyOk then
			removeMoneyFromCitizen(invoice.author_identifier, authorShare, function()
				cb(false)
			end)
			return
		end

		if authorSource then
			notifyPlayer(authorSource, ("組織請求の個人取り分: %s￥"):format(authorShare), 'success', 8000)
		end
		cb(true)
	end, invoice.author_name)
end

QBCore.Functions.CreateCallback("okokBilling:GetInvoices", function(source, cb)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if not xPlayer then cb({}) return end

	MySQL.Async.fetchAll(('SELECT * FROM %s WHERE receiver_identifier = @identifier ORDER BY CASE WHEN status = "unpaid" THEN 1 WHEN status = "autopaid" THEN 2 WHEN status = "paid" THEN 3 WHEN status = "cancelled" THEN 4 END ASC, id DESC'):format(tableName), {
		['@identifier'] = xPlayer.PlayerData.citizenid
	}, function(result)
		cb(result or {})
	end)
end)

RegisterServerEvent("okokBilling:PayInvoice")
AddEventHandler("okokBilling:PayInvoice", function(invoice_id)
	local src = source
	local payer = QBCore.Functions.GetPlayer(src)
	if not payer then return end

	MySQL.Async.fetchAll(('SELECT * FROM %s WHERE id = @id'):format(tableName), {
		['@id'] = invoice_id
	}, function(result)
		local invoice = result and result[1]
		if not invoice then return end

		local amount = math.ceil(tonumber(invoice.invoice_value) or 0)
		local bank = payer.PlayerData.money and payer.PlayerData.money.bank or 0
		if bank < amount then
			notifyPlayer(src, "所持金が不足しています。", 'error', 10000)
			return
		end

		payer.Functions.RemoveMoney('bank', amount, 'billing-invoice')
		distributePayment(invoice, amount, function(ok)
			if not ok then
				payer.Functions.AddMoney('bank', amount, 'billing-refund')
				notifyPlayer(src, "入金処理失敗のため返金しました。", 'error', 10000)
				return
			end

			MySQL.Async.execute(('UPDATE %s SET status = "paid", paid_date = CURRENT_TIMESTAMP WHERE id = @id'):format(tableName), {
				['@id'] = invoice_id
			})
			notifyPlayer(src, "請求書を支払いました。", 'success', 10000)
		end)
	end)
end)

RegisterServerEvent("okokBilling:CancelInvoice")
AddEventHandler("okokBilling:CancelInvoice", function(invoice_id)
	local src = source
	MySQL.Async.execute(('UPDATE %s SET status = "cancelled", paid_date = CURRENT_TIMESTAMP WHERE id = @id'):format(tableName), {
		['@id'] = invoice_id
	})
	notifyPlayer(src, "請求書をキャンセルしました。", 'primary', 10000)
end)

RegisterServerEvent("okokBilling:CreateInvoice")
AddEventHandler("okokBilling:CreateInvoice", function(data)
	local src = source
	local author = QBCore.Functions.GetPlayer(src)
	local target = QBCore.Functions.GetPlayer(tonumber(data.target))
	if not author or not target then return end

	local invoiceType = data.invoice_type == 'personal' and 'personal' or 'society'
	local society = invoiceType == 'personal' and '' or (data.society or '')
	local societyName = invoiceType == 'personal' and '個人請求' or (data.society_name or '')
	local limitDate = (Config.LimitDate == false and 'N/A') or tostring(limitDays)

	local insertQuery = ('INSERT INTO %s (receiver_identifier, receiver_name, author_identifier, author_name, society, society_name, item, invoice_value, status, notes, sent_date, limit_pay_date) VALUES (@receiver_identifier, @receiver_name, @author_identifier, @author_name, @society, @society_name, @item, @invoice_value, "unpaid", @notes, CURRENT_TIMESTAMP(), %s)'):format(
		tableName,
		Config.LimitDate == false and '@limit_pay_date' or 'DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL @limit_pay_date DAY)'
	)

	MySQL.Async.insert(insertQuery, {
		['@receiver_identifier'] = target.PlayerData.citizenid,
		['@receiver_name'] = getPlayerFullName(target),
		['@author_identifier'] = author.PlayerData.citizenid,
		['@author_name'] = getPlayerFullName(author),
		['@society'] = society,
		['@society_name'] = societyName,
		['@item'] = data.invoice_item,
		['@invoice_value'] = tonumber(data.invoice_value) or 0,
		['@notes'] = data.invoice_notes or '',
		['@limit_pay_date'] = limitDate
	}, function()
		-- Use QBCore notify for invoice receive to avoid low-contrast overlays.
		TriggerClientEvent('QBCore:Notify', target.PlayerData.source, "新しい請求書を受け取りました。", 'success', 10000)
	end)
end)

QBCore.Functions.CreateCallback("okokBilling:GetSocietyInvoices", function(source, cb, society)
	MySQL.Async.fetchAll(('SELECT * FROM %s WHERE society = @society ORDER BY id DESC'):format(tableName), {
		['@society'] = society
	}, function(result)
		local invoices = result or {}
		local totalInvoices, totalIncome, totalUnpaid, awaitedIncome = 0, 0, 0, 0
		for i = 1, #invoices do
			totalInvoices = totalInvoices + 1
			if invoices[i].status == 'paid' then
				totalIncome = totalIncome + (tonumber(invoices[i].invoice_value) or 0)
			elseif invoices[i].status == 'unpaid' then
				totalUnpaid = totalUnpaid + 1
				awaitedIncome = awaitedIncome + (tonumber(invoices[i].invoice_value) or 0)
			end
		end
		cb(invoices, totalInvoices, totalIncome, totalUnpaid, awaitedIncome)
	end)
end)

local function checkTimeLeft()
	MySQL.Async.fetchAll(('SELECT *, TIMESTAMPDIFF(HOUR, limit_pay_date, CURRENT_TIMESTAMP()) AS "timeLeft" FROM %s WHERE status = "unpaid"'):format(tableName), {}, function(result)
		for i = 1, #(result or {}) do
			local row = result[i]
			if row and row.receiver_identifier then
				local valueWithFee = (tonumber(row.invoice_value) or 0) * (tonumber(Config.FeeAfterEachDayPercentage or 0) / 100 + 1)
				if row.timeLeft and row.timeLeft < 0 and Config.FeeAfterEachDay then
					for feeStep, triggerHour in pairs(whenToAddFees) do
						if row.fees_amount == feeStep - 1 and row.timeLeft >= triggerHour * (-1) then
							MySQL.Async.execute(('UPDATE %s SET fees_amount = @fees_amount, invoice_value = @invoice_value WHERE id = @id'):format(tableName), {
								['@fees_amount'] = feeStep,
								['@invoice_value'] = valueWithFee,
								['@id'] = row.id
							})
						end
					end
				elseif row.timeLeft and row.timeLeft >= 0 and Config.PayAutomaticallyAfterLimit then
					local payer = QBCore.Functions.GetPlayerByCitizenId(row.receiver_identifier)
					if payer then
						payer.Functions.RemoveMoney('bank', valueWithFee, 'billing-autopay')
					else
						removeMoneyFromCitizen(row.receiver_identifier, valueWithFee, function() end)
					end

					distributePayment(row, valueWithFee, function(ok)
						if ok then
							MySQL.Async.execute(('UPDATE %s SET status = "autopaid", paid_date = CURRENT_TIMESTAMP() WHERE id = @id'):format(tableName), {
								['@id'] = row.id
							})
						else
							if payer then
								payer.Functions.AddMoney('bank', valueWithFee, 'billing-autopay-refund')
							else
								addMoneyToCitizen(row.receiver_identifier, valueWithFee, 'billing-autopay-refund', function() end)
							end
						end
					end)
				end
			end
		end
	end)
	SetTimeout(30 * 60000, checkTimeLeft)
end

if Config.PayAutomaticallyAfterLimit then
	checkTimeLeft()
end
