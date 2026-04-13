local config = require 'config'
local Lootbox = require 'server.modules.Lootbox'

---@param src number
---@param garage string
---@param model string
---@return boolean
local function giveQBVehicle(src, garage, model)
    if GetResourceState('qb-core') ~= 'started' then
        lib.print.error('world_gacha: qb-core is not started')
        return false
    end

    local QBCore = exports['qb-core']:GetCoreObject()
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return false
    end

    local function generatePlate()
        local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
        local exists = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
        if exists then
            return generatePlate()
        end
        return plate:upper()
    end

    local plate = generatePlate()
    local hash = joaat(model)

    -- qb-garages: state 1 = ガレージ内保管（0 は「外」扱いのため一覧で取り出しにくい場合がある）
    local ok, insertIdOrErr = pcall(function()
        return MySQL.insert.await('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            model,
            tostring(hash),
            '{}',
            plate,
            garage,
            1,
        })
    end)

    if not ok then
        lib.print.error(('world_gacha: player_vehicles INSERT failed for %s (%s): %s'):format(
            model,
            plate,
            tostring(insertIdOrErr)
        ))
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'データベースへの車両登録に失敗しました。管理者に連絡してください。',
        })
        return false
    end

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = ('車両をガレージに登録しました（%s / %s）'):format(model, plate),
    })

    return true
end

-- 起動直後のガチャでフック未登録→ vehicle を ox アイテム扱いにするレースを避ける（Wait は不要）
Lootbox.registerRewardHook('vehicle', function(source, reward, _caseName)
    local data = reward.rewardData
    if not data or not data.model then
        return false
    end

    local garage = data.garage or config.defaultVehicleGarage or 'pillboxgarage'
    return giveQBVehicle(source, garage, data.model)
end)

lib.print.info('sleepless_lootbox: vehicle reward hook registered (QBCore)')

--- クライアントと同じ基準（NPC 座標 + pedOffset）で距離判定。サーバー ped の座標だけだと Z ずれ・OneSync で誤判定しやすい。
RegisterNetEvent('sleepless_lootbox:server:openWorldGacha', function(index, clientCoords)
    local src = source
    index = tonumber(index)
    if not index or index < 1 then
        return
    end

    local spots = config.worldGachas
    if not spots or not spots[index] then
        return
    end

    local spot = spots[index]
    local t = spot.coords
    local po = spot.pedOffset or spot.propOffset
    local ox, oy, oz = 0.0, 0.0, 0.0
    if po then
        ox = po.x or 0.0
        oy = po.y or 0.0
        oz = po.z or 0.0
    end
    local target = vector3(t.x + ox, t.y + oy, t.z + oz)
    local maxDist = (spot.interactDistance or spot.distance or 2.5) + 1.5

    local cc = nil
    if type(clientCoords) == 'vector3' then
        cc = clientCoords
    elseif type(clientCoords) == 'table' and clientCoords.x then
        cc = vector3(clientCoords.x, clientCoords.y, clientCoords.z)
    end
    if not cc then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = '位置情報を取得できません。再度お試しください。',
        })
        return
    end

    local ped = GetPlayerPed(src)
    local srvCoords = ped and ped ~= 0 and GetEntityCoords(ped) or nil
    if srvCoords and #(srvCoords - cc) > 25.0 then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = '位置情報が一致しません。少し動いてから再度お試しください。',
        })
        return
    end

    if #(cc - target) > maxDist then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'ガチャのそばに行ってください。',
        })
        return
    end

    local price = tonumber(spot.price) or 0
    local QBCore = price > 0 and GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject() or nil
    local Player = QBCore and QBCore.Functions.GetPlayer(src) or nil

    if price > 0 then
        if not Player then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'プレイヤー情報を取得できませんでした。',
            })
            return
        end
        if not Player.Functions.RemoveMoney('cash', price, 'sleepless_lootbox-world') then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = ('現金が $%s 必要です。'):format(price),
            })
            return
        end
    end

    local caseName = spot.caseName
    if type(caseName) == 'string' then
        caseName = caseName:match('^%s*(.-)%s*$')
    end
    -- 起動直後のレースで init 前に届く場合のフォールバック
    if caseName and not Lootbox.get(caseName) then
        Lootbox.init()
    end
    if not caseName or not Lootbox.get(caseName) then
        if price > 0 and Player then
            Player.Functions.AddMoney('cash', price, 'sleepless_lootbox-world-refund')
        end
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = ('ガチャ設定が不正です（ケース: %s）。config の lootboxes に定義があるか確認してください。'):format(tostring(caseName)),
        })
        return
    end

    local ok = Lootbox.open(src, caseName, true)
    if not ok then
        if price > 0 and Player then
            Player.Functions.AddMoney('cash', price, 'sleepless_lootbox-world-refund')
        end
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'ガチャを開始できません。前回のガチャが未完了の場合は、一度結果を確認してからお試しください。',
        })
    end
end)
