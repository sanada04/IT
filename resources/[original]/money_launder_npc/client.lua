local QBCore = exports['qb-core']:GetCoreObject()

local npcPed
local busy = false

local function notify(msg, ntype)
    QBCore.Functions.Notify(msg, ntype or 'primary')
end

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
    return hash
end

local function spawnNpc()
    local cfg = Config.Npc
    local model = loadModel(cfg.model)

    npcPed = CreatePed(4, model, cfg.coords.x, cfg.coords.y, cfg.coords.z - 1.0, cfg.coords.w, false, true)
    SetEntityAsMissionEntity(npcPed, true, true)
    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)

    if cfg.scenario and cfg.scenario ~= '' then
        TaskStartScenarioInPlace(npcPed, cfg.scenario, 0, true)
    end

    SetModelAsNoLongerNeeded(model)
end

local function startLaunder()
    if busy then return end
    busy = true

    local amount = lib.callback.await('money_launder_npc:getBlackMoney', false)
    if not amount or amount < Config.MinConvert then
        notify(Config.Text.noMoney, 'error')
        busy = false
        return
    end

    local ok = lib.progressCircle({
        duration = Config.ConvertSeconds * 1000,
        label = Config.Text.converting,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    })

    if not ok then
        notify(Config.Text.cancelled, 'error')
        busy = false
        return
    end

    local converted = lib.callback.await('money_launder_npc:convertMoney', false)
    if converted and converted > 0 then
        notify((Config.Text.success):format(converted), 'success')
    else
        notify(Config.Text.failed, 'error')
    end

    busy = false
end

CreateThread(function()
    spawnNpc()

    exports['qb-target']:AddTargetModel(Config.Npc.model, {
        options = {
            {
                icon = 'fas fa-sack-dollar',
                label = Config.Text.targetLabel,
                action = function(entity)
                    if entity ~= npcPed then return end
                    startLaunder()
                end
            }
        },
        distance = 2.0
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if npcPed and DoesEntityExist(npcPed) then
        DeletePed(npcPed)
        npcPed = nil
    end

    exports['qb-target']:RemoveTargetModel(Config.Npc.model, { Config.Text.targetLabel })
end)
