local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1
L0_1 = 0
L1_1 = nil
L2_1 = nil
L3_1 = false
L4_1 = 0.0
L5_1 = false
function L6_1()
  local L0_2, L1_2
  L0_2 = DoScreenFadeOut
  L1_2 = 0
  L0_2(L1_2)
  L0_2 = SetNui
  L1_2 = false
  L0_2(L1_2)
  while true do
    L0_2 = IsScreenFadedOut
    L0_2 = L0_2()
    if L0_2 then
      break
    end
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
  end
  L0_2 = lib
  L0_2 = L0_2.callback
  L0_2 = L0_2.await
  L1_2 = "um-multi:bucket:setRandomBucket"
  L0_2(L1_2)
  L0_2 = SetPlayerAndCamera
  L0_2()
end
UMShutDownNui = L6_1
function L6_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = SetNuiFocus
  L2_2 = A0_2
  L3_2 = A0_2
  L1_2(L2_2, L3_2)
  L1_2 = Debug
  L2_2 = "NUI:"
  L3_2 = tostring
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L2_2 = L2_2 .. L3_2
  L1_2(L2_2)
end
SetNui = L6_1
function L6_1(A0_2)
  local L1_2, L2_2
  if "mp_m_freemode_01" == A0_2 or "mp_f_freemode_01" == A0_2 then
    L1_2 = joaat
    L2_2 = A0_2
    L1_2 = L1_2(L2_2)
    if not L1_2 then
      L1_2 = A0_2
    end
    return L1_2
  else
    L1_2 = tonumber
    L2_2 = A0_2
    L1_2 = L1_2(L2_2)
    if nil ~= L1_2 then
      L1_2 = tonumber
      L2_2 = A0_2
      return L1_2(L2_2)
    else
      L1_2 = joaat
      L2_2 = A0_2
      L1_2 = L1_2(L2_2)
      if not L1_2 then
        L1_2 = A0_2
      end
      return L1_2
    end
  end
end
ModelJoat = L6_1
function L6_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = ModelJoat
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  A0_2 = L1_2
  L1_2 = RequestModel
  L2_2 = A0_2
  L1_2(L2_2)
  while true do
    L1_2 = HasModelLoaded
    L2_2 = A0_2
    L1_2 = L1_2(L2_2)
    if L1_2 then
      break
    end
    L1_2 = RequestModel
    L2_2 = A0_2
    L1_2(L2_2)
    L1_2 = Wait
    L2_2 = 0
    L1_2(L2_2)
  end
  L1_2 = SetPlayerModel
  L2_2 = cache
  L2_2 = L2_2.playerId
  L3_2 = A0_2
  L1_2(L2_2, L3_2)
  L1_2 = SetModelAsNoLongerNeeded
  L2_2 = A0_2
  L1_2(L2_2)
end
SetModel = L6_1
function L6_1(A0_2)
  local L1_2, L2_2
  L1_2 = Config
  L1_2 = L1_2.TimeSettings
  L1_2 = L1_2.SyncStatus
  if not L1_2 then
    L1_2 = Config
    L1_2 = L1_2.PerformanceMode
    if not L1_2 then
      L3_1 = A0_2
      L1_2 = L3_1
      if L1_2 then
        L1_2 = TriggerEvent
        L2_2 = "qb-weathersync:client:DisableSync"
        L1_2(L2_2)
      else
        L1_2 = TriggerEvent
        L2_2 = "qb-weathersync:client:EnableSync"
        L1_2(L2_2)
      end
      L1_2 = Config
      L1_2 = L1_2.TimeSettings
      L1_2 = L1_2.Weather
      if "RAIN" == L1_2 then
        L1_2 = 0.3
        L4_1 = L1_2
      else
        L1_2 = Config
        L1_2 = L1_2.TimeSettings
        L1_2 = L1_2.Weather
        if "THUNDER" == L1_2 then
          L1_2 = 0.5
          L4_1 = L1_2
        end
      end
      L1_2 = CreateThread
      function L2_2()
        local L0_3, L1_3, L2_3, L3_3
        while true do
          L0_3 = L3_1
          if not L0_3 then
            break
          end
          L0_3 = SetRainLevel
          L1_3 = L4_1
          L0_3(L1_3)
          L0_3 = SetWeatherTypePersist
          L1_3 = Config
          L1_3 = L1_3.TimeSettings
          L1_3 = L1_3.Weather
          L0_3(L1_3)
          L0_3 = SetWeatherTypeNow
          L1_3 = Config
          L1_3 = L1_3.TimeSettings
          L1_3 = L1_3.Weather
          L0_3(L1_3)
          L0_3 = SetWeatherTypeNowPersist
          L1_3 = Config
          L1_3 = L1_3.TimeSettings
          L1_3 = L1_3.Weather
          L0_3(L1_3)
          L0_3 = NetworkOverrideClockTime
          L1_3 = Config
          L1_3 = L1_3.TimeSettings
          L1_3 = L1_3.Time
          L2_3 = 0
          L3_3 = 0
          L0_3(L1_3, L2_3, L3_3)
          L0_3 = Wait
          L1_3 = 0
          L0_3(L1_3)
        end
      end
      L1_2(L2_2)
    end
  end
end
SetTimeMultiCharacter = L6_1
function L6_1()
  local L0_2, L1_2, L2_2
  L0_2 = math
  L0_2 = L0_2.random
  L1_2 = 1
  L2_2 = Effect
  L2_2 = L2_2.List
  L2_2 = #L2_2
  L0_2 = L0_2(L1_2, L2_2)
  L1_2 = Effect
  L1_2 = L1_2.List
  L1_2 = L1_2[L0_2]
  return L1_2
end
RandomParticleEffect = L6_1
function L6_1()
  local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.Effects
  L0_2 = L0_2.Random
  if not L0_2 then
    L0_2 = Config
    L0_2 = L0_2.Effects
    L0_2 = L0_2.Single
    L0_2 = L0_2.pName
    L1_1 = L0_2
    L0_2 = Config
    L0_2 = L0_2.Effects
    L0_2 = L0_2.Single
    L0_2 = L0_2.pNameChild
    L2_1 = L0_2
  else
    L0_2 = RandomParticleEffect
    L0_2 = L0_2()
    L1_2 = L0_2.pName
    L1_1 = L1_2
    L1_2 = L0_2.pNameChild
    L2_1 = L1_2
  end
  L0_2 = L1_1
  L1_2 = L2_1
  return L0_2, L1_2
end
RandomCheckEffect = L6_1
function L6_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L0_2 = Config
  L0_2 = L0_2.PerformanceMode
  if not L0_2 then
    L0_2 = Config
    L0_2 = L0_2.Effects
    L0_2 = L0_2.Status
    if L0_2 then
      goto lbl_11
    end
  end
  do return end
  ::lbl_11::
  L0_2 = RandomCheckEffect
  L0_2, L1_2 = L0_2()
  L2_1 = L1_2
  L1_1 = L0_2
  L0_2 = DoesParticleFxLoopedExist
  L1_2 = L0_1
  L0_2 = L0_2(L1_2)
  if L0_2 then
    L0_2 = RemoveParticleFx
    L1_2 = L0_1
    L2_2 = false
    L0_2(L1_2, L2_2)
  end
  L0_2 = RequestNamedPtfxAsset
  L1_2 = L1_1
  L0_2(L1_2)
  while true do
    L0_2 = HasNamedPtfxAssetLoaded
    L1_2 = L1_1
    L0_2 = L0_2(L1_2)
    if L0_2 then
      break
    end
    L0_2 = Wait
    L1_2 = 10
    L0_2(L1_2)
  end
  L0_2 = UseParticleFxAssetNextCall
  L1_2 = L1_1
  L0_2(L1_2)
  L0_2 = DoesParticleFxLoopedExist
  L1_2 = L0_1
  L0_2 = L0_2(L1_2)
  if not L0_2 then
    L0_2 = StartParticleFxLoopedOnEntity
    L1_2 = L2_1
    L2_2 = cache
    L2_2 = L2_2.ped
    L3_2 = 0.0
    L4_2 = 1.0
    L5_2 = 0.0
    L6_2 = 0.0
    L7_2 = 0.0
    L8_2 = 0.0
    L9_2 = 1.1
    L10_2 = false
    L11_2 = false
    L12_2 = false
    L0_2 = L0_2(L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
    L0_1 = L0_2
  end
end
Particle = L6_1
function L6_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L0_2 = Config
  L0_2 = L0_2.Coords
  L0_2 = L0_2.Single
  L0_2 = L0_2.anim
  if not L0_2 then
    L0_2 = Config
    L0_2 = L0_2.Coords
    L0_2 = L0_2.Single
    L0_2 = L0_2.scenario
    if not L0_2 then
      goto lbl_43
    end
    L0_2 = Config
    L0_2 = L0_2.Coords
    L0_2 = L0_2.Random
    if L0_2 then
      goto lbl_43
    end
  end
  L0_2 = Config
  L0_2 = L0_2.Coords
  L0_2 = L0_2.Single
  L0_2 = L0_2.anim
  if L0_2 then
    L0_2 = Animation
    L0_2 = L0_2.Export
    L1_2 = Config
    L1_2 = L1_2.Coords
    L1_2 = L1_2.Single
    L1_2 = L1_2.anim
    L0_2(L1_2)
  else
    L0_2 = TaskStartScenarioInPlace
    L1_2 = cache
    L1_2 = L1_2.ped
    L2_2 = Config
    L2_2 = L2_2.Coords
    L2_2 = L2_2.Single
    L2_2 = L2_2.scenario
    L3_2 = 0
    L4_2 = true
    L0_2(L1_2, L2_2, L3_2, L4_2)
  end
  do return end
  ::lbl_43::
  L0_2 = Config
  L0_2 = L0_2.Animation
  L0_2 = L0_2.Status
  if not L0_2 then
    L0_2 = Config
    L0_2 = L0_2.Animation
    L0_2 = L0_2.Scenario
    L0_2 = L0_2.Status
    if not L0_2 then
      return
    end
  end
  L0_2 = Config
  L0_2 = L0_2.Animation
  L0_2 = L0_2.Status
  if L0_2 then
    L0_2 = Config
    L0_2 = L0_2.Animation
    L0_2 = L0_2.Random
    if L0_2 then
      L0_2 = math
      L0_2 = L0_2.random
      L1_2 = 1
      L2_2 = Animation
      L2_2 = L2_2.List
      L2_2 = #L2_2
      L0_2 = L0_2(L1_2, L2_2)
      L1_2 = Animation
      L1_2 = L1_2.List
      L1_2 = L1_2[L0_2]
      L2_2 = Animation
      L2_2 = L2_2.Export
      L3_2 = L1_2
      L2_2(L3_2)
    else
      L0_2 = Animation
      L0_2 = L0_2.Export
      L1_2 = Config
      L1_2 = L1_2.Animation
      L1_2 = L1_2.Single
      L0_2(L1_2)
    end
  else
    L0_2 = Config
    L0_2 = L0_2.Animation
    L0_2 = L0_2.Scenario
    L0_2 = L0_2.Status
    if L0_2 then
      L0_2 = Config
      L0_2 = L0_2.Animation
      L0_2 = L0_2.Scenario
      L0_2 = L0_2.Random
      if L0_2 then
        L0_2 = math
        L0_2 = L0_2.random
        L1_2 = 1
        L2_2 = Animation
        L2_2 = L2_2.ScenarioList
        L2_2 = #L2_2
        L0_2 = L0_2(L1_2, L2_2)
        L1_2 = Animation
        L1_2 = L1_2.ScenarioList
        L1_2 = L1_2[L0_2]
        L2_2 = TaskStartScenarioInPlace
        L3_2 = cache
        L3_2 = L3_2.ped
        L4_2 = L1_2
        L5_2 = 0
        L6_2 = true
        L2_2(L3_2, L4_2, L5_2, L6_2)
      else
        L0_2 = TaskStartScenarioInPlace
        L1_2 = cache
        L1_2 = L1_2.ped
        L2_2 = Config
        L2_2 = L2_2.Animation
        L2_2 = L2_2.Scenario
        L2_2 = L2_2.Single
        L3_2 = 0
        L4_2 = true
        L0_2(L1_2, L2_2, L3_2, L4_2)
      end
    end
  end
end
AnimationPlay = L6_1
function L6_1(A0_2)
  local L1_2, L2_2
  L1_2 = Config
  L1_2 = L1_2.CleanZone
  if not L1_2 then
    return
  end
  L5_1 = A0_2
  L1_2 = CreateThread
  function L2_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3
    while true do
      L0_3 = L5_1
      if not L0_3 then
        break
      end
      L0_3 = Wait
      L1_3 = 0
      L0_3(L1_3)
      L0_3 = PlayerPedId
      L0_3 = L0_3()
      L1_3 = GetEntityCoords
      L2_3 = L0_3
      L1_3 = L1_3(L2_3)
      L2_3 = ClearAreaOfPeds
      L3_3 = L1_3.x
      L4_3 = L1_3.y
      L5_3 = L1_3.z
      L6_3 = 100.0
      L7_3 = false
      L2_3(L3_3, L4_3, L5_3, L6_3, L7_3)
    end
  end
  L1_2(L2_2)
end
ClearPeds = L6_1
function L6_1(A0_2)
  local L1_2, L2_2
  L1_2 = Config
  L1_2 = L1_2.CustomHud
  L2_2 = A0_2
  L1_2(L2_2)
  L1_2 = Config
  L1_2 = L1_2.HideRadar
  if not L1_2 then
    return
  end
  if A0_2 then
    L1_2 = DisplayRadar
    L2_2 = false
    L1_2(L2_2)
  else
    L1_2 = DisplayRadar
    L2_2 = true
    L1_2(L2_2)
  end
end
HideRadar = L6_1
function L6_1()
  local L0_2, L1_2, L2_2
  L0_2 = math
  L0_2 = L0_2.random
  L1_2 = 1
  L2_2 = DefaultSpawnCoords
  L2_2 = #L2_2
  L0_2 = L0_2(L1_2, L2_2)
  L1_2 = DefaultSpawnCoords
  L1_2 = L1_2[L0_2]
  return L1_2
end
DefaultRandomCoords = L6_1
