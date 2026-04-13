local QBCore = exports['qb-core']:GetCoreObject()
local actionLocks = {}
local actionCooldowns = {}

local function now()
    return os.time()
end

local function sendNotify(src, message, nType)
    TriggerClientEvent('it_drugs:client:notify', src, message, nType)
end

local function getPoliceCount()
    local count = 0
    local players = QBCore.Functions.GetQBPlayers()

    for _, player in pairs(players) do
        local job = player.PlayerData.job
        if job and job.onduty and Config.PoliceJobs[job.name] then
            count = count + 1
        end
    end

    return count
end

local function getDistance(a, b)
    return #(a - b)
end

local function playerCoords(src)
    local ped = GetPlayerPed(src)
    if ped <= 0 then return nil end
    return GetEntityCoords(ped)
end

local function hasRequiredCops(action)
    local cops = getPoliceCount()
    return cops >= (action.minCops or 0), cops
end

local function withinActionZone(src, action)
    local coords = playerCoords(src)
    if not coords then return false end
    local maxDistance = (action.zone.radius or 1.5) + 2.0
    return getDistance(coords, action.zone.coords) <= maxDistance
end

local function canCarry(src, item, amount)
    return exports.ox_inventory:CanCarryItem(src, item, amount)
end

local function hasItem(src, item, amount)
    local count = exports.ox_inventory:Search(src, 'count', item)
    return (count or 0) >= amount
end

local function startLock(src, actionKey)
    local key = ('%s:%s'):format(src, actionKey)
    if actionLocks[key] then
        return false
    end

    actionLocks[key] = true
    return true
end

local function releaseLock(src, actionKey)
    actionLocks[('%s:%s'):format(src, actionKey)] = nil
end

local function checkCooldown(src, actionKey, action)
    actionCooldowns[src] = actionCooldowns[src] or {}
    local lastAction = actionCooldowns[src][actionKey] or 0
    local cooldown = action.cooldown or 0

    if lastAction > 0 and (now() - lastAction) < cooldown then
        local remain = cooldown - (now() - lastAction)
        if remain < 1 then remain = 1 end
        return false, remain
    end

    return true, 0
end

local function setCooldown(src, actionKey)
    actionCooldowns[src] = actionCooldowns[src] or {}
    actionCooldowns[src][actionKey] = now()
end

local function isProcessUiAction(action)
    return action and action.mode == 'process_ui'
end

lib.callback.register('it_drugs:server:getSerialMaterials', function(source, actionKey)
    local action = Config.Actions[actionKey]
    if not isProcessUiAction(action) then
        return {}
    end

    local items = {}

    for recipeKey, recipe in pairs(Config.ProcessRecipes or {}) do
        local slots = exports.ox_inventory:Search(source, 'slots', recipe.inputItem) or {}
        for i = 1, #slots do
            local slotData = slots[i]
            local metadata = slotData.metadata or {}
            if metadata.serial == 'it_drugs' and (slotData.count or 0) > 0 then
                items[#items + 1] = {
                    slot = slotData.slot,
                    itemName = slotData.name,
                    label = slotData.label or recipe.inputItem,
                    count = slotData.count,
                    recipeKey = recipeKey,
                    recipeLabel = recipe.label,
                    inputPerBatch = recipe.inputPerBatch,
                    outputItem = recipe.outputItem,
                    outputCount = recipe.outputCount
                }
            end
        end
    end

    return items
end)

lib.callback.register('it_drugs:server:canStartAction', function(source, actionKey)
    local action = Config.Actions[actionKey]
    if not action then
        sendNotify(source, '不明なアクションです。', 'error')
        return false
    end

    if not withinActionZone(source, action) then
        sendNotify(source, '対象エリア外です。', 'error')
        return false
    end

    local cooldownOk, remain = checkCooldown(source, actionKey, action)
    if not cooldownOk then
        sendNotify(source, ('クールダウン中です (%s秒)'):format(remain), 'error')
        return false
    end

    local copsOk, cops = hasRequiredCops(action)
    if not copsOk then
        sendNotify(source, ('警察人数が不足しています (%s/%s)'):format(cops, action.minCops), 'error')
        return false
    end

    if not isProcessUiAction(action) and action.requireItem and action.requireCount and not hasItem(source, action.requireItem, action.requireCount) then
        sendNotify(source, ('必要アイテム不足: %s x%s'):format(action.requireItem, action.requireCount), 'error')
        return false
    end

    if not isProcessUiAction(action) and action.giveItem then
        local giveCount = action.giveCount
        if action.amount then
            giveCount = math.random(action.amount.min, action.amount.max)
        end

        if not canCarry(source, action.giveItem, giveCount) then
            sendNotify(source, '所持重量/スロットが足りません。', 'error')
            return false
        end
    end

    return true
end)

lib.callback.register('it_drugs:server:completeProcess', function(source, actionKey, payload)
    local action = Config.Actions[actionKey]
    if not isProcessUiAction(action) then
        sendNotify(source, '製造アクションではありません。', 'error')
        return false
    end

    if not startLock(source, actionKey) then
        sendNotify(source, '処理中です。少し待ってください。', 'error')
        return false
    end

    local ok, result = pcall(function()
        if not withinActionZone(source, action) then
            sendNotify(source, '対象エリア外です。', 'error')
            return false
        end

        local cooldownOk = checkCooldown(source, actionKey, action)
        if not cooldownOk then
            sendNotify(source, '連続実行できません。', 'error')
            return false
        end

        local copsOk = hasRequiredCops(action)
        if not copsOk then
            sendNotify(source, '警察人数が不足しています。', 'error')
            return false
        end

        local recipeKey = payload and payload.recipeKey
        local inputSlot = tonumber(payload and payload.slot)
        local itemName = payload and payload.itemName
        local inputAmount = tonumber(payload and payload.inputAmount) or 0
        local recipe = Config.ProcessRecipes and Config.ProcessRecipes[recipeKey]

        if not recipe then
            sendNotify(source, '無効なレシピです。', 'error')
            return false
        end

        if inputAmount < 1 or inputAmount > 100 then
            sendNotify(source, '投入量が不正です。', 'error')
            return false
        end

        if not inputSlot or inputSlot < 1 then
            sendNotify(source, '素材スロットが不正です。', 'error')
            return false
        end

        if itemName ~= recipe.inputItem then
            sendNotify(source, '素材とレシピが一致しません。', 'error')
            return false
        end

        local inputSlots = exports.ox_inventory:Search(source, 'slots', recipe.inputItem) or {}
        local selectedSlot = nil
        for i = 1, #inputSlots do
            local slotData = inputSlots[i]
            if slotData.slot == inputSlot then
                selectedSlot = slotData
                break
            end
        end

        if not selectedSlot then
            sendNotify(source, '選択した素材が見つかりません。', 'error')
            return false
        end

        local selectedMetadata = selectedSlot.metadata or {}
        if selectedMetadata.serial ~= 'it_drugs' then
            sendNotify(source, 'この素材は精製に使えません。', 'error')
            return false
        end

        if (selectedSlot.count or 0) < inputAmount then
            sendNotify(source, ('素材不足: %s x%s'):format(recipe.inputItem, inputAmount), 'error')
            return false
        end

        local isCorrectMix = inputAmount % recipe.inputPerBatch == 0
        local outputBatches = math.floor(inputAmount / recipe.inputPerBatch)
        local outputAmount = outputBatches * recipe.outputCount
        local wasteAmount = math.max(1, math.floor(inputAmount / recipe.inputPerBatch))

        if isCorrectMix and outputAmount < 1 then
            sendNotify(source, ('最低投入量は %s 個です。'):format(recipe.inputPerBatch), 'error')
            return false
        end

        if isCorrectMix then
            if not canCarry(source, recipe.outputItem, outputAmount) then
                sendNotify(source, '完成品を持てません。', 'error')
                return false
            end
        else
            if not canCarry(source, 'drug_waste', wasteAmount) then
                sendNotify(source, 'ゴミを持てません。', 'error')
                return false
            end
        end

        local removed = exports.ox_inventory:RemoveItem(source, recipe.inputItem, inputAmount, selectedMetadata, inputSlot)
        if not removed then
            sendNotify(source, '原料の消費に失敗しました。', 'error')
            return false
        end

        if isCorrectMix then
            local added = exports.ox_inventory:AddItem(source, recipe.outputItem, outputAmount, { serial = 'it_drugs' })
            if not added then
                sendNotify(source, '完成品の付与に失敗しました。', 'error')
                return false
            end

            sendNotify(source, ('調合成功: %s x%s'):format(recipe.outputItem, outputAmount), 'success')
        else
            exports.ox_inventory:AddItem(source, 'drug_waste', wasteAmount)
            sendNotify(source, ('調合失敗: drug_waste x%s を生成'):format(wasteAmount), 'error')
        end

        setCooldown(source, actionKey)
        return true
    end)

    releaseLock(source, actionKey)

    if not ok then
        print(('[it_drugs] Error on %s from %s: %s'):format(actionKey, source, result))
        sendNotify(source, 'サーバーエラーが発生しました。', 'error')
        return false
    end

    return result
end)

lib.callback.register('it_drugs:server:completeAction', function(source, actionKey)
    local action = Config.Actions[actionKey]
    if not action then
        sendNotify(source, '不明なアクションです。', 'error')
        return false
    end

    if not startLock(source, actionKey) then
        sendNotify(source, '処理中です。少し待ってください。', 'error')
        return false
    end

    local ok, result = pcall(function()
        if not withinActionZone(source, action) then
            sendNotify(source, '対象エリア外です。', 'error')
            return false
        end

        local cooldownOk = checkCooldown(source, actionKey, action)
        if not cooldownOk then
            sendNotify(source, '連続実行できません。', 'error')
            return false
        end

        local copsOk = hasRequiredCops(action)
        if not copsOk then
            sendNotify(source, '警察人数が不足しています。', 'error')
            return false
        end

        if action.requireItem and action.requireCount then
            if not hasItem(source, action.requireItem, action.requireCount) then
                sendNotify(source, '必要アイテムがありません。', 'error')
                return false
            end

            local removed = exports.ox_inventory:RemoveItem(source, action.requireItem, action.requireCount)
            if not removed then
                sendNotify(source, 'アイテムの消費に失敗しました。', 'error')
                return false
            end
        end

        if action.giveItem then
            local giveCount = action.giveCount
            if action.amount then
                giveCount = math.random(action.amount.min, action.amount.max)
            end

            if not canCarry(source, action.giveItem, giveCount) then
                sendNotify(source, '受け取るスペースがありません。', 'error')
                return false
            end

            local added = exports.ox_inventory:AddItem(source, action.giveItem, giveCount, { serial = 'it_drugs' })
            if not added then
                sendNotify(source, 'アイテム付与に失敗しました。', 'error')
                return false
            end

            sendNotify(source, ('%s x%s を入手しました。'):format(action.giveItem, giveCount), 'success')
        end

        if action.payout then
            local amount = math.random(action.payout.min, action.payout.max)
            local player = QBCore.Functions.GetPlayer(source)
            if not player then
                sendNotify(source, 'プレイヤー情報の取得に失敗しました。', 'error')
                return false
            end

            player.Functions.AddMoney(action.account or 'cash', amount, 'drug-sell')
            sendNotify(source, ('$%s を受け取りました。'):format(amount), 'success')
        end

        setCooldown(source, actionKey)
        return true
    end)

    releaseLock(source, actionKey)

    if not ok then
        print(('[it_drugs] Error on %s from %s: %s'):format(actionKey, source, result))
        sendNotify(source, 'サーバーエラーが発生しました。', 'error')
        return false
    end

    return result
end)

AddEventHandler('playerDropped', function()
    local src = source
    actionCooldowns[src] = nil

    for actionKey, _ in pairs(Config.Actions) do
        releaseLock(src, actionKey)
    end
end)

QBCore.Functions.CreateUseableItem('drug_waste', function(source, item)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local removed = exports.ox_inventory:RemoveItem(source, 'drug_waste', 1)
    if not removed then return end

    local currentStress = player.PlayerData.metadata and player.PlayerData.metadata.stress or 0
    local newStress = currentStress - 1
    if newStress < 0 then newStress = 0 end

    player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('it_drugs:client:applyDizzy', source)
    sendNotify(source, '少し落ち着いたが、めまいがする...', 'inform')
end)
