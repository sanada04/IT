local QBCore = exports['qb-core']:GetCoreObject()

local function formatMoney(n)
    local s = tostring(math.floor(n))
    local result = ''
    local count = 0
    for i = #s, 1, -1 do
        count = count + 1
        result = s:sub(i, i) .. result
        if count % 3 == 0 and i > 1 then
            result = ',' .. result
        end
    end
    return result
end

QBCore.Functions.CreateCallback('it-vehiclesell:server:getPlayerVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(nil) return end

    local citizenId = Player.PlayerData.citizenid
    local rows = MySQL.query.await(
        'SELECT plate, vehicle, fuel, engine, body FROM player_vehicles WHERE citizenid = ? AND state = 1 AND depotprice = 0',
        { citizenId }
    )

    if not rows or #rows == 0 then cb(nil) return end

    local result = {}
    for _, v in ipairs(rows) do
        local vehData = QBCore.Shared.Vehicles[v.vehicle]
        result[#result + 1] = {
            plate       = v.plate,
            model       = v.vehicle,
            label       = vehData and vehData.name     or v.vehicle,
            brand       = vehData and vehData.brand    or '',
            category    = vehData and vehData.category or '',
            marketPrice = vehData and vehData.price    or 0,
            fuel        = math.min(100, math.max(0, v.fuel   or 0)),
            engine      = math.min(100, math.max(0, math.floor(((v.engine or 1000) / 1000) * 100))),
            body        = math.min(100, math.max(0, math.floor(((v.body   or 1000) / 1000) * 100))),
        }
    end

    cb(result)
end)

RegisterNetEvent('it-vehiclesell:server:sellVehicles', function(plates)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if type(plates) ~= 'table' or #plates == 0 then
        TriggerClientEvent('it-vehiclesell:client:sellResult', src, false, '無効なリクエストです')
        return
    end

    local citizenId = Player.PlayerData.citizenid

    local placeholders = {}
    local params = { citizenId }
    for _, plate in ipairs(plates) do
        placeholders[#placeholders + 1] = '?'
        params[#params + 1] = tostring(plate)
    end

    local owned = MySQL.query.await(
        'SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ? AND state = 1 AND depotprice = 0 AND plate IN (' .. table.concat(placeholders, ',') .. ')',
        params
    )

    if not owned or #owned == 0 then
        TriggerClientEvent('it-vehiclesell:client:sellResult', src, false, '売却できる車両が見つかりませんでした')
        return
    end

    local totalMoney = 0
    local soldPlates = {}

    for _, v in ipairs(owned) do
        local vehData = QBCore.Shared.Vehicles[v.vehicle]
        local marketPrice = vehData and vehData.price or 0
        totalMoney = totalMoney + math.floor(marketPrice * Config.SellPriceRate)
        soldPlates[#soldPlates + 1] = v.plate
    end

    local delPlaceholders = {}
    local delParams = { citizenId }
    for _, plate in ipairs(soldPlates) do
        delPlaceholders[#delPlaceholders + 1] = '?'
        delParams[#delParams + 1] = plate
    end

    MySQL.update.await(
        'DELETE FROM player_vehicles WHERE citizenid = ? AND plate IN (' .. table.concat(delPlaceholders, ',') .. ')',
        delParams
    )

    Player.Functions.AddMoney(Config.PaymentType, totalMoney, 'vehicle-sell')

    TriggerClientEvent('it-vehiclesell:client:sellResult', src, true,
        string.format('%d台の車両を売却しました（合計 ¥%s）', #soldPlates, formatMoney(totalMoney)))

    print(string.format('[it-vehiclesell] %s sold %d vehicle(s) for $%s', citizenId, #soldPlates, formatMoney(totalMoney)))
end)
