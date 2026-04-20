local QBCore = nil

local function initQBCore()
    if QBCore then return true end

    pcall(function()
        QBCore = exports['qb-core']:GetCoreObject()
    end)

    if not QBCore then
        pcall(function()
            QBCore = exports['qb-core']:GetSharedObject()
        end)
    end

    if not QBCore then
        TriggerEvent('QBCore:GetObject', function(obj)
            QBCore = obj
        end)
    end

    return QBCore ~= nil
end

while not initQBCore() do
    Wait(200)
end

lastRob = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
}
discord = {
    ['webhook'] = 'DISCORDCHANNELWEBHOOKLINK',
    ['name'] = 'rm_fleecaheist',
    ['image'] = 'https://cdn.discordapp.com/avatars/869260464775921675/dea34d25f883049a798a241c8d94020c.png?size=1024'
}

local function giveDirtyMoney(src, player, amount)
    amount = tonumber(amount) or 0
    if amount <= 0 or not player then
        return false
    end

    if GetResourceState('ox_inventory') == 'started' then
        local ok = exports.ox_inventory:AddItem(src, 'black_money', amount)
        if ok then
            return true
        end
    end

    player.Functions.AddMoney('cash', amount)
    return false
end

QBCore.Functions.CreateCallback('fleecaheist:server:checkPoliceCount', function(source, cb)
    local src = source
    local players = QBCore.Functions.GetPlayers()
    local policeCount = 0

    for i = 1, #players do
        local player = QBCore.Functions.GetPlayer(players[i])
        if player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name == 'police' then
            policeCount = policeCount + 1
        end
    end

    if policeCount >= Config['FleecaMain']['requiredPoliceCount'] then
        cb(true)
    else
        cb(false)
        TriggerClientEvent('fleecaheist:client:showNotification', src, Strings['need_police'])
    end
end)

QBCore.Functions.CreateCallback('fleecaheist:server:checkTime', function(source, cb, index)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    
    if (os.time() - lastRob[index]) < Config['FleecaHeist'][index]['nextRob'] and lastRob[index] ~= 0 then
        local seconds = Config['FleecaHeist'][index]['nextRob'] - (os.time() - lastRob[index])
        TriggerClientEvent('fleecaheist:client:showNotification', src, Strings['wait_nextheist'] .. ' ' .. math.floor(seconds / 60) .. ' ' .. Strings['minute'])
        cb(false)
    else
        lastRob[index] = os.time()
        discordLog(player.PlayerData.name ..  ' - ' .. player.PlayerData.license, ' started the Fleeca Heist!')
        cb(true)
    end
end)

QBCore.Functions.CreateCallback('fleecaheist:server:hasItem', function(source, cb, item)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if not player then
        cb(false, tostring(item or 'item'))
        return
    end

    local playerItem = item and player.Functions.GetItemByName(item) or nil
    local itemAmount = 0
    if playerItem then
        itemAmount = tonumber(playerItem.amount) or tonumber(playerItem.count) or 0
    end

    if playerItem and itemAmount >= 1 then
        cb(true, playerItem.label or tostring(item))
        return
    end

    local fallbackLabel = tostring(item or 'item')
    if QBCore.Shared and QBCore.Shared.Items and item and QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label then
        fallbackLabel = QBCore.Shared.Items[item].label
    end
    cb(false, fallbackLabel)
end)

RegisterNetEvent('fleecaheist:server:policeAlert')
AddEventHandler('fleecaheist:server:policeAlert', function(coords)
    local players = QBCore.Functions.GetPlayers()
    
    for i = 1, #players do
        local player = QBCore.Functions.GetPlayer(players[i])
        if player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name == 'police' then
            TriggerClientEvent('fleecaheist:client:policeAlert', players[i], coords)
        end
    end
end)

RegisterServerEvent('fleecaheist:server:rewardItem')
AddEventHandler('fleecaheist:server:rewardItem', function(reward, count)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if player then
        if reward.item ~= nil then
            if count ~= nil then
                player.Functions.AddItem(reward.item, count)
            else
                player.Functions.AddItem(reward.item, reward.count)
            end
        else
            if count ~= nil then
                giveDirtyMoney(src, player, count)
            else
                giveDirtyMoney(src, player, reward.count)
            end
        end
    end
end)

RegisterServerEvent('fleecaheist:server:sellRewardItems')
AddEventHandler('fleecaheist:server:sellRewardItems', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if player then
        local totalMoney = 0
        local rewardItems = Config['FleecaMain']['rewardItems']
        local diamondCount = player.Functions.GetItemByName(rewardItems['diamondTrolly']['item'])
        local goldCount = player.Functions.GetItemByName(rewardItems['goldTrolly']['item'])

        if diamondCount ~= nil and diamondCount.amount > 0 then
            player.Functions.RemoveItem(rewardItems['diamondTrolly']['item'], diamondCount.amount)
            giveDirtyMoney(src, player, rewardItems['diamondTrolly']['sellPrice'] * diamondCount.amount)
            totalMoney = totalMoney + (rewardItems['diamondTrolly']['sellPrice'] * diamondCount.amount)
        end
        if goldCount ~= nil and goldCount.amount > 0 then
            player.Functions.RemoveItem(rewardItems['goldTrolly']['item'], goldCount.amount)
            giveDirtyMoney(src, player, rewardItems['goldTrolly']['sellPrice'] * goldCount.amount)
            totalMoney = totalMoney + (rewardItems['goldTrolly']['sellPrice'] * goldCount.amount)
        end

        discordLog(player.PlayerData.name ..  ' - ' .. player.PlayerData.license, ' Gain $' .. totalMoney .. ' on the Fleeca Heist Buyer!')
        TriggerClientEvent('fleecaheist:client:showNotification', src, Strings['total_money'] .. ' $' .. totalMoney)
    end
end)

RegisterServerEvent('fleecaheist:server:doorSync')
AddEventHandler('fleecaheist:server:doorSync', function(index)
    TriggerClientEvent('fleecaheist:client:doorSync', -1, index)
end)

RegisterServerEvent('fleecaheist:server:lootSync')
AddEventHandler('fleecaheist:server:lootSync', function(index, type, k)
    TriggerClientEvent('fleecaheist:client:lootSync', -1, index, type, k)
end)

RegisterServerEvent('fleecaheist:server:modelSync')
AddEventHandler('fleecaheist:server:modelSync', function(index, k, model)
    TriggerClientEvent('fleecaheist:client:modelSync', -1, index, k, model)
end)

RegisterServerEvent('fleecaheist:server:grabSync')
AddEventHandler('fleecaheist:server:grabSync', function(index, k, model)
    TriggerClientEvent('fleecaheist:client:grabSync', -1, index, k, model)
end)

RegisterServerEvent('fleecaheist:server:resetHeist')
AddEventHandler('fleecaheist:server:resetHeist', function(index)
    TriggerClientEvent('fleecaheist:client:resetHeist', -1, index)
end)

RegisterCommand('pdfleeca', function(source, args)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    
    if player then
        if player.PlayerData.job.name == 'police' then
            TriggerClientEvent('fleecaheist:client:nearBank', src)
        else
            TriggerClientEvent('fleecaheist:client:showNotification', src, 'You are not cop!')
        end
    end
end)

function discordLog(name, message)
    local data = {
        {
            ["color"] = '3553600',
            ["title"] = "**".. name .."**",
            ["description"] = message,
        }
    }
    PerformHttpRequest(discord['webhook'], function(err, text, headers) end, 'POST', json.encode({username = discord['name'], embeds = data, avatar_url = discord['image']}), { ['Content-Type'] = 'application/json' })
end