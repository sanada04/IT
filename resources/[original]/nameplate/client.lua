local playerNames    = {}
local myServerId     = nil
local myEarnedTitles = {}
local hasSpawned     = false

-- ── ネームプレート送信スレッド (毎フレーム実行で頭に追従) ────────
CreateThread(function()
    while true do
        Wait(0)

        local canShow = hasSpawned
                     and not IsPauseMenuActive()
                     and not IsNuiFocused()

        local plates = {}

        if canShow and myServerId then
            local myPed    = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)

            for _, playerId in ipairs(GetActivePlayers()) do
                local ped      = GetPlayerPed(playerId)
                local serverId = GetPlayerServerId(playerId)

                -- 自分のスキップ / 死亡 / 乗り物乗車中はスキップ
                if (serverId ~= myServerId or Config.ShowSelf)
                    and not IsEntityDead(ped)
                    and not IsPedInAnyVehicle(ped, false) then

                    local pedCoords = GetEntityCoords(ped)
                    local dist      = #(myCoords - pedCoords)

                    if dist <= Config.DrawDistance then
                        local data = playerNames[serverId]
                        if data and data.name then
                            local onScreen, sx, sy = World3dToScreen2d(
                                pedCoords.x, pedCoords.y, pedCoords.z + 1.15
                            )
                            if onScreen then
                                plates[#plates + 1] = {
                                    id    = serverId,
                                    x     = sx,
                                    y     = sy,
                                    name  = data.name,
                                    title = data.title or '',
                                    nc    = data.nameColor  or Config.DefaultNameColor,
                                    tc    = data.titleColor or Config.DefaultTitleColor,
                                    dist  = math.floor(dist),
                                }
                            end
                        end
                    end
                end
            end
        end

        SendNUIMessage({ action = 'plates', plates = plates })
    end
end)

-- ── イベント受信 ─────────────────────────────────────────────────
RegisterNetEvent('nameplate:sync', function(data)
    playerNames = data
end)

RegisterNetEvent('nameplate:update', function(serverId, name, title, nameColor, titleColor)
    playerNames[serverId] = {
        name       = name,
        title      = title,
        nameColor  = nameColor,
        titleColor = titleColor,
    }
end)

RegisterNetEvent('nameplate:remove', function(serverId)
    playerNames[serverId] = nil
end)

RegisterNetEvent('nameplate:earnedTitles', function(titles)
    myEarnedTitles = titles or {}
end)

-- ── 同期リクエスト ────────────────────────────────────────────────
local function requestSync()
    myServerId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('nameplate:requestSync')
end

-- ── スポーン管理 ─────────────────────────────────────────────────
if Config.UseQBCore then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        hasSpawned = true
        requestSync()
    end)

    AddEventHandler('QBCore:Client:OnPlayerUnload', function()
        hasSpawned = false
        playerNames = {}
    end)
end

-- リソース再起動時: すでにインゲームなら即時有効化
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    CreateThread(function()
        Wait(2000)
        requestSync()
        if Config.UseQBCore then
            local ok, QBCore = pcall(function() return exports['qb-core']:GetCoreObject() end)
            if ok and QBCore then
                local pd = QBCore.Functions.GetPlayerData()
                if pd and pd.citizenid then
                    hasSpawned = true
                end
            end
        else
            hasSpawned = true
        end
    end)
end)

-- ── /name コマンド ────────────────────────────────────────────────
RegisterCommand('name', function()
    myServerId = myServerId or GetPlayerServerId(PlayerId())
    local d = playerNames[myServerId] or {}

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        data   = {
            name       = d.name       or '',
            title      = d.title      or '',
            nameColor  = d.nameColor  or Config.DefaultNameColor,
            titleColor = d.titleColor or Config.DefaultTitleColor,
            titles     = myEarnedTitles,
        }
    })
end, false)

RegisterNUICallback('save', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('nameplate:saveAll',
        data.name,
        data.titleId or '',
        data.nameColor,
        data.titleColor
    )
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
