local QBCore = exports['qb-core']:GetCoreObject()
local actionLocks = {}
local actionCooldowns = {}
local defaultProcessMaterials = {
    'wild_herb',
    'poppy_seed',
    'coca_leaf',
    'hallucinogenic_mushroom',
    'cactus',
    'medicinal_flower',
    'fermented_fruit',
    'resin',
    'seaweed',
    'contaminated_plant',
    'solvent_alcohol',
    'strong_solvent',
    'acidic_liquid',
    'alkaline_liquid',
    'chemical_reagent_a',
    'chemical_reagent_b',
    'catalyst',
    'purified_water',
    'filter_material',
    'crystallization_powder'
}

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
    if GetResourceState('ox_inventory') ~= 'started' then
        return true
    end

    local ok, result = pcall(function()
        return exports.ox_inventory:CanCarryItem(src, item, amount)
    end)

    if ok then
        return result
    end

    return true
end

local function hasItem(src, item, amount)
    local ok, count = pcall(function()
        return exports.ox_inventory:Search(src, 'count', item)
    end)
    if not ok then return false end
    return (count or 0) >= amount
end

local function getRecipeInputs(recipe)
    if type(recipe) ~= 'table' then
        return nil
    end

    if type(recipe.inputs) == 'table' then
        local normalized = {}
        for itemName, perBatch in pairs(recipe.inputs) do
            local required = tonumber(perBatch) or 0
            if type(itemName) == 'string' and itemName ~= '' and required > 0 then
                normalized[itemName] = math.floor(required)
            end
        end
        if next(normalized) ~= nil then
            return normalized
        end
    end

    if recipe.inputItem and recipe.inputPerBatch then
        local required = tonumber(recipe.inputPerBatch) or 0
        if required > 0 then
            return {
                [recipe.inputItem] = math.floor(required)
            }
        end
    end

    return nil
end

local function getSerialSlots(src, itemName)
    local slots = exports.ox_inventory:Search(src, 'slots', itemName) or {}
    local filtered = {}
    for i = 1, #slots do
        local slotData = slots[i]
        local metadata = slotData.metadata or {}
        if metadata.serial == 'it_drugs' and (slotData.count or 0) > 0 then
            filtered[#filtered + 1] = slotData
        end
    end
    return filtered
end

local function getSerialItemCount(src, itemName)
    local total = 0
    local slots = getSerialSlots(src, itemName)
    for i = 1, #slots do
        total = total + (slots[i].count or 0)
    end
    return total
end

local function consumeSerialItem(src, itemName, amount)
    local remain = tonumber(amount) or 0
    if remain <= 0 then
        return true
    end

    local slots = getSerialSlots(src, itemName)
    for i = 1, #slots do
        if remain <= 0 then
            break
        end

        local slotData = slots[i]
        local take = math.min(remain, slotData.count or 0)
        if take > 0 then
            local metadata = slotData.metadata or {}
            local removed = exports.ox_inventory:RemoveItem(src, itemName, take, metadata, slotData.slot)
            if not removed then
                return false
            end
            remain = remain - take
        end
    end

    return remain <= 0
end

local function getItemDisplayData(itemName)
    local label = itemName
    local image = ('%s.png'):format(itemName)

    local ok, itemData = pcall(function()
        return exports.ox_inventory:Items(itemName)
    end)

    if ok and type(itemData) == 'table' then
        label = itemData.label or label
        image = itemData.image or image
    end

    return label, image
end

local function getRequestedInputs(inputMap)
    local requested = {}
    local count = 0

    if type(inputMap) ~= 'table' then
        return requested, count
    end

    for itemName, rawAmount in pairs(inputMap) do
        if type(itemName) == 'string' and itemName ~= '' then
            local amount = math.floor(tonumber(rawAmount) or 0)
            if amount > 0 then
                requested[itemName] = amount
                count = count + 1
            end
        end
    end

    return requested, count
end

local function findMatchedRecipe(requestedInputs, requestedCount)
    for recipeKey, recipe in pairs(Config.ProcessRecipes or {}) do
        local recipeInputs = getRecipeInputs(recipe)
        if recipeInputs then
            local recipeCount = 0
            local expectedBatches = nil
            local valid = true

            for itemName, perBatch in pairs(recipeInputs) do
                recipeCount = recipeCount + 1
                local amount = requestedInputs[itemName]
                if not amount or amount < 1 then
                    valid = false
                    break
                end

                if amount % perBatch ~= 0 then
                    valid = false
                    break
                end

                local batches = math.floor(amount / perBatch)
                if batches < 1 then
                    valid = false
                    break
                end

                if expectedBatches == nil then
                    expectedBatches = batches
                elseif expectedBatches ~= batches then
                    valid = false
                    break
                end
            end

            if valid and recipeCount == requestedCount then
                for itemName, _ in pairs(requestedInputs) do
                    if not recipeInputs[itemName] then
                        valid = false
                        break
                    end
                end
            end

            if valid then
                return recipeKey, recipe, recipeInputs, expectedBatches or 0
            end
        end
    end

    return nil, nil, nil, 0
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
        return { recipes = {} }
    end

    local recipeList = {}
    local materialMap = {}

    local function appendMaterial(itemName)
        if type(itemName) ~= 'string' or itemName == '' then
            return
        end

        local itemLabel, itemImage = getItemDisplayData(itemName)
        materialMap[itemName] = {
            itemName = itemName,
            label = itemLabel,
            image = itemImage,
            owned = getSerialItemCount(source, itemName)
        }
    end

    for i = 1, #defaultProcessMaterials do
        appendMaterial(defaultProcessMaterials[i])
    end
    for recipeKey, recipe in pairs(Config.ProcessRecipes or {}) do
        local inputs = getRecipeInputs(recipe)
        if inputs then
            local uiInputs = {}
            local ingredientCount = 0
            local minPossibleBatches = nil

            for itemName, required in pairs(inputs) do
                local owned = getSerialItemCount(source, itemName)
                local possibleBatches = math.floor(owned / required)
                local itemLabel, itemImage = getItemDisplayData(itemName)
                ingredientCount = ingredientCount + 1

                if minPossibleBatches == nil or possibleBatches < minPossibleBatches then
                    minPossibleBatches = possibleBatches
                end

                uiInputs[#uiInputs + 1] = {
                    itemName = itemName,
                    label = itemLabel,
                    image = itemImage,
                    required = required,
                    owned = owned
                }
                appendMaterial(itemName)
            end

            recipeList[#recipeList + 1] = {
                recipeKey = recipeKey,
                recipeLabel = recipe.label or recipeKey,
                outputItem = recipe.outputItem,
                outputCount = recipe.outputCount or 1,
                ingredientCount = ingredientCount,
                canCraftBatches = minPossibleBatches or 0,
                inputs = uiInputs
            }
        end
    end

    local materials = {}
    for _, data in pairs(materialMap) do
        materials[#materials + 1] = data
    end

    table.sort(materials, function(a, b)
        return (a.label or a.itemName) < (b.label or b.itemName)
    end)

    return {
        recipes = recipeList,
        materials = materials
    }
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

        local inputMap = payload and payload.inputs or {}
        local requestedInputs, requestedCount = getRequestedInputs(inputMap)

        if requestedCount < 1 then
            sendNotify(source, '投入する素材を選択してください。', 'error')
            return false
        end

        local consumableInputs = {}
        local totalConsumable = 0
        local hasShortage = false
        local totalRequested = 0

        for itemName, requested in pairs(requestedInputs) do
            if requested < 1 or requested > 1000 then
                sendNotify(source, ('投入量が不正です: %s'):format(itemName), 'error')
                return false
            end

            local owned = getSerialItemCount(source, itemName)
            local consumable = math.min(requested, owned)

            consumableInputs[itemName] = consumable
            totalRequested = totalRequested + requested
            totalConsumable = totalConsumable + consumable

            if owned < requested then
                hasShortage = true
            end

        end

        local matchedRecipeKey, matchedRecipe, _, expectedBatches = findMatchedRecipe(requestedInputs, requestedCount)
        local isSuccess = (matchedRecipe ~= nil) and (not hasShortage) and expectedBatches > 0
        local outputAmount = isSuccess and (expectedBatches * (matchedRecipe.outputCount or 1)) or 0
        local wasteAmount = math.max(1, math.floor(totalConsumable / math.max(1, requestedCount)))

        if isSuccess then
            if outputAmount < 1 then
                sendNotify(source, '投入量が足りません。', 'error')
                return false
            end

            if not canCarry(source, matchedRecipe.outputItem, outputAmount) then
                sendNotify(source, '完成品を持てません。', 'error')
                return false
            end
        else
            if not canCarry(source, 'drug_waste', wasteAmount) then
                sendNotify(source, 'ゴミを持てません。', 'error')
                return false
            end
        end

        for itemName, amount in pairs(consumableInputs) do
            if amount > 0 then
                local removed = consumeSerialItem(source, itemName, amount)
                if not removed then
                    sendNotify(source, '原料の消費に失敗しました。', 'error')
                    return false
                end
            end
        end

        if isSuccess then
            local added = exports.ox_inventory:AddItem(source, matchedRecipe.outputItem, outputAmount, { serial = 'it_drugs' })
            if not added then
                sendNotify(source, '完成品の付与に失敗しました。', 'error')
                return false
            end

            sendNotify(source, ('調合成功: %s x%s'):format(matchedRecipe.outputItem, outputAmount), 'success')
        else
            exports.ox_inventory:AddItem(source, 'drug_waste', wasteAmount)
            if matchedRecipeKey == nil then
                sendNotify(source, ('調合失敗: 配合が一致しません (drug_waste x%s)'):format(wasteAmount), 'error')
            else
                sendNotify(source, ('調合失敗: 素材不足 (drug_waste x%s)'):format(wasteAmount), 'error')
            end
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
