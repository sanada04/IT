local QBCore = exports['qb-core']:GetCoreObject()

local function findVehicleConfig(model, shopId)
    if type(model) ~= 'string' then return nil end
    local needle = model:lower()
    for _, vehicle in ipairs(Config.Vehicles or {}) do
        if type(vehicle.model) == 'string' and vehicle.model:lower() == needle then
            if not shopId or vehicle.shop == shopId then
                return vehicle
            end
        end
    end
    return nil
end

local function resolveGarageForShop(shopId)
    if type(Config.ShopGarages) == 'table' and shopId and Config.ShopGarages[shopId] then
        return Config.ShopGarages[shopId]
    end
    return Config.DefaultGarage or 'pillboxgarage'
end

local function generatePlate()
    if QBCore.Functions.GeneratePlate then
        return QBCore.Functions.GeneratePlate()
    end

    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local exists = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    if exists then
        return generatePlate()
    end
    return plate:upper()
end

RegisterNetEvent('car-dealer:buyVehicle', function(model, label, price, shopId)
    local src    = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local vehicleCfg = findVehicleConfig(model, shopId)
    if not vehicleCfg then
        TriggerClientEvent('car-dealer:purchaseResult', src, false, '購入対象の車両データが見つかりません', nil, nil)
        return
    end

    local finalPrice = vehicleCfg.price
    local finalLabel = vehicleCfg.label or label or model

    if type(finalPrice) ~= 'number' or finalPrice <= 0 then
        TriggerClientEvent('car-dealer:purchaseResult', src, false, '価格設定が不正です', nil, nil)
        return
    end

    local balance = Player.Functions.GetMoney('bank')
    if balance < finalPrice then
        TriggerClientEvent('car-dealer:purchaseResult', src, false, '残高が不足しています', nil, nil)
        return
    end

    local paid = Player.Functions.RemoveMoney('bank', finalPrice, 'car-dealer-purchase')
    if not paid then
        TriggerClientEvent('car-dealer:purchaseResult', src, false, '支払い処理に失敗しました', nil, nil)
        return
    end

    local plate = generatePlate()
    local garage = resolveGarageForShop(shopId)

    -- state=0 で受け渡し中（外に出ている状態）として登録
    local inserted = MySQL.insert.await(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        {
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            model,
            GetHashKey(model),
            '{}',
            plate,
            garage,
            0
        }
    )

    if not inserted then
        Player.Functions.AddMoney('bank', finalPrice, 'car-dealer-refund')
        TriggerClientEvent('car-dealer:purchaseResult', src, false, '購入登録に失敗したため返金しました', nil, nil)
        return
    end

    TriggerClientEvent('car-dealer:purchaseResult', src, true,
        finalLabel .. ' を購入しました！\nナンバー: ' .. plate,
        model,
        plate
    )
end)
