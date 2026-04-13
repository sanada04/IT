local QBCore = exports['qb-core']:GetCoreObject()

local searching = false
local metalMenuUIOpen = false  -- UI表示中は「金属探知メニューを開く」を非表示にする
local npcBlip = nil
local zoneBlip = nil   -- マップに表示する掘れる範囲の円
local cachedHasDetector = false
local canDigFromServer = false  -- 掘り可能範囲にいるときだけサーバーに問い合わせた結果（キャッシュに頼らない）
local detectorActive = false  -- 金属探知機を「使用」したときだけ true（ビープ・円を表示）
local treasurePositions = {}  -- 宝の座標リスト { {x,y,z}, ... }（サーバーから取得）
local detectorProp = nil     -- 手に持つ金属探知機プロップ（探知ON時）

-- NPC 生成
CreateThread(function()
    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end

    local npc = CreatePed(4, model,
        Config.NPC.coords.x,
        Config.NPC.coords.y,
        Config.NPC.coords.z - 1,
        Config.NPC.coords.w,
        false,
        true)

    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    if Config.NPC.blip and Config.NPC.blip.enabled then
        npcBlip = AddBlipForCoord(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
        SetBlipSprite(npcBlip, Config.NPC.blip.sprite)
        SetBlipDisplay(npcBlip, 4)
        SetBlipScale(npcBlip, 1.0)
        SetBlipColour(npcBlip, Config.NPC.blip.color)
        SetBlipAsShortRange(npcBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.NPC.blip.label or "金属探知 JOB")  -- マップは日本語非対応のため英語のまま
        EndTextCommandSetBlipName(npcBlip)
    end

    -- マップに掘れる範囲を色付きの円で表示
    local zone = Config.TreasureZone
    if zone and zone.showOnMap and zone.center and zone.radius then
        zoneBlip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
        SetBlipColour(zoneBlip, zone.mapBlipColor or 5)
        SetBlipAlpha(zoneBlip, math.max(0, math.min(255, zone.mapBlipAlpha or 80)))
    end
end)

-- NPC 付近で [E] で UI オープン
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local npcPos = vector3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
        local dist = #(coords - npcPos)

        if dist < 2.0 then
            if IsControlJustPressed(0, 38) then
                metalMenuUIOpen = true
                SetNuiFocus(true, true)
                local strings = Locale[Config.Locale or "ja"] or Locale["ja"]
                SendNUIMessage({ type = "open", strings = strings })
                TriggerServerEvent("metal:getRanking")
                QBCore.Functions.TriggerCallback("metal:getShopData", function(data)
                    SendNUIMessage({ type = "shopData", data = data })
                end)
            end
        end
    end
end)

-- 金属探知機所持チェックを即時更新
local function refreshHasDetector()
    QBCore.Functions.TriggerCallback("metal:hasDetector", function(result)
        cachedHasDetector = result
    end)
end

-- 金属探知機所持チェック（キャッシュ）。探知ON/OFFやメニュー用
CreateThread(function()
    while true do
        Wait(2000)
        refreshHasDetector()
    end
end)


-- 日本語ワールドラベル用（NUIで表示するため文字化けしない）
function DrawText3DJapanese(x, y, z, text)
    local on, sx, sy = World3dToScreen2d(x, y, z)
    if on and text and text ~= "" then
        SendNUIMessage({ type = "worldLabel", visible = true, x = sx, y = sy, text = text })
    else
        SendNUIMessage({ type = "worldLabel", visible = false })
    end
end

function HideJapaneseLabel()
    SendNUIMessage({ type = "worldLabel", visible = false })
end

-- 宝の座標一覧を取得（探知ON時・定期的に更新）
local function refreshTreasurePositions()
    QBCore.Functions.TriggerCallback("metal:getTreasurePositions", function(list)
        treasurePositions = list or {}
    end)
end

-- 日本語ラベル表示（NPCはそのまま。掘削は「宝あり」かつ掘れる距離のときだけ [E] 掘る）
local lastShowDig = false  -- 「掘る」表示が前フレームで出ていたか（表示が出た瞬間に音を鳴らす用）
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local npcPos = vector3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
        local distNpc = #(coords - npcPos)

        if distNpc < 2.0 then
            lastShowDig = false
            if metalMenuUIOpen then
                HideJapaneseLabel()
            else
                DrawText3DJapanese(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z + 1, L("menu_open_label"))
            end
        elseif canDigFromServer and detectorActive then
            local showDig = false
            for _, pos in ipairs(treasurePositions) do
                local p = vector3(pos.x, pos.y, pos.z)
                local d = #(coords - p)
                if d <= Config.DigDistance then
                    DrawText3DJapanese(pos.x, pos.y, pos.z + 0.3, L("dig_label"))
                    showDig = true
                    break
                end
            end
            if showDig and not lastShowDig and Config.DigReadySound then
                SendNUIMessage({ type = "digReadySound" })
            end
            lastShowDig = showDig
            if not showDig then
                HideJapaneseLabel()
            end
        else
            lastShowDig = false
            HideJapaneseLabel()
        end
    end
end)

-- 金属探知機「使用」で探知モードON/OFF（ビープ・円はこのときだけ）
RegisterNetEvent("metal_detector:toggle")
AddEventHandler("metal_detector:toggle", function()
    if not cachedHasDetector then return end
    detectorActive = not detectorActive
    if detectorActive then
        refreshTreasurePositions()
    else
        SendNUIMessage({ type = "metalDetectorBeep", active = false })
        if detectorProp then
            DeleteEntity(detectorProp)
            detectorProp = nil
            ClearPedTasks(PlayerPedId())
        end
        -- 装備を外した直後にキャッシュを更新（外した状態で掘れないようにする）
        refreshHasDetector()
    end
    QBCore.Functions.Notify(detectorActive and L("detector_on") or L("detector_off"), detectorActive and "success" or "primary", 3000)
end)

-- 探知ON時：金属探知機を手に持つモーション（プロップ＋アニメーション）
CreateThread(function()
    local cfg = Config.DetectorProp or {}
    local fallbackModel = GetHashKey("prop_cs_hand_radio")  -- GTA V に必ずあるプロップ
    local bone = cfg.bone or 18905  -- 右手 SKEL_R_Hand
    local offset = cfg.offset or vector3(0.08, 0.03, 0.0)
    local rot = cfg.rotation or vector3(-90.0, 0.0, 0.0)
    local animDict = cfg.animDict or "anim@mp_radio@garage@low"
    local animName = cfg.animName or "action_a"
    local animFlag = (cfg.flag ~= nil) and cfg.flag or 49

    local function tryCreateProp()
        local modelHash = cfg.model and GetHashKey(cfg.model) or fallbackModel
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 150 do
            Wait(10)
            timeout = timeout + 1
        end
        if not HasModelLoaded(modelHash) then
            modelHash = fallbackModel
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) and timeout < 200 do Wait(10); timeout = timeout + 1 end
        end
        return modelHash
    end

    while true do
        Wait(500)
        local ped = PlayerPedId()
        if detectorActive and cachedHasDetector then
            if not detectorProp and not searching then
                local coords = GetEntityCoords(ped)
                local modelHash = tryCreateProp()
                if HasModelLoaded(modelHash) then
                    detectorProp = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
                    if DoesEntityExist(detectorProp) then
                        SetEntityAsMissionEntity(detectorProp, true, true)
                        local boneIndex = GetPedBoneIndex(ped, bone)
                        AttachEntityToEntity(detectorProp, ped, boneIndex, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
                        RequestAnimDict(animDict)
                        while not HasAnimDictLoaded(animDict) do Wait(10) end
                        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, animFlag, 0, false, false, false)
                    else
                        detectorProp = nil
                    end
                end
            end
        else
            if detectorProp then
                if DoesEntityExist(detectorProp) then DeleteEntity(detectorProp) end
                detectorProp = nil
                ClearPedTasks(ped)
            end
        end
    end
end)

-- 宝への最短距離を取得
local function getMinDistToTreasure(coords)
    local minDist = 999999.0
    for _, pos in ipairs(treasurePositions) do
        local d = #(coords - vector3(pos.x, pos.y, pos.z))
        if d < minDist then minDist = d end
    end
    return minDist
end

-- 掘れるかはサーバーに都度問い合わせ（掘り可能範囲にいるときだけ）。装備外し後も掘れないようにする
CreateThread(function()
    while true do
        Wait(400)
        local coords = GetEntityCoords(PlayerPedId())
        local minDist = getMinDistToTreasure(coords)
        if minDist <= Config.DetectDistance then
            QBCore.Functions.TriggerCallback("metal:hasDetector", function(result)
                canDigFromServer = result
            end)
        else
            canDigFromServer = false
        end
    end
end)

-- 金属探知ビープ：探知モードONのときだけ、宝ありスポットへの距離でビープ（NUIは音のみ。円は下の3Dで描画）
CreateThread(function()
    local lastTreasureRefresh = 0
    while true do
        Wait(100)
        if not cachedHasDetector or not detectorActive or searching then
            SendNUIMessage({ type = "metalDetectorBeep", active = false })
        else
            if GetGameTimer() - lastTreasureRefresh > 10000 then
                refreshTreasurePositions()
                lastTreasureRefresh = GetGameTimer()
            end
            local coords = GetEntityCoords(PlayerPedId())
            local minDist = getMinDistToTreasure(coords)
            local inRange = minDist <= Config.DetectDistance
            local veryClose = minDist <= Config.DigDistance
            SendNUIMessage({
                type = "metalDetectorBeep",
                active = true,
                distance = inRange and minDist or (Config.DetectDistance + 1),
                detectDistance = Config.DetectDistance,
                digDistance = Config.DigDistance,
                intervalMin = Config.BeepIntervalMin,
                intervalMax = Config.BeepIntervalMax,
                intervalVeryClose = Config.BeepIntervalVeryClose or 120,
                inRange = inRange,
                veryClose = veryClose
            })
        end
    end
end)

-- プレイヤー足元に3Dの円（リング）を描画。遠い＝赤、近い＝緑
CreateThread(function()
    local radius = math.max(1.5, math.min(4.0, Config.DetectorCircleRadius or 2.2))
    while true do
        Wait(0)
        if not cachedHasDetector or not detectorActive then
            -- 何も描画しない
        else
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local px, py, pz = coords.x, coords.y, coords.z
            local gz = pz - 0.95
            local minDist = getMinDistToTreasure(coords)
            local detectDist = Config.DetectDistance
            local digDist = Config.DigDistance
            local t = (detectDist > digDist) and ((minDist - digDist) / (detectDist - digDist)) or 0
            t = math.max(0, math.min(1, t))
            local heat = 1 - t
            local r = math.floor(220 * (1 - heat) + 80 * heat)
            local g = math.floor(50 * (1 - heat) + 200 * heat)
            local b = math.floor(50 * (1 - heat) + 80 * heat)
            DrawMarker(1, px, py, gz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius * 2, radius * 2, 0.08, r, g, b, 200, false, true, 2, false, nil, nil, false)
        end
    end
end)

-- 金属探知・掘削ループ（[E]押下のみ。表示は上記スレッドで実施）
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if canDigFromServer and detectorActive then
            for _, pos in ipairs(treasurePositions) do
                local p = vector3(pos.x, pos.y, pos.z)
                local d = #(coords - p)

                if Config.Debug then
                    DrawMarker(1, pos.x, pos.y, pos.z - 1.0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 200, 0, 100, false, true, 2, false, nil, nil, false)
                end

                if d < Config.DetectDistance then
                    sleep = 0
                    if d <= Config.DigDistance then
                        if IsControlJustPressed(0, 38) then
                            StartDig()
                            refreshTreasurePositions()
                            break
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

function StartDig()
    local ped = PlayerPedId()
    if searching then return end
    searching = true
    local coords = GetEntityCoords(ped)

    -- 掘削中は手元の金属探知機プロップを外す（掘り終わりで自動で再表示される）
    if detectorProp then
        if DoesEntityExist(detectorProp) then DeleteEntity(detectorProp) end
        detectorProp = nil
    end
    ClearPedTasks(ped)

    -- 掘削アニメーション
    RequestAnimDict("amb@world_human_gardener_plant@male@base")
    while not HasAnimDictLoaded("amb@world_human_gardener_plant@male@base") do
        Wait(0)
    end
    TaskPlayAnim(ped, "amb@world_human_gardener_plant@male@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    FreezeEntityPosition(ped, true)

    -- NUI プログレス
    SendNUIMessage({ type = "digStart", duration = Config.DigDuration })
    Wait(Config.DigDuration)

    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)
    SendNUIMessage({ type = "digEnd" })

    TriggerServerEvent("metal:dig", coords.x, coords.y, coords.z)
    searching = false
end

-- アイテムIDを表示名（label）に変換（"md_metal_scrap x2" → "掘り出し金属 x2"）
local function getItemDisplayName(itemName)
    if not itemName or itemName == "" then return itemName end
    local baseName, amountSuffix = itemName:match("^(.+)%s+x(%d+)$")
    baseName = baseName or itemName
    local label = baseName
    if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[baseName] then
        label = QBCore.Shared.Items[baseName].label or baseName
    end
    if amountSuffix then
        return label .. " x" .. amountSuffix
    end
    return label
end

RegisterNetEvent("metal:digResult")
AddEventHandler("metal:digResult", function(success, money, itemName, isRare, xpGain)
    if success then
        refreshTreasurePositions()
        if money and money > 0 then
            QBCore.Functions.Notify(string.format(L("dig_found_money"), money), "success", 4000)
        end
        if itemName and itemName ~= "" then
            local displayName = getItemDisplayName(itemName)
            local msg = isRare and (L("rare_label") .. displayName) or (L("item_label") .. displayName)
            QBCore.Functions.Notify(msg, "success", 4000)
        end
        if xpGain and xpGain > 0 then
            QBCore.Functions.Notify(string.format(L("xp_gain"), xpGain), "success", 3000)
        end
    else
        QBCore.Functions.Notify(L("dig_fail"), "error", 3000)
    end
end)

-- NUI
RegisterNUICallback("close", function(_, cb)
    metalMenuUIOpen = false
    SetNuiFocus(false, false)
    if cb then cb("ok") end
end)

RegisterNUICallback("getRanking", function(_, cb)
    TriggerServerEvent("metal:getRanking")
    if cb then cb("ok") end
end)

RegisterNUICallback("buyDetector", function(_, cb)
    TriggerServerEvent("metal:buyDetector")
    if cb then cb("ok") end
end)

RegisterNUICallback("sellItem", function(data, cb)
    TriggerServerEvent("metal:sellItem", data.itemName or data.name, data.amount or 1)
    if cb then cb("ok") end
end)

RegisterNUICallback("refreshSellList", function(_, cb)
    QBCore.Functions.TriggerCallback("metal:getShopData", function(shopData)
        SendNUIMessage({ type = "shopData", data = shopData })
        if cb then cb("ok") end
    end)
end)

RegisterNetEvent("metal:sendRanking")
AddEventHandler("metal:sendRanking", function(data)
    SendNUIMessage({ type = "ranking", ranking = data })
end)

RegisterNetEvent("metal:buyResult")
AddEventHandler("metal:buyResult", function(success, message)
    QBCore.Functions.Notify(message or (success and L("buy_ok") or L("buy_fail")), success and "success" or "error", 4000)
    if success then
        QBCore.Functions.TriggerCallback("metal:getShopData", function(shopData)
            SendNUIMessage({ type = "shopData", data = shopData })
        end)
    end
end)

RegisterNetEvent("metal:sellResult")
AddEventHandler("metal:sellResult", function(success, totalOrMessage, amount, itemName)
    if success then
        QBCore.Functions.Notify(string.format(L("sell_ok"), totalOrMessage or 0), "success", 4000)
        QBCore.Functions.TriggerCallback("metal:getShopData", function(shopData)
            SendNUIMessage({ type = "shopData", data = shopData })
        end)
    else
        QBCore.Functions.Notify(totalOrMessage or L("sell_fail"), "error", 4000)
    end
end)

function DrawText3D(x, y, z, text)
    local on, _x, _y = World3dToScreen2d(x, y, z)
    if on then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
