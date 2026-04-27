math.randomseed(os.time())
local QBCore = exports['qb-core']:GetCoreObject()
ESX = {}
isRoll = false
local car = Config.Cars[math.random(#Config.Cars)]

local function _U(key, ...)
    local locale = (Locales and Locales[Config.Locale] and Locales[Config.Locale][key]) or key
    if select('#', ...) > 0 then
        return string.format(locale, ...)
    end
    return locale
end

local function getWrappedPlayer(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end

    local char = Player.PlayerData.charinfo or {}
    local fullName = ((char.firstname or '') .. ' ' .. (char.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')

    return {
        source = source,
        identifier = Player.PlayerData.citizenid,
        name = fullName ~= '' and fullName or ('Player ' .. source),
        getInventoryItem = function(itemName)
            local item = Player.Functions.GetItemByName(itemName)
            local amount = item and (item.amount or item.count) or 0
            return { count = amount, amount = amount }
        end,
        removeInventoryItem = function(itemName, count)
            Player.Functions.RemoveItem(itemName, count)
        end,
        addInventoryItem = function(itemName, count)
            Player.Functions.AddItem(itemName, count)
        end,
        addAccountMoney = function(account, amount)
            local moneyType = account == 'bank' and 'bank' or 'cash'
            Player.Functions.AddMoney(moneyType, amount)
        end,
        addWeapon = function(weaponName, _ammo)
            -- QBCoreでは武器をアイテムとして付与
            Player.Functions.AddItem(weaponName, 1)
        end
    }
end

ESX.GetPlayerFromId = function(source)
    return getWrappedPlayer(source)
end

ESX.RegisterServerCallback = function(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

ESX.GetItemLabel = function(name) return name end
ESX.GetWeaponLabel = function(name) return name end
ESX.Math = {
    GroupDigits = function(value)
        return tostring(value)
    end
}

if Config.DailySpin then
	TriggerEvent('cron:runAt', Config.ResetSpin.h, Config.ResetSpin.m, ResetSpins)
end


function ResetSpins(d, h, m)
	MySQL.Sync.execute('UPDATE users SET wheel = 0')
end

ESX.RegisterServerCallback('luckywheel:getcar', function(source, cb)
	cb(car)
end)

RegisterServerEvent('luckywheel:getwheel')
AddEventHandler('luckywheel:getwheel', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	if Config.DailySpin == true then
		MySQL.Async.fetchScalar('SELECT wheel FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(dwheel)
			if dwheel == '0' then
				TriggerEvent("luckywheel:startwheel", xPlayer, _source)
			else
				TriggerClientEvent('esx:showNotification', _source, _U('already_spin'))
			end
		end)
	elseif Config.DailySpin == false then
		local cash = 0
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer ~= nil then
            cash = xPlayer.getInventoryItem('cchip').count
        end

		if cash >= Config.SpinMoney then
			TriggerEvent("luckywheel:startwheel", xPlayer, _source)
			xPlayer.removeInventoryItem('cchip', Config.SpinMoney)
		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_money'))
		end

		--[[if xPlayer.getMoney() >= Config.SpinMoney then
			TriggerEvent("luckywheel:startwheel", xPlayer, _source)
			xPlayer.removeMoney(Config.SpinMoney)
		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_money'))
		end]]--
	end
end)	
	
	

RegisterServerEvent('luckywheel:startwheel')
AddEventHandler('luckywheel:startwheel', function(xPlayer, source)
    local _source = source
    if not isRoll then
        if xPlayer ~= nil then
			if Config.DailySpin and xPlayer.identifier then
				MySQL.Sync.execute('UPDATE users SET wheel = @wheel WHERE identifier = @identifier', {
					['@identifier'] = xPlayer.identifier,
					['@wheel'] = '1'
				})
			end
			isRoll = true
			local rnd = math.random(1, 1000)
			local price = 0
			local priceIndex = 0
			for k,v in pairs(Config.Prices) do
				if (rnd > v.probability.a) and (rnd <= v.probability.b) then
					price = v
					priceIndex = k
					break
				end
			end
			TriggerClientEvent("luckywheel:syncanim", _source, priceIndex)
			TriggerClientEvent("luckywheel:startroll", -1, _source, priceIndex, price)
		end
	end
end)

RegisterServerEvent('luckywheel:give')
AddEventHandler('luckywheel:give', function(s, price)
    local _s = s
	local xPlayer = ESX.GetPlayerFromId(_s)
	isRoll = false
	if price.type == 'car' then
		TriggerClientEvent("luckywheel:winCar", _s, car)
		TriggerClientEvent('esx:showNotification', _s, _U('you_won_car'))
	elseif price.type == 'item' then
		xPlayer.addInventoryItem(price.name, price.count)
		TriggerClientEvent('esx:showNotification', _s, _U('you_won_item', price.count, ESX.GetItemLabel(price.name)))
	elseif price.type == 'money' then
		xPlayer.addAccountMoney('bank', price.count)
		TriggerClientEvent('esx:showNotification', _s, _U('you_won_money', price.count))
	elseif price.type == 'weapon' then
		xPlayer.addWeapon(price.name, 0)
		TriggerClientEvent('esx:showNotification', _s, _U('you_won_weapon', ESX.GetWeaponLabel(price.name)))
	end
	TriggerClientEvent("luckywheel:rollFinished", -1)
end)

RegisterServerEvent('luckywheel:stoproll')
AddEventHandler('luckywheel:stoproll', function()
	isRoll = false
end)