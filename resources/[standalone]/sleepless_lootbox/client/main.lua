local Lootbox = require 'client.modules.Lootbox'
local config = require 'config'

print('^2[sleepless_lootbox] client main.lua loaded (F8 = クライアント)^0')

RegisterNetEvent('sleepless_lootbox:roll', function(data)
    Lootbox.startRoll(data)
end)

RegisterNetEvent('sleepless_lootbox:showPreview', function(data)
    Lootbox.showPreview(data)
end)

exports('isRolling', function()
    return Lootbox.isRolling()
end)

exports('preview', function(caseName)
    if type(caseName) ~= 'string' then
        lib.print.error('preview: caseName must be a string')
        return
    end

    Lootbox.requestPreview(caseName)
end)

exports('close', function()
    Lootbox.closeUI()
end)

RegisterNUICallback('escape', function(_, cb)
    if Lootbox.isRolling() then
        cb({ allow = false })
        return
    end

    Lootbox.closeUI()
    cb({ allow = true })
end)

if config.debug then
    RegisterCommand('lootbox_preview', function(_, args)
        local caseName = args[1] or 'gun_case'
        Lootbox.requestPreview(caseName)
    end, false)

    RegisterCommand('lootbox_test_ui', function()
        local dummyPool = {}
        local rarities = { 'common', 'common', 'common', 'uncommon', 'uncommon', 'rare', 'epic', 'legendary' }

        for i = 1, 100 do
            local rarity = rarities[math.random(#rarities)]
            dummyPool[i] = {
                name = 'test_item_' .. i,
                label = 'Test Item ' .. i,
                amount = math.random(1, 5),
                image = 'nui://ox_inventory/web/images/water.webp',
                rarity = rarity,
                weight = rarity == 'common' and 50 or rarity == 'uncommon' and 20 or rarity == 'rare' and 10 or rarity == 'epic' and 5 or 1,
                chance = 1,
            }
        end

        Lootbox.startRoll({
            pool = dummyPool,
            winnerIndex = math.random(70, 95),
            caseName = 'test_case',
            caseLabel = 'Test Case',
        })
    end, false)

    RegisterCommand('lootbox_test_preview', function()
        local dummyItems = {}
        local rarities = { 'common', 'uncommon', 'rare', 'epic', 'legendary' }
        local weights = { 50, 20, 10, 5, 1 }

        for i = 1, 10 do
            local idx = math.min(i, #rarities)
            dummyItems[i] = {
                name = 'test_item_' .. i,
                label = 'Test Item ' .. i,
                amount = math.random(1, 5),
                image = 'nui://ox_inventory/web/images/water.webp',
                rarity = rarities[idx],
                weight = weights[idx],
                chance = weights[idx],
            }
        end

        Lootbox.showPreview({
            caseName = 'test_case',
            caseLabel = 'Test Case',
            description = 'A test case for debugging',
            items = dummyItems,
        })
    end, false)
end

-------------------------------------------------
-- World gacha (NPC) — main.lua に統合（確実にクライアントで実行）
-------------------------------------------------
local worldGachaNpcs = {}

local FALLBACK_PEDS = {
    's_m_m_autoshop_01',
    's_m_y_shop_mask',
    'a_m_m_hasjew_01',
}

local function tryLoadModel(name)
    local ok, result = pcall(function()
        return lib.requestModel(name, 10000)
    end)
    if ok and result then
        return result
    end
    return nil
end

local function loadCollisionAt(x, y, z)
    RequestCollisionAtCoord(x, y, z)
    for _ = 1, 30 do
        RequestCollisionAtCoord(x, y, z)
        Wait(0)
    end
end

local function createNpcPed(hash, c, off, scenario)
    local x, y, z = c.x + off.x, c.y + off.y, c.z + off.z
    local heading = c.w or 0.0

    loadCollisionAt(x, y, z)

    local ped = CreatePed(4, hash, x, y, z, heading, true, true)
    if not ped or ped == 0 then
        ped = CreatePed(4, hash, x, y, z, heading, false, true)
    end
    if not ped or ped == 0 then
        return nil
    end

    SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
    SetEntityHeading(ped, heading)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedFleeAttributes(ped, 0, false)

    TaskStartScenarioInPlace(ped, scenario or 'WORLD_HUMAN_STAND_MOBILE', 0, true)

    SetModelAsNoLongerNeeded(hash)
    return ped
end

local function resolvePedModel(spot, index)
    local pedModel = spot.ped or spot.pedModel
    local names = {}

    if type(pedModel) == 'string' then
        names[1] = pedModel
    elseif type(pedModel) == 'number' then
        names[1] = pedModel
    elseif type(pedModel) == 'table' then
        names = pedModel
    end

    local hash = nil
    for _, name in ipairs(names) do
        hash = tryLoadModel(name)
        if hash then
            break
        end
    end

    if not hash then
        for _, name in ipairs(FALLBACK_PEDS) do
            hash = tryLoadModel(name)
            if hash then
                print(('[sleepless_lootbox] worldGachas[%s]: fallback ped %s'):format(index, name))
                break
            end
        end
    end

    return hash
end

local function spawnWorldNpc(index, spot)
    local hash = resolvePedModel(spot, index)
    if not hash then
        print(('[sleepless_lootbox] ERROR: could not load ped model for index %s'):format(index))
        return
    end

    local c = spot.coords
    local off = spot.pedOffset or spot.propOffset or vec3(0.0, 0.0, 0.0)

    local ped = createNpcPed(hash, c, off, spot.scenario)
    if not ped then
        print(('[sleepless_lootbox] ERROR: CreatePed failed index %s'):format(index))
        return
    end

    worldGachaNpcs[index] = ped
    print(('[sleepless_lootbox] world gacha NPC #%s spawned (entity %s)'):format(index, ped))
end

local function cleanupWorldGachaNpcs()
    for i, ent in pairs(worldGachaNpcs) do
        if DoesEntityExist(ent) then
            DeleteEntity(ent)
        end
        worldGachaNpcs[i] = nil
    end
end

local function isRollingSafe()
    local ok, rolling = pcall(function()
        return exports[GetCurrentResourceName()]:isRolling()
    end)
    if ok then
        return rolling
    end
    return false
end

local function getSpotCenter(spot, index)
    local pedEnt = worldGachaNpcs[index]
    if pedEnt and DoesEntityExist(pedEnt) then
        return GetEntityCoords(pedEnt)
    end
    local c = spot.coords
    return vector3(c.x, c.y, c.z)
end

CreateThread(function()
    print('^2[sleepless_lootbox] world gacha thread starting (client)^0')

    -- qb-multichar など: ログイン完了まで待つ（永遠に ped=0 のループを避ける）
    if GetResourceState('qb-core') == 'started' then
        local deadline = GetGameTimer() + 120000
        while GetGameTimer() < deadline do
            if LocalPlayer and LocalPlayer.state and LocalPlayer.state.isLoggedIn then
                break
            end
            Wait(200)
        end
    end

    while not NetworkIsSessionStarted() do
        Wait(200)
    end

    -- プレイヤーpedが取れるまで（最大60秒）
    local t0 = GetGameTimer()
    while (not PlayerPedId() or PlayerPedId() == 0) and (GetGameTimer() - t0) < 60000 do
        Wait(100)
    end

    Wait(1500)

    local spots = config.worldGachas
    if not spots then
        print('^1[sleepless_lootbox] config.worldGachas is nil — check config.lua^0')
        return
    end

    local n = #spots
    if n == 0 then
        print('^3[sleepless_lootbox] config.worldGachas length is 0 — world gacha disabled^0')
        return
    end

    print(('^2[sleepless_lootbox] spawning %d world gacha NPC(s)^0'):format(n))

    for i = 1, n do
        spawnWorldNpc(i, spots[i])
    end

    local lastNear = false

    while true do
        local sleep = 800
        local spotsLoop = config.worldGachas
        if not spotsLoop or #spotsLoop == 0 then
            Wait(1000)
        else
            local myPed = PlayerPedId()
            local pcoords = GetEntityCoords(myPed)
            local nearIndex = nil
            local spotNear = nil
            local distBest = 9999.0

            for i = 1, #spotsLoop do
                local spot = spotsLoop[i]
                local center = getSpotCenter(spot, i)
                local dist = #(pcoords - center)
                local maxDist = (spot.interactDistance or 2.0) + 0.5

                local c = spot.coords
                if dist < 40.0 and config.debug then
                    sleep = 0
                    DrawMarker(
                        1, c.x, c.y, c.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        1.2, 1.2, 1.0,
                        50, 150, 255, 120,
                        false, true, 2, false, nil, nil, false
                    )
                elseif dist < 15.0 then
                    sleep = 100
                end

                if dist < maxDist and dist < distBest then
                    distBest = dist
                    nearIndex = i
                    spotNear = spot
                end
            end

            if nearIndex and spotNear then
                sleep = 0
                if isRollingSafe() then
                    if lastNear then
                        lib.hideTextUI()
                        lastNear = false
                    end
                else
                    lib.showTextUI('[E] ' .. (spotNear.label or 'ガチャを回す'))
                    lastNear = true
                    local pressed = IsControlJustReleased(0, 38) or IsDisabledControlJustReleased(0, 38)
                    if pressed then
                        lib.hideTextUI()
                        local p = GetEntityCoords(PlayerPedId())
                        TriggerServerEvent('sleepless_lootbox:server:openWorldGacha', nearIndex, { x = p.x, y = p.y, z = p.z })
                    end
                end
            else
                if lastNear then
                    lib.hideTextUI()
                    lastNear = false
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        Lootbox.closeUI()
        lib.hideTextUI()
        cleanupWorldGachaNpcs()
    end
end)
