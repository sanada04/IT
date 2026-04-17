-- █▀▀ █▀▄ █ ▀█▀ ▄▀█ █▄▄ █░░ █▀▀
-- ██▄ █▄▀ █ ░█░ █▀█ █▄█ █▄▄ ██▄
-- This file contains functions that can be customized for framework integrations
-- WARNING: Do not modify the function names or return types, only the internal logic

-- Prop attach coords (optional)
EditableSeatbeltAttachCoords = {
    driver = {x = -0.27, y = 0.05, z = -0.02, rotX = 0.0, rotY = 90.0, rotZ = 180.0},
    passenger = {x = -0.25, y = 0.05, z = 0.07, rotX = 0.0, rotY = 90.0, rotZ = 180.0}
}

-- return nil to skip creating any seatbelt prop (useful for harness integrations)
-- seatIndex: -1 = driver, 0 = front passenger, 1 = rear left, 2 = rear right
function GetSeatbeltPropModel(vehicle, ped, seatIndex)
    local isDriverSide = (seatIndex == -1 or seatIndex == 1)
    local modelName = isDriverSide and 'mst_seatbelt' or 'mst_seatbelt2'
    local attachCoords = isDriverSide and EditableSeatbeltAttachCoords.driver or EditableSeatbeltAttachCoords.passenger
    
    return modelName, attachCoords
end

-- return true if player is restricted (exit blocked + quick-exit blocked)
function IsPlayerRestricted()
    return false
end

-- return true to exclude vehicle, false to force include, nil = use Config
function CustomVehicleExclusion(vehicle)
    return nil
end

-- called on seatbelt state change
function OnSeatbeltToggle(seatbeltOn, vehicle)
end

-- damage when player has seatbelt ON during collision
-- impactSeverity: "low", "medium", or "high"
function ApplySeatbeltDamage(ped, damageAmount, impactSeverity)
    local currentHealth = GetEntityHealth(ped)
    local newHealth = math.max(100, currentHealth - damageAmount)
    SetEntityHealth(ped, newHealth)

    return newHealth
end

-- damage when player is ejected (no seatbelt)
function ApplyEjectionDamage(ped, damageAmount, impactSeverity, survived)
    local currentHealth = GetEntityHealth(ped)
    local targetHealth = currentHealth - damageAmount

    return targetHealth
end

-- death handler - deathReason: "damage" or "chance"
function HandleCollisionDeath(ped, coords, impactSeverity, deathReason)
    SetEntityHealth(ped, 0)
end

-- called after player is ejected from vehicle
function OnPlayerEjected(impactSpeed, impactSeverity, survived)
end

-- called on any significant collision (logging, external systems)
function OnCollisionDetected(impactSpeed, impactSeverity, hadSeatbelt, wasEjected)
end
