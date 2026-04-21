local playerNames = {}
local myServerId  = nil

-- ネームプレートをNUIに送信するスレッド
CreateThread(function()
    while true do
        Wait(50)

        local plates = {}

        if myServerId then
            local myPed    = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)

            for _, playerId in ipairs(GetActivePlayers()) do
                local ped      = GetPlayerPed(playerId)
                local serverId = GetPlayerServerId(playerId)

                -- ShowSelf=falseのとき自分をスキップ
                if (serverId ~= myServerId or Config.ShowSelf) and not IsEntityDead(ped) then
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

-- イベント受信
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

-- 同期リクエスト
local function requestSync()
    myServerId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('nameplate:requestSync')
end

-- リソース開始時 (2秒待ってから同期)
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CreateThread(function()
            Wait(2000)
            requestSync()
        end)
    end
end)

-- QBCore: キャラ読み込み完了時
if Config.UseQBCore then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        requestSync()
    end)
end

-- /name コマンド: 設定UIを開く
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
        }
    })
end, false)

RegisterNUICallback('save', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('nameplate:saveAll', data.name, data.title, data.nameColor, data.titleColor)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
