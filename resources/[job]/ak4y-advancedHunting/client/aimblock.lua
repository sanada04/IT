local hasHuntingRifle = false
local isFreeAiming = false
local function processScope(freeAiming)
  if not isFreeAiming and freeAiming then
    isFreeAiming = true
  elseif isFreeAiming and not freeAiming then
    isFreeAiming = false
  end
end

local blockShotActive = false
local function blockShooting()
    if blockShotActive then return end
    blockShotActive = true
    Citizen.CreateThread(function()
        while hasHuntingRifle do
            local ply = PlayerId()
            local ped = PlayerPedId()
            local ent = nil
            local aiming, ent = GetEntityPlayerIsFreeAimingAt(ply)
            local freeAiming = IsPlayerFreeAiming(ply)
            processScope(freeAiming)
            local et = GetEntityType(ent)
            if not freeAiming
                or IsPedAPlayer(ent)
                or et == 2
                or (et == 1 and IsPedInAnyVehicle(ent))
            then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 47, true)
                DisableControlAction(0, 58, true)
                DisablePlayerFiring(ped, true)
            end
            Citizen.Wait(0)
        end
        blockShotActive = false
        processScope(false)
    end)
end

Citizen.CreateThread(function()
    local weapons = AK4Y.AimBlockWeapons

    while true do
        for k,v in pairs(weapons) do
            if GetSelectedPedWeapon(PlayerPedId()) == k then
                hasHuntingRifle = true
                blockShooting()
            else
                hasHuntingRifle = false
            end
        end
        Citizen.Wait(1000)
    end
end)

local bekle = 1000
local bolgede = false
Citizen.CreateThread(function()
    local weapons = AK4Y.AimBlockWeapons
    local zones = AK4Y.HuntLocations

    while true do
        local ped = PlayerPedId()
        if AK4Y.OnlyShootInZone then
            if IsPedArmed(ped, 4) then
                for k,v in pairs(zones) do
                    if GetDistanceBetweenCoords(GetEntityCoords(ped), v.location, false) < v.radius then
                        bekle = 1000
                        bolgede = true
                    end
                end
                if not bolgede then
                    bekle = 1
                    for k,v in pairs(weapons) do
                        local silah = GetSelectedPedWeapon(PlayerPedId())
                        if silah == GetHashKey(k) then
                            DisablePlayerFiring(ped, true)
                            if IsControlJustReleased(0, 329) then
                                if GetAmmoInPedWeapon(ped, silah) > 0 then
                                    NOTIFY(AK4Y.Languages["cant_shoot_out_of_zone"])
                                else
                                    NOTIFY(AK4Y.Languages["refill_ammo_in_zone"])
                                end
                            end
                        end
                    end
                end
            else
                bekle = 1000
            end
        end
        bolgede = false
        Citizen.Wait(bekle)
    end
end)