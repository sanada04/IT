local title = Lang:t('teleport.teleport_default')
local ran = false
local teleportPoly = {}

local function teleportMenu(zones, currentZone)
    local menu = {
        {
            header = Lang:t('teleport.teleport_default'),
            isMenuHeader = true
        }
    }
    for k, v in pairs(Config.Teleports[zones]) do
        if k ~= currentZone then
            if not v.label then
                title = Lang:t('teleport.teleport_default')
            else
                title = v.label
            end
            menu[#menu + 1] = {
                header = title,
                params = {
                    event = 'teleports:chooseloc',
                    args = {
                        car = Config.Teleports[zones][currentZone].allowVeh,
                        coords = v.poly.coords,
                        heading = v.poly.heading
                    }
                }
            }
        end
    end
    CreateThread(function()
        Wait(75)
        exports['qb-menu']:openMenu(menu)
    end)
end

CreateThread(function()
    if Config.UseTarget then
        for i = 1, #Config.Teleports, 1 do
            for u = 1, #Config.Teleports[i] do
                local portal = Config.Teleports[i][u]
                local zoneIndex = i
                local padIndex = u
                local zoneName = ('teleport_%s_%s'):format(zoneIndex, padIndex)
                local label = portal.label or Lang:t('teleport.teleport_default')
                local destination = nil

                for k, v in pairs(Config.Teleports[zoneIndex]) do
                    if k ~= padIndex then
                        destination = v
                        break
                    end
                end

                if not destination then
                    goto continue
                end

                exports['qb-target']:AddBoxZone(zoneName, portal.poly.coords, portal.poly.length, portal.poly.width, {
                    name = zoneName,
                    heading = portal.poly.heading,
                    debugPoly = false,
                    minZ = portal.poly.coords.z - 5,
                    maxZ = portal.poly.coords.z + 5,
                }, {
                    options = {
                        {
                            icon = 'fas fa-elevator',
                            label = label,
                            canInteract = function()
                                return destination ~= nil
                            end,
                            action = function()
                                TriggerEvent('teleports:chooseloc', {
                                    car = Config.Teleports[zoneIndex][padIndex].allowVeh,
                                    coords = destination.poly.coords,
                                    heading = destination.poly.heading
                                })
                            end,
                        }
                    },
                    distance = 2.0
                })
                ::continue::
            end
        end
        return
    end

    for i = 1, #Config.Teleports, 1 do
        for u = 1, #Config.Teleports[i] do
            local portal = Config.Teleports[i][u].poly
            teleportPoly[#teleportPoly + 1] = BoxZone:Create(vector3(portal.coords.x, portal.coords.y, portal.coords.z), portal.length, portal.width, {
                heading = portal.heading,
                name = i,
                debugPoly = false,
                minZ = portal.coords.z - 5,
                maxZ = portal.coords.z + 5,
                data = { pad = u }
            })
        end
    end

    local teleportCombo = ComboZone:Create(teleportPoly, { name = 'teleportPoly' })
    teleportCombo:onPlayerInOut(function(isPointInside, _, zone)
        if isPointInside then
            if not ran then
                ran = true
                teleportMenu(tonumber(zone.name), zone.data.pad)
            end
        else
            ran = false
        end
    end)
end)

RegisterNetEvent('teleports:chooseloc', function(data)
    local ped = PlayerPedId()
    -- Prefer InteractSound door effects (used by other QB resources).
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'houses_door_open', 0.2)
    -- Fallback frontend click in case custom sound pack is unavailable.
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    DoScreenFadeOut(500)
    Wait(500)
    if data.car then
        SetPedCoordsKeepVehicle(ped, data.coords.x, data.coords.y, data.coords.z)
    else
        SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z)
    end
    SetEntityHeading(ped, data.heading)
    Wait(500)
    DoScreenFadeIn(500)
end)