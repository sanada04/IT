local QBCore = exports['qb-core']:GetCoreObject()

-- インベントリにアイテムを追加（ox_inventory / qb-inventory 対応）
local function AddItemToInventory(src, itemName, amount)
    amount = math.floor(tonumber(amount) or 1)
    if amount < 1 then return false end
    if GetResourceState("ox_inventory") == "started" then
        local ok, err = exports.ox_inventory:AddItem(src, itemName, amount)
        if ok then return true end
        if err == "invalid_item" then
            print("^1[metal_detector]^7 アイテム '" .. tostring(itemName) .. "' が ox_inventory に登録されていません。ox_inventory/data/items.lua に追加してください。")
        elseif err == "inventory_full" then
            print("^1[metal_detector]^7 プレイヤー " .. tostring(src) .. " のインベントリが満杯です。")
        end
        return false
    end
    if GetResourceState("qb-inventory") == "started" then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        exports["qb-inventory"]:AddItem(src, itemName, amount, false, nil, "metal_detector")
        return true
    end
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem(itemName, amount)
        return true
    end
    return false
end

-- インベントリからアイテムを削除
local function RemoveItemFromInventory(src, itemName, amount)
    amount = math.floor(tonumber(amount) or 1)
    if amount < 1 then return false end
    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:RemoveItem(src, itemName, amount)
    end
    if GetResourceState("qb-inventory") == "started" then
        exports["qb-inventory"]:RemoveItem(src, itemName, amount)
        return true
    end
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.RemoveItem(itemName, amount)
        return true
    end
    return false
end

-- 所持アイテム数取得（ox_inventory / qb-inventory 対応）
local function GetItemCount(src, itemName)
    if GetResourceState("ox_inventory") == "started" then
        local count = exports.ox_inventory:GetItemCount(src, itemName)
        return count or 0
    end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return 0 end
    local item = Player.Functions.GetItemByName(itemName)
    return (item and item.amount) or 0
end

-- 起動時にテーブルがなければ自動作成し、xp カラムを追加（DB名に依存しない）
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `metal_detector_players` (
            `citizenid` varchar(50) NOT NULL,
            `rare_items` int NOT NULL DEFAULT 0,
            `xp` int NOT NULL DEFAULT 0,
            `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]], {}, function()
    end)
end)

-- 金属探知機を「使用」すると探知モードON/OFF（クライアントでビープ・円を表示）
QBCore.Functions.CreateUseableItem(Config.MetalDetectorItem, function(source, item)
    TriggerClientEvent("metal_detector:toggle", source)
end)

-- 金属探知機所持チェック
QBCore.Functions.CreateCallback("metal:hasDetector", function(source, cb)
    local src = source
    local n = GetItemCount(src, Config.MetalDetectorItem)
    cb(n > 0)
end)

-- 宝の位置リスト（ゾーン内ランダム湧き。1回取ったら消えて別の場所に1つ湧く）
local treasurePositions = {}
local zone = Config.TreasureZone or { center = vector3(-1605, -1028, 13), radius = 45, zMin = 12, zMax = 15 }

local function getRandomPositionInZone()
    local angle = math.random() * 2 * math.pi
    local r = math.sqrt(math.random()) * (zone.radius or 40)
    local cx, cy, cz = zone.center.x, zone.center.y, zone.center.z
    local zMin, zMax = zone.zMin or (cz - 2), zone.zMax or (cz + 2)
    local x = cx + r * math.cos(angle)
    local y = cy + r * math.sin(angle)
    local z = zMin + math.random() * (zMax - zMin)
    return { x = x, y = y, z = z }
end

local function initTreasurePositions()
    treasurePositions = {}
    local n = math.max(1, math.min(30, Config.TreasureCount or 8))
    for i = 1, n do
        treasurePositions[#treasurePositions + 1] = getRandomPositionInZone()
    end
    print("^2[metal_detector]^7 宝を " .. n .. " 個ランダムに湧かせました。")
end

CreateThread(function()
    Wait(1000)
    initTreasurePositions()
end)

QBCore.Functions.CreateCallback("metal:getTreasurePositions", function(source, cb)
    local list = {}
    for _, p in ipairs(treasurePositions) do
        list[#list + 1] = { x = p.x, y = p.y, z = p.z }
    end
    cb(list)
end)

-- 掘削処理（プレイヤー位置に最も近い宝を取得。取ったらその宝を削除し、ゾーン内に1つ新規湧き）
RegisterNetEvent("metal:dig")
AddEventHandler("metal:dig", function(digX, digY, digZ)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- 掘るには常に金属探知機の所持が必須
    local item = Player.Functions.GetItemByName(Config.MetalDetectorItem)
    if not item or item.amount < 1 then
        TriggerClientEvent("metal:digResult", src, false)
        return
    end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local px, py, pz = coords.x, coords.y, coords.z
    local checkX = (type(digX) == "number") and digX or px
    local checkY = (type(digY) == "number") and digY or py
    local checkZ = (type(digZ) == "number") and digZ or pz

    local maxDist = Config.DigDistance + 3.0
    local nearestIdx = nil
    local nearestDist = 999999.0
    for i, p in ipairs(treasurePositions) do
        local d = #(vector3(checkX, checkY, checkZ) - vector3(p.x, p.y, p.z))
        if d < nearestDist and d <= maxDist then
            nearestDist = d
            nearestIdx = i
        end
    end

    if not nearestIdx then
        TriggerClientEvent("metal:digResult", src, false)
        return
    end

    local distFromPlayer = #(vector3(px, py, pz) - vector3(treasurePositions[nearestIdx].x, treasurePositions[nearestIdx].y, treasurePositions[nearestIdx].z))
    if distFromPlayer > maxDist then
        TriggerClientEvent("metal:digResult", src, false)
        return
    end

    table.remove(treasurePositions, nearestIdx)
    treasurePositions[#treasurePositions + 1] = getRandomPositionInZone()

    -- 報酬計算（お金は付与しない。アイテム＋XP のみ）
    local isRare = math.random() < Config.Rewards.rareChance
    local itemName = ""

    if isRare and #Config.Rewards.rareItems > 0 then
        itemName = Config.Rewards.rareItems[math.random(#Config.Rewards.rareItems)]
        AddItemToInventory(src, itemName, 1)
    end

    if #Config.Rewards.commonItems > 0 then
        local common = Config.Rewards.commonItems[math.random(#Config.Rewards.commonItems)]
        local amount = math.random(1, 3)
        AddItemToInventory(src, common, amount)
        if itemName == "" then itemName = common .. " x" .. amount end
    end

    -- XP 計算（掘るごと＋取ったものに応じて変動。お金ボーナスはなし）
    local xpBase = Config.XPBase or 10
    local xpRare = (Config.XPRareBonus or 50) * (isRare and 1 or 0)
    local xpGain = xpBase + xpRare

    -- DB 更新（ランキング用：XP とレア数）
    local citizenid = Player.PlayerData.citizenid
    MySQL.query(
        "INSERT INTO metal_detector_players (citizenid, rare_items, xp) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE rare_items = rare_items + ?, xp = xp + ?",
        { citizenid, isRare and 1 or 0, xpGain, isRare and 1 or 0, xpGain },
        function() end
    )

    TriggerClientEvent("metal:digResult", src, true, 0, itemName, isRare, xpGain)
end)

-- ランキング取得（XP 順）。表示名は players の charinfo から「街での名前」を取得
local function getDisplayNameFromCharinfo(charinfo)
    if not charinfo then return nil end
    if type(charinfo) == "string" then
        local ok, decoded = pcall(json.decode, charinfo)
        charinfo = (ok and decoded) or nil
    end
    if not charinfo or type(charinfo) ~= "table" then return nil end
    for _, key in ipairs(Config.RankingNameFields or { "streetname", "nickname", "displayname" }) do
        local v = charinfo[key]
        if v and type(v) == "string" and v ~= "" then return v end
    end
    local first = charinfo.firstname or ""
    local last = charinfo.lastname or ""
    if first ~= "" or last ~= "" then return (first .. " " .. last):gsub("^%s+", ""):gsub("%s+$", "") end
    return nil
end

RegisterNetEvent("metal:getRanking")
AddEventHandler("metal:getRanking", function()
    local src = source
    MySQL.query(
        "SELECT citizenid, xp, rare_items FROM metal_detector_players ORDER BY xp DESC LIMIT ?",
        { Config.RankingLimit },
        function(result)
            result = result or {}
            local cids = {}
            for _, row in ipairs(result) do
                if row.citizenid then cids[#cids + 1] = row.citizenid end
            end
            if #cids == 0 then
                TriggerClientEvent("metal:sendRanking", src, result)
                return
            end
            local placeholders = table.concat((function()
                local t = {}
                for i = 1, #cids do t[i] = "?" end
                return t
            end)(), ",")
            MySQL.query("SELECT citizenid, charinfo FROM players WHERE citizenid IN (" .. placeholders .. ")", cids, function(rows)
                local nameByCid = {}
                if rows then
                    for _, row in ipairs(rows) do
                        nameByCid[row.citizenid] = getDisplayNameFromCharinfo(row.charinfo)
                    end
                end
                for _, row in ipairs(result) do
                    row.name = nameByCid[row.citizenid] or row.citizenid or "???"
                end
                TriggerClientEvent("metal:sendRanking", src, result)
            end)
        end
    )
end)

-- ショップ情報取得（金属探知機価格 + 売却可能な所持アイテム一覧）
QBCore.Functions.CreateCallback("metal:getShopData", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then cb(nil) return end

    local price = Config.Shop and Config.Shop.metalDetectorPrice or 500
    local sellList = {}

    for itemName, priceRange in pairs(Config.SellItems or {}) do
        local amount = GetItemCount(src, itemName)
        if amount > 0 then
            local label = itemName
            if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[itemName] then
                label = QBCore.Shared.Items[itemName].label or label
            end
            local minP = (type(priceRange) == "table") and priceRange.min or priceRange
            local maxP = (type(priceRange) == "table") and priceRange.max or priceRange
            sellList[#sellList + 1] = {
                name = itemName,
                label = label,
                amount = amount,
                priceMin = minP,
                priceMax = maxP,
            }
        end
    end

    cb({
        metalDetectorPrice = price,
        sellItems = sellList,
    })
end)

-- 金属探知機を購入
RegisterNetEvent("metal:buyDetector")
AddEventHandler("metal:buyDetector", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local price = Config.Shop and Config.Shop.metalDetectorPrice or 500
    local cash = Player.PlayerData.money["cash"] or 0

    if cash < price then
        TriggerClientEvent("metal:buyResult", src, false, L("buy_not_enough_money"))
        return
    end

    Player.Functions.RemoveMoney("cash", price)
    local added = AddItemToInventory(src, Config.MetalDetectorItem, 1)
    if not added then
        Player.Functions.AddMoney("cash", price)
        TriggerClientEvent("metal:buyResult", src, false, L("inventory_full"))
        return
    end
    TriggerClientEvent("metal:buyResult", src, true, L("buy_success"))
end)

-- アイテムを売却
RegisterNetEvent("metal:sellItem")
AddEventHandler("metal:sellItem", function(itemName, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    amount = math.floor(tonumber(amount) or 1)
    if amount < 1 then
        TriggerClientEvent("metal:sellResult", src, false, L("sell_invalid_amount"))
        return
    end

    local priceRange = Config.SellItems and Config.SellItems[itemName]
    if not priceRange then
        TriggerClientEvent("metal:sellResult", src, false, L("sell_cannot_sell"))
        return
    end
    local minP = (type(priceRange) == "table") and priceRange.min or priceRange
    local maxP = (type(priceRange) == "table") and priceRange.max or priceRange

    local have = GetItemCount(src, itemName)
    if have < amount then
        TriggerClientEvent("metal:sellResult", src, false, L("sell_not_enough"))
        return
    end

    local removed = RemoveItemFromInventory(src, itemName, amount)
    if not removed then
        TriggerClientEvent("metal:sellResult", src, false, L("sell_remove_failed"))
        return
    end
    -- 1個ごとに min～max のランダム価格を付けて合計
    local total = 0
    for _ = 1, amount do
        total = total + math.random(minP, maxP)
    end
    Player.Functions.AddMoney("cash", total)
    TriggerClientEvent("metal:sellResult", src, true, total, amount, itemName)
end)
