local QBCore = exports['qb-core']:GetCoreObject()

local shopOpen       = false
local previewActive  = false
local previewVehicle = nil
local previewCamera  = nil
local previewAngle   = 0.0
local currentShopId  = nil
local lastPurchaseShopId = nil
local previewPedState = {
    visible = true,
    collision = true
}

-- ショップを開く（shop = Config.Shops の1エントリ）
local function OpenShop(shop)
    if shopOpen then return end
    shopOpen = true
    currentShopId = shop.id

    -- このショップの車両のみ抽出
    local shopVehicles = {}
    for _, v in ipairs(Config.Vehicles) do
        if v.shop == shop.id then
            table.insert(shopVehicles, v)
        end
    end

    -- このショップのカテゴリーのみ抽出（定義順を維持）
    local shopCategories = {}
    for _, cat in ipairs(Config.Categories) do
        for _, catId in ipairs(shop.categories) do
            if cat.id == catId then
                table.insert(shopCategories, cat)
                break
            end
        end
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action     = 'open',
        shopLabel  = shop.label,
        vehicles   = shopVehicles,
        categories = shopCategories,
    })
end

local function getShopById(shopId)
    for _, shop in ipairs(Config.Shops or {}) do
        if shop.id == shopId then
            return shop
        end
    end
    return nil
end

local function getPurchaseSpawn(shopId)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    local shop = getShopById(shopId)

    if shop and shop.purchaseSpawn then
        return vector4(shop.purchaseSpawn.x, shop.purchaseSpawn.y, shop.purchaseSpawn.z, shop.purchaseSpawn.w)
    end

    if shop and shop.coords then
        local h = shop.coords.w or pedHeading
        local x = shop.coords.x + 6.0 * math.sin(math.rad(-h))
        local y = shop.coords.y + 6.0 * math.cos(math.rad(-h))
        return vector4(x, y, shop.coords.z + 0.5, h)
    end

    local fwd = GetEntityForwardVector(ped)
    return vector4(pedCoords.x + (fwd.x * 4.0), pedCoords.y + (fwd.y * 4.0), pedCoords.z + 0.5, pedHeading)
end

local function getPreviewSpawn(shopId, pedCoords, pedHeading)
    local shop = getShopById(shopId)
    if shop and shop.previewSpawn then
        return vector4(shop.previewSpawn.x, shop.previewSpawn.y, shop.previewSpawn.z, shop.previewSpawn.w or 0.0)
    end
    if Config.PreviewSpawn then
        return vector4(Config.PreviewSpawn.x, Config.PreviewSpawn.y, Config.PreviewSpawn.z, Config.PreviewSpawn.w or 0.0)
    end

    local rad = math.rad(-pedHeading)
    return vector4(
        pedCoords.x + 8.0 * math.sin(rad),
        pedCoords.y + 8.0 * math.cos(rad),
        pedCoords.z,
        pedHeading + 180.0
    )
end

-- ショップを閉じる
local function CloseShop()
    shopOpen = false
    currentShopId = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

-- プレビュー後片付け
local function StopPreview()
    previewActive = false

    if previewCamera then
        RenderScriptCams(false, true, 600, true, false)
        DestroyCam(previewCamera, false)
        previewCamera = nil
    end

    if previewVehicle and DoesEntityExist(previewVehicle) then
        DeleteVehicle(previewVehicle)
        previewVehicle = nil
    end

    local ped = PlayerPedId()
    SetEntityVisible(ped, previewPedState.visible, false)
    SetEntityCollision(ped, previewPedState.collision, previewPedState.collision)
    ResetEntityAlpha(ped)
    FreezeEntityPosition(ped, false)
end

-- 3Dプレビュー開始
local function StartPreview(modelName)
    if previewActive then
        StopPreview()
    end

    local model = GetHashKey(modelName)
    RequestModel(model)

    local t = 0
    while not HasModelLoaded(model) and t < 50 do
        Wait(100)
        t = t + 1
    end

    if not HasModelLoaded(model) then
        SendNUIMessage({ action = 'previewFailed' })
        return
    end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local previewSpawn = getPreviewSpawn(currentShopId, playerCoords, heading)
    local spawnX, spawnY, spawnZ, spawnHeading = previewSpawn.x, previewSpawn.y, previewSpawn.z, previewSpawn.w

    -- 非ネットワーク生成で他プレイヤーには見せない
    previewVehicle = CreateVehicle(model, spawnX, spawnY, spawnZ, spawnHeading, false, false)
    SetVehicleOnGroundProperly(previewVehicle)
    SetEntityInvincible(previewVehicle, true)
    SetEntityCanBeDamaged(previewVehicle, false)
    FreezeEntityPosition(previewVehicle, true)
    SetVehicleEngineOn(previewVehicle, false, true, true)
    SetModelAsNoLongerNeeded(model)

    previewPedState.visible = IsEntityVisible(ped)
    previewPedState.collision = true
    SetEntityVisible(ped, false, false)
    SetEntityAlpha(ped, 0, false)
    SetEntityCollision(ped, false, false)
    FreezeEntityPosition(ped, true)

    previewCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamFov(previewCamera, Config.PreviewCameraFOV)
    SetCamActive(previewCamera, true)
    RenderScriptCams(true, true, 800, true, false)

    previewActive = true
    previewAngle  = 0.0

    Citizen.CreateThread(function()
        while previewActive do
            Wait(0)
            if not (previewVehicle and DoesEntityExist(previewVehicle)) then break end

            local vPos   = GetEntityCoords(previewVehicle)
            local radius = Config.PreviewCameraRadius
            local height = Config.PreviewCameraHeight

            previewAngle = previewAngle + Config.PreviewRotateSpeed
            if previewAngle >= 360.0 then previewAngle = 0.0 end

            local rads = math.rad(previewAngle)
            SetCamCoord(previewCamera,
                vPos.x + radius * math.cos(rads),
                vPos.y + radius * math.sin(rads),
                vPos.z + height
            )
            PointCamAtEntity(previewCamera, previewVehicle, 0.0, 0.0, 0.3, true)
        end
    end)
end

-- NUIコールバック
RegisterNUICallback('close', function(_, cb)
    CloseShop()
    cb('ok')
end)

RegisterNUICallback('preview', function(data, cb)
    StartPreview(data.model)
    cb('ok')
end)

RegisterNUICallback('backToShop', function(_, cb)
    StopPreview()
    SendNUIMessage({ action = 'returnToShop' })
    cb('ok')
end)

RegisterNUICallback('buy', function(data, cb)
    local shopId = currentShopId
    lastPurchaseShopId = shopId

    -- プレビュー中購入で固まる問題を防ぐため、購入前に必ず解除する
    if previewActive then
        StopPreview()
    end
    CloseShop()

    TriggerServerEvent('car-dealer:buyVehicle', data.model, data.label, data.price, shopId)
    cb('ok')
end)

RegisterNetEvent('car-dealer:purchaseResult', function(success, message, model, plate)
    if success then
        SpawnPurchasedVehicle(model, plate, message, lastPurchaseShopId)
        lastPurchaseShopId = nil
    else
        lastPurchaseShopId = nil
        QBCore.Functions.Notify(message, 'error', 5000)
    end
end)

-- 購入した車をスポーンしてプレイヤーを乗せる
function SpawnPurchasedVehicle(model, plate, message, shopId)
    Citizen.CreateThread(function()
        Wait(600) -- カメラ遷移・ショップクローズを待つ

        local ped      = PlayerPedId()
        local spawnPos = getPurchaseSpawn(shopId)

        QBCore.Functions.SpawnVehicle(model, function(vehicle)
            if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
                QBCore.Functions.Notify('車両のスポーンに失敗しました', 'error', 4000)
                return
            end

            SetVehicleOnGroundProperly(vehicle)
            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleNumberPlateText(vehicle, plate)
            TaskWarpPedIntoVehicle(ped, vehicle, -1)

            -- 鍵を渡す（環境差分に対応）
            TriggerEvent('vehiclekeys:client:SetOwner', plate)
            TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)

            QBCore.Functions.Notify(message, 'success', 6000)
        end, spawnPos, true, true)
    end)
end

-- マーカー・ブリップ・Eキー処理（全ショップ対応）
Citizen.CreateThread(function()
    -- 全ショップのブリップを生成
    for _, shop in ipairs(Config.Shops) do
        local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
        SetBlipSprite(blip, shop.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, shop.blip.scale)
        SetBlipColour(blip, shop.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(shop.label)
        EndTextCommandSetBlipName(blip)
    end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearAny      = false

        for _, shop in ipairs(Config.Shops) do
            local sc   = shop.coords
            local dist = #(playerCoords - vector3(sc.x, sc.y, sc.z))

            if dist < 30.0 then
                nearAny = true
                local mc = shop.markerColor
                DrawMarker(
                    Config.MarkerType,
                    sc.x, sc.y, sc.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                    mc.r, mc.g, mc.b, mc.a,
                    false, false, 2, false, nil, nil, false
                )

                if dist < 2.5 and not shopOpen then
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName('[E] ' .. shop.label .. 'を開く')
                    EndTextCommandDisplayHelp(0, false, true, -1)

                    if IsControlJustReleased(0, 38) then
                        OpenShop(shop)
                    end
                end
            end
        end

        -- ESC でショップを閉じる
        if shopOpen and IsControlJustReleased(0, 200) then
            if previewActive then
                StopPreview()
                SendNUIMessage({ action = 'returnToShop' })
            else
                CloseShop()
            end
        end

        Wait(nearAny and 0 or 500)
    end
end)
