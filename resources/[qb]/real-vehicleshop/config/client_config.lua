function DrawText3D(msg, coords)
    AddTextEntry('esxFloatingHelpNotification', msg)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('esxFloatingHelpNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end

function ShowHelpNotification(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end


-- Vehicleshop
Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        local Player = PlayerPedId()
        local PlayerCoords = GetEntityCoords(Player)
        for k, v in pairs(Config.Vehicleshops) do
            local Distance = #(PlayerCoords - v.ShopOpenCoords)
            if Distance < 20.0 then
                sleep = 3
                DrawMarker(
                    2,
                    v.ShopOpenCoords.x, v.ShopOpenCoords.y, v.ShopOpenCoords.z + 0.15,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.35, 0.35, 0.2,
                    0, 170, 255, 140,
                    false, true, 2, nil, nil, false
                )
                if Distance < 2.0 then
                    DrawText3D(v.Marker, v.ShopOpenCoords)
                    if CheckPlayerJob(k) then
                        if IsControlJustReleased(0, 38) then
                            OpenVehicleshop(k)
                        end
                    else
                        Config.Notification(Language('not_allowed_to_open_vs'), 'error', false)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

-- Boss menu
Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        local Player = PlayerPedId()
        local PlayerCoords = GetEntityCoords(Player)
        for k, v in pairs(Config.Vehicleshops) do
            if v.Manageable then
                local Distance = #(PlayerCoords - v.BossmenuCoords)
                if Distance < 2.0 then
                    sleep = 3
                    if v.Owner ~= "" then
                        if CheckAccess(k) then
                            DrawText3D(Language('bossmenu_marker'), v.BossmenuCoords)
                            if IsControlJustReleased(0, 38) then
                                OpenBossmenu(k)
                            end
                        end
                    else
                        if v.Owner == "" then
                            DrawText3D(Language('buy_company_marker'), v.BossmenuCoords)
                            if IsControlJustReleased(0, 38) then
                                BuyCompany(k)
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

-- Complaint Form (disabled)

RegisterNetEvent('real-vehicleshop:SendMailToOnlinePlayer', function(sender, subject, message) -- Here is the place to send mail to active players. You can organize it according to yourself.
    TriggerServerEvent(Config.PhoneMailOnline, {
        sender = sender,
        subject = subject,
        message = message
    })
end)

-- ATM feature disabled