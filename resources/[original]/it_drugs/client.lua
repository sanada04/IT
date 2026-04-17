local zones = {}
local nearestAction = nil
local textUiOpen = false
local hasOxTarget = false
local pendingProcessActionKey = nil
local nuiReady = false
local pendingOpenRecipes = nil

local function notify(description, nType)
    lib.notify({
        title = 'Drug System',
        description = description,
        type = nType or 'inform'
    })
end

local function canDoAction(actionKey)
    local action = Config.Actions[actionKey]
    if not action then
        notify('不明なアクションです。', 'error')
        return false
    end

    local canProceed = lib.callback.await('it_drugs:server:canStartAction', false, actionKey)
    if not canProceed then
        return false
    end

    return true
end

local function buildRecipeList(actionKey)
    return lib.callback.await('it_drugs:server:getSerialMaterials', false, actionKey)
end

local function openProcessUi(actionKey)
    local processData = buildRecipeList(actionKey)
    if type(processData) ~= 'table' then
        processData = {}
    end
    if type(processData.recipes) ~= 'table' then
        processData.recipes = {}
    end

    pendingProcessActionKey = actionKey
    pendingOpenRecipes = processData
    if textUiOpen then
        lib.hideTextUI()
        textUiOpen = false
    end

    local function openNow()
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openProcessUi',
            data = processData
        })
    end

    openNow()

    -- Limited retry for first-message loss.
    CreateThread(function()
        for _ = 1, 4 do
            if pendingProcessActionKey ~= actionKey then
                break
            end
            Wait(150)
            openNow()
        end
    end)

    return true
end

local function runProcessAction(actionKey, processPayload)
    local action = Config.Actions[actionKey]
    if not action then return end

    if not canDoAction(actionKey) then
        return
    end

    local success = lib.progressCircle({
        duration = action.duration,
        label = action.label,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = action.anim,
        disable = {
            move = true,
            car = true,
            combat = true,
            sprint = true
        }
    })

    if not success then
        notify('キャンセルしました。', 'error')
        return
    end

    lib.callback.await('it_drugs:server:completeProcess', false, actionKey, processPayload)
end

local function doAction(actionKey)
    local action = Config.Actions[actionKey]
    if not action then return end

    if action.mode == 'process_ui' then
        openProcessUi(actionKey)
        return
    end

    if not canDoAction(actionKey) then
        return
    end

    local success = lib.progressCircle({
        duration = action.duration,
        label = action.label,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = action.anim,
        disable = {
            move = true,
            car = true,
            combat = true,
            sprint = true
        }
    })

    if not success then
        notify('キャンセルしました。', 'error')
        return
    end

    local completed = lib.callback.await('it_drugs:server:completeAction', false, actionKey)

    if not completed then
        return
    end
end

local function createActionZone(actionKey, data)
    local id = exports.ox_target:addSphereZone({
        coords = data.zone.coords,
        radius = data.zone.radius,
        debug = Config.Debug,
        options = {
            {
                name = ('it_drugs_%s'):format(actionKey),
                icon = data.icon,
                label = data.label,
                onSelect = function()
                    doAction(actionKey)
                end
            }
        }
    })

    zones[#zones + 1] = id
end

CreateThread(function()
    hasOxTarget = GetResourceState('ox_target') == 'started'

    for actionKey, data in pairs(Config.Actions) do
        if hasOxTarget then
            createActionZone(actionKey, data)
        end
    end
end)

RegisterNetEvent('it_drugs:client:notify', function(description, nType)
    notify(description, nType)
end)

RegisterNUICallback('uiReady', function(_, cb)
    nuiReady = true
    if pendingProcessActionKey and pendingOpenRecipes then
        SendNUIMessage({
            action = 'openProcessUi',
            data = pendingOpenRecipes
        })
    end
    cb({ ok = true })
end)

RegisterNUICallback('submitProcess', function(data, cb)
    local actionKey = pendingProcessActionKey
    pendingProcessActionKey = nil
    pendingOpenRecipes = nil
    SetNuiFocus(false, false)

    if actionKey then
        local payload = {
            recipeKey = data.recipeKey,
            inputs = data.inputs or {}
        }
        CreateThread(function()
            runProcessAction(actionKey, payload)
        end)
    end

    cb({ ok = true })
end)

RegisterCommand('it_drugs_ui', function()
    notify('NUI表示テストを実行します。', 'inform')
    openProcessUi('process_lab_1')
end, false)

RegisterNUICallback('cancelProcess', function(_, cb)
    pendingProcessActionKey = nil
    pendingOpenRecipes = nil
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

CreateThread(function()
    while true do
        Wait(0)
        if pendingProcessActionKey and IsControlJustReleased(0, 322) then -- ESC fallback
            pendingProcessActionKey = nil
            pendingOpenRecipes = nil
            SetNuiFocus(false, false)
        end
    end
end)

RegisterNetEvent('it_drugs:client:applyDizzy', function()
    local ped = PlayerPedId()
    ShakeGameplayCam('DRUNK_SHAKE', 1.0)
    SetTimecycleModifier('spectator5')
    SetPedMotionBlur(ped, true)
    Wait(15000)
    SetPedMotionBlur(ped, false)
    ShakeGameplayCam('DRUNK_SHAKE', 0.0)
    ClearTimecycleModifier()
end)

CreateThread(function()
    while true do
        local waitMs = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local found = nil
        local nearestDistance = 9999.0

        for actionKey, data in pairs(Config.Actions) do
            local distance = #(coords - data.zone.coords)
            if distance <= (data.zone.radius + 1.2) and distance < nearestDistance then
                found = actionKey
                nearestDistance = distance
            end
        end

        nearestAction = found

        if nearestAction then
            waitMs = 0

            local action = Config.Actions[nearestAction]
            if not textUiOpen then
                lib.showTextUI(('[E] %s'):format(action and action.label or '薬物アクション'), { position = 'right-center' })
                textUiOpen = true
            end

            if IsControlJustReleased(0, 38) then
                doAction(nearestAction)
            end
        elseif textUiOpen then
            lib.hideTextUI()
            textUiOpen = false
        end

        Wait(waitMs)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if textUiOpen then
        lib.hideTextUI()
        textUiOpen = false
    end
    if hasOxTarget then
        for i = 1, #zones do
            exports.ox_target:removeZone(zones[i])
        end
    end
end)
