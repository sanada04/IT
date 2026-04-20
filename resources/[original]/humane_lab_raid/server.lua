local QBCore = exports['qb-core']:GetCoreObject()

local function getItemCount(src, itemName)
    if GetResourceState('ox_inventory') == 'started' then
        local ok, count = pcall(function()
            return exports.ox_inventory:GetItemCount(src, itemName)
        end)
        if ok then
            return count or 0
        end
    end

    local player = QBCore.Functions.GetPlayer(src)
    if not player then return 0 end
    local item = player.Functions.GetItemByName(itemName)
    return (item and item.amount) or 0
end

local function addItem(src, itemName, amount)
    if GetResourceState('ox_inventory') == 'started' then
        local ok, err = exports.ox_inventory:AddItem(src, itemName, amount)
        return ok, err
    end

    local player = QBCore.Functions.GetPlayer(src)
    if not player then return false, 'no_player' end
    player.Functions.AddItem(itemName, amount)
    return true, nil
end

local function removeItem(src, itemName, amount)
    if GetResourceState('ox_inventory') == 'started' then
        local ok = exports.ox_inventory:RemoveItem(src, itemName, amount)
        return ok, ok and nil or 'remove_failed'
    end

    local player = QBCore.Functions.GetPlayer(src)
    if not player then return false, 'no_player' end
    player.Functions.RemoveItem(itemName, amount)
    return true, nil
end

lib.callback.register('humane_lab_raid:server:rewardUsb', function(source)
    local src = source
    local terminal = Config.DataTerminal
    if not terminal or not terminal.coords then
        return { ok = false, reason = 'invalid_config' }
    end

    local ped = GetPlayerPed(src)
    if ped == 0 then
        return { ok = false, reason = 'invalid_ped' }
    end

    local pos = GetEntityCoords(ped)
    local maxDist = (terminal.radius or 1.5) + 1.5
    if #(pos - terminal.coords) > maxDist then
        return { ok = false, reason = 'too_far' }
    end

    local itemName = terminal.rewardItem or 'humane_usb'
    local amount = terminal.rewardCount or 1

    if getItemCount(src, itemName) > 0 then
        return { ok = false, reason = 'already_has' }
    end

    local ok, err = addItem(src, itemName, amount)
    if not ok then
        return { ok = false, reason = err or 'add_failed' }
    end

    return { ok = true, item = itemName, amount = amount }
end)

lib.callback.register('humane_lab_raid:server:exchangeData', function(source)
    local src = source
    local cfg = Config.Exchange or {}
    local reqItem = cfg.requiredItem or 'humane_usb'
    local reqCount = cfg.requiredCount or 1
    local rewardItem = cfg.rewardItem or 'black_money'
    local minReward = cfg.rewardMin or 25000
    local maxReward = cfg.rewardMax or minReward

    local ped = GetPlayerPed(src)
    if ped == 0 then
        return { ok = false, reason = 'invalid_ped' }
    end

    local npc = Config.QuestNpc
    if npc and npc.coords then
        local pos = GetEntityCoords(ped)
        local npcPos = vec3(npc.coords.x, npc.coords.y, npc.coords.z)
        if #(pos - npcPos) > 4.0 then
            return { ok = false, reason = 'too_far' }
        end
    end

    if getItemCount(src, reqItem) < reqCount then
        return { ok = false, reason = 'no_usb' }
    end

    local removed = removeItem(src, reqItem, reqCount)
    if not removed then
        return { ok = false, reason = 'remove_failed' }
    end

    local payout = math.random(minReward, maxReward)
    local rewarded = addItem(src, rewardItem, payout)
    if not rewarded then
        addItem(src, reqItem, reqCount)
        return { ok = false, reason = 'reward_failed' }
    end

    return { ok = true, amount = payout }
end)
