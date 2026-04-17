local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1, L24_1, L25_1, L26_1, L27_1, L28_1, L29_1, L30_1
L0_1 = GetGameplayCamRot
L1_1 = GetEntityHeading
L2_1 = GetEntityCoords
L3_1 = GetStreetNameAtCoord
L4_1 = GetStreetNameFromHashKey
L5_1 = GetNameOfZone
L6_1 = GetLabelText
L7_1 = GetEntityHealth
L8_1 = GetPedArmour
L9_1 = GetPlayerSprintStaminaRemaining
L10_1 = IsEntityInWater
L11_1 = GetPlayerUnderwaterTimeRemaining
L12_1 = NetworkIsPlayerTalking
L13_1 = GetClockHours
L14_1 = GetClockMinutes
L15_1 = GetPlayerMaxStamina
function L16_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L0_2 = UserSettingsData
  if L0_2 then
    L0_2 = L0_2.playerInfoTime
  end
  if "local" == L0_2 then
    L0_2 = GetLocalTime
    L0_2, L1_2, L2_2, L3_2, L4_2 = L0_2()
    L5_2 = string
    L5_2 = L5_2.format
    L6_2 = "%s:%s"
    L7_2 = string
    L7_2 = L7_2.format
    L8_2 = "%02d"
    L9_2 = L3_2
    L7_2 = L7_2(L8_2, L9_2)
    L8_2 = string
    L8_2 = L8_2.format
    L9_2 = "%02d"
    L10_2 = L4_2
    L8_2, L9_2, L10_2 = L8_2(L9_2, L10_2)
    return L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
  end
  L0_2 = string
  L0_2 = L0_2.format
  L1_2 = "%s:%s"
  L2_2 = string
  L2_2 = L2_2.format
  L3_2 = "%02d"
  L4_2 = L13_1
  L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L4_2()
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L3_2 = string
  L3_2 = L3_2.format
  L4_2 = "%02d"
  L5_2 = L14_1
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L5_2()
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  return L0_2(L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
end
function L17_1()
  local L0_2, L1_2
  L0_2 = UserSettingsData
  if L0_2 then
    L0_2 = L0_2.compassFollowCamera
  end
  if L0_2 then
    L0_2 = L0_1
    L1_2 = 0
    L0_2 = L0_2(L1_2)
    L1_2 = L0_2.z
    L1_2 = L1_2 + 360.0
    L1_2 = L1_2 % 360.0
    return L1_2
  end
  L0_2 = L1_1
  L1_2 = cache
  L1_2 = L1_2.ped
  return L0_2(L1_2)
end
function L18_1(A0_2)
  local L1_2, L2_2
  L1_2 = Config
  L1_2 = L1_2.CustomStreetNames
  if L1_2 then
    L2_2 = A0_2 & 4294967295
    L1_2 = L1_2[L2_2]
  end
  if not L1_2 then
    L1_2 = L4_1
    L2_2 = A0_2
    L1_2 = L1_2(L2_2)
    if not L1_2 then
      L1_2 = "Unknown"
    end
  end
  return L1_2
end
function L19_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L1_2 = L3_1
  L2_2 = A0_2.x
  L3_2 = A0_2.y
  L4_2 = A0_2.z
  L1_2, L2_2 = L1_2(L2_2, L3_2, L4_2)
  if 0 == L1_2 and 0 == L2_2 then
    L3_2 = false
    return L3_2
  end
  L3_2 = L18_1
  L4_2 = L1_2
  L3_2 = L3_2(L4_2)
  L4_2 = L3_2
  if L2_2 > 0 then
    L5_2 = "%s / %s"
    L6_2 = L5_2
    L5_2 = L5_2.format
    L7_2 = L4_2
    L8_2 = L18_1
    L9_2 = L2_2
    L8_2, L9_2 = L8_2(L9_2)
    L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2)
    L4_2 = L5_2
  end
  L5_2 = L3_2
  L6_2 = L4_2
  return L5_2, L6_2
end
function L20_1(A0_2)
  local L1_2, L2_2
  if not A0_2 then
    L1_2 = false
    return L1_2
  end
  L1_2 = Config
  L1_2 = L1_2.SpeedLimits
  if L1_2 then
    L1_2 = type
    L2_2 = Config
    L2_2 = L2_2.SpeedLimits
    L1_2 = L1_2(L2_2)
    if "table" == L1_2 then
      goto lbl_17
    end
  end
  L1_2 = false
  do return L1_2 end
  ::lbl_17::
  L1_2 = Config
  L1_2 = L1_2.SpeedLimits
  L1_2 = L1_2[A0_2]
  if not L1_2 then
    L1_2 = false
  end
  return L1_2
end
function L21_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = L17_1
  L0_2 = L0_2()
  L1_2 = {}
  L1_2[1] = "N"
  L1_2[2] = "NW"
  L1_2[3] = "W"
  L1_2[4] = "SW"
  L1_2[5] = "S"
  L1_2[6] = "SE"
  L1_2[7] = "E"
  L1_2[8] = "NE"
  L2_2 = math
  L2_2 = L2_2.floor
  L3_2 = L0_2 + 22.5
  L3_2 = L3_2 / 45
  L2_2 = L2_2(L3_2)
  L2_2 = L2_2 + 1
  if L2_2 > 8 then
    L2_2 = 1
  end
  L3_2 = L1_2[L2_2]
  L4_2 = L0_2
  return L3_2, L4_2
end
function L22_1(A0_2)
  local L1_2, L2_2
  L1_2 = Config
  L1_2 = L1_2.CustomZoneNames
  if L1_2 then
    L1_2 = L1_2[A0_2]
  end
  if not L1_2 then
    L1_2 = L6_1
    L2_2 = A0_2
    L1_2 = L1_2(L2_2)
  end
  return L1_2
end
function L23_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = L5_1
  L2_2 = A0_2.x
  L3_2 = A0_2.y
  L4_2 = A0_2.z
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  L2_2 = L22_1
  L3_2 = L1_2
  L2_2 = L2_2(L3_2)
  L3_2 = L2_2 or L3_2
  if "NULL" == L2_2 or not L2_2 then
    L3_2 = L1_2
  end
  return L3_2
end
function L24_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = Config
  L0_2 = L0_2.ShowComponents
  L0_2 = L0_2.pedAvatar
  if not L0_2 then
    L0_2 = false
    return L0_2
  end
  L0_2 = Config
  L0_2 = L0_2.CustomPedAvatarUrl
  if L0_2 and false ~= L0_2 and "" ~= L0_2 then
    return L0_2
  end
  L0_2 = lib
  L0_2 = L0_2.waitFor
  function L1_2()
    local L0_3, L1_3
    L0_3 = cache
    L0_3 = L0_3.ped
    if L0_3 then
      L0_3 = DoesEntityExist
      L1_3 = cache
      L1_3 = L1_3.ped
      L0_3 = L0_3(L1_3)
      if L0_3 then
        L0_3 = true
        return L0_3
      end
    end
  end
  L2_2 = nil
  L3_2 = 5000
  L0_2(L1_2, L2_2, L3_2)
  L0_2 = RegisterPedheadshot
  L1_2 = cache
  L1_2 = L1_2.ped
  L0_2 = L0_2(L1_2)
  L1_2 = lib
  L1_2 = L1_2.waitFor
  function L2_2()
    local L0_3, L1_3
    L0_3 = IsPedheadshotReady
    L1_3 = L0_2
    L0_3 = L0_3(L1_3)
    if L0_3 then
      L0_3 = IsPedheadshotValid
      L1_3 = L0_2
      L0_3 = L0_3(L1_3)
      if L0_3 then
        L0_3 = true
        return L0_3
      end
    end
  end
  L3_2 = "Could not load ped headshot"
  L4_2 = 5000
  L1_2(L2_2, L3_2, L4_2)
  L1_2 = GetPedheadshotTxdString
  L2_2 = L0_2
  L1_2 = L1_2(L2_2)
  L2_2 = string
  L2_2 = L2_2.format
  L3_2 = "https://nui-img/%s/%s"
  L4_2 = L1_2
  L5_2 = L1_2
  L2_2 = L2_2(L3_2, L4_2, L5_2)
  L3_2 = UnregisterPedheadshot
  L4_2 = L0_2
  L3_2(L4_2)
  return L2_2
end
GeneratePedHeadshot = L24_1
function L24_1()
  local L0_2, L1_2
  L0_2 = UserSettingsData
  if L0_2 then
    L0_2 = L0_2.performanceMode
  end
  if "ultra" == L0_2 then
    L0_2 = 50
    return L0_2
  end
  L0_2 = UserSettingsData
  if L0_2 then
    L0_2 = L0_2.performanceMode
  end
  if "performance" == L0_2 then
    L0_2 = 250
    return L0_2
  end
  L0_2 = UserSettingsData
  if L0_2 then
    L0_2 = L0_2.performanceMode
  end
  if "lowResmon" == L0_2 then
    L0_2 = 1000
    return L0_2
  end
  L0_2 = 500
  return L0_2
end
L25_1 = false
function L26_1()
  local L0_2, L1_2
  L0_2 = L25_1
  if L0_2 then
    return
  end
  L0_2 = true
  L25_1 = L0_2
  L0_2 = CreateThread
  function L1_2()
    local L0_3, L1_3, L2_3, L3_3
    while true do
      L0_3 = IsHudRunning
      if not L0_3 then
        break
      end
      L0_3 = SendNUIMessage
      L1_3 = {}
      L1_3.type = "isTalking"
      L2_3 = L12_1
      L3_3 = cache
      L3_3 = L3_3.playerId
      L2_3 = L2_3(L3_3)
      L1_3.isTalking = L2_3
      L0_3(L1_3)
      L0_3 = Wait
      L1_3 = 200
      L0_3(L1_3)
    end
    L0_3 = false
    L25_1 = L0_3
  end
  L0_2(L1_2)
end
CreateIsTalkingThread = L26_1
L26_1 = false
L27_1 = 100
L28_1 = false
L29_1 = 0
function L30_1()
  local L0_2, L1_2, L2_2
  L0_2 = L26_1
  if L0_2 then
    return
  end
  L0_2 = true
  L26_1 = L0_2
  L0_2 = Framework
  L0_2 = L0_2.Client
  L0_2 = L0_2.CreateEventListeners
  L0_2()
  L0_2 = L24_1
  L0_2 = L0_2()
  L1_2 = CreateThread
  function L2_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3
    while true do
      L0_3 = IsHudRunning
      if not L0_3 then
        break
      end
      L0_3 = cache
      L0_3 = L0_3.ped
      if not L0_3 then
        break
      end
      L0_3 = L29_1
      if 0 == L0_3 then
        L0_3 = Framework
        L0_3 = L0_3.Client
        L0_3 = L0_3.IsPlayerDead
        L0_3 = L0_3()
        L1_3 = 5
        L29_1 = L1_3
        L28_1 = L0_3
      else
        L0_3 = L29_1
        L0_3 = L0_3 - 1
        L29_1 = L0_3
      end
      L0_3 = L28_1
      if L0_3 then
        L0_3 = 0
        if L0_3 then
          goto lbl_35
        end
      end
      L0_3 = L7_1
      L1_3 = cache
      L1_3 = L1_3.ped
      L0_3 = L0_3(L1_3)
      L0_3 = L0_3 - 100
      ::lbl_35::
      L1_3 = L8_1
      L2_3 = cache
      L2_3 = L2_3.ped
      L1_3 = L1_3(L2_3)
      L2_3 = 100
      L3_3 = L28_1
      if L3_3 then
        L2_3 = 0
      else
        L3_3 = L10_1
        L4_3 = cache
        L4_3 = L4_3.ped
        L3_3 = L3_3(L4_3)
        if L3_3 then
          L3_3 = IsPedSwimmingUnderWater
          L4_3 = cache
          L4_3 = L4_3.ped
          L3_3 = L3_3(L4_3)
          if L3_3 then
            L3_3 = L11_1
            L4_3 = cache
            L4_3 = L4_3.playerId
            L3_3 = L3_3(L4_3)
            L2_3 = L3_3 * 10
          else
            L3_3 = GetPlayerStamina
            L4_3 = cache
            L4_3 = L4_3.playerId
            L3_3 = L3_3(L4_3)
            L2_3 = L3_3
          end
        else
          L3_3 = cache
          L3_3 = L3_3.vehicle
          if not L3_3 then
          L3_3 = math
          L3_3 = L3_3.max
          L4_3 = 0
          L5_3 = L9_1
          L6_3 = cache
          L6_3 = L6_3.playerId
          L5_3 = L5_3(L6_3)
          L3_3 = L3_3(L4_3, L5_3)
            L4_3 = L15_1
            L5_3 = cache
            L5_3 = L5_3.playerId
            L4_3 = L4_3(L5_3)
            L3_3 = L3_3 / L4_3
            L4_3 = 1
            L3_3 = L4_3 - L3_3
            L2_3 = L3_3 * 100
          end
        end
      end
      L3_3 = L16_1
      L3_3 = L3_3()
      L4_3 = L2_1
      L5_3 = cache
      L5_3 = L5_3.ped
      L4_3 = L4_3(L5_3)
      L5_3 = L21_1
      L5_3, L6_3 = L5_3()
      L7_3 = L19_1
      L8_3 = L4_3
      L7_3, L8_3 = L7_3(L8_3)
      L9_3 = L23_1
      L10_3 = L4_3
      L9_3 = L9_3(L10_3)
      L10_3 = SendNUIMessage
      L11_3 = {}
      L11_3.type = "pedData"
      L12_3 = {}
      L12_3.health = L0_3
      L12_3.armour = L1_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.hunger
      if not L13_3 then
        L13_3 = false
      end
      L12_3.food = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.thirst
      if not L13_3 then
        L13_3 = false
      end
      L12_3.water = L13_3
      L13_3 = L2_3 or L13_3
      if not L2_3 then
        L13_3 = false
      end
      L12_3.oxygen = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.stress
      if not L13_3 then
        L13_3 = false
      end
      L12_3.stress = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.job
      L12_3.job = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.gang
      L12_3.gang = L13_3
      L12_3.time = L3_3
      L13_3 = cache
      L13_3 = L13_3.serverId
      L12_3.playerId = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.cash
      L12_3.cash = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.bank
      L12_3.bank = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.dirtyMoney
      L12_3.dirtyMoney = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.micRange
      L12_3.micRange = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.radioActive
      L12_3.radioActive = L13_3
      L13_3 = LocalPlayer
      L13_3 = L13_3.state
      L13_3 = L13_3.radioChannel
      if not L13_3 then
        L13_3 = 0
      end
      L12_3.radioChannel = L13_3
      L13_3 = Framework
      L13_3 = L13_3.CachedPlayerData
      L13_3 = L13_3.voiceModes
      L12_3.voiceModes = L13_3
      L12_3.cardinalDirection = L5_3
      L12_3.heading = L6_3
      L13_3 = L8_3 or L13_3
      if not L8_3 then
        L13_3 = L9_3
      end
      L12_3.streetName = L13_3
      L12_3.areaName = L9_3
      L13_3 = GetNearestPostal
      L14_3 = L4_3
      L13_3 = L13_3(L14_3)
      L12_3.nearestPostal = L13_3
      L13_3 = L20_1
      L14_3 = L7_3
      L13_3 = L13_3(L14_3)
      L12_3.speedLimit = L13_3
      L11_3.pedData = L12_3
      L10_3(L11_3)
      L10_3 = Wait
      L11_3 = L0_2
      L10_3(L11_3)
    end
    L0_3 = false
    L26_1 = L0_3
  end
  L1_2(L2_2)
end
CreatePlayerThread = L30_1
