local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = nil
L1_1 = nil
L2_1 = nil
L3_1 = nil
function L4_1()
  local L0_2, L1_2, L2_2
  L0_2 = Config
  L0_2 = L0_2.Coords
  L0_2 = L0_2.Random
  if not L0_2 then
    L0_2 = Config
    L0_2 = L0_2.Coords
    L0_2 = L0_2.Single
    L0_2 = L0_2.pedCoords
    L2_1 = L0_2
    L0_2 = Config
    L0_2 = L0_2.Coords
    L0_2 = L0_2.Single
    L0_2 = L0_2.camCoords
    if L0_2 then
      L0_2 = "single"
      L3_1 = L0_2
    end
  else
    L0_2 = math
    L0_2 = L0_2.random
    L1_2 = Coords
    L1_2 = L1_2.List
    L1_2 = #L1_2
    L0_2 = L0_2(L1_2)
    L1_1 = L0_2
    while true do
      L0_2 = Coords
      L0_2 = L0_2.List
      L1_2 = L1_1
      L0_2 = L0_2[L1_2]
      L0_2 = L0_2.scenario
      if not L0_2 then
        L0_2 = Coords
        L0_2 = L0_2.List
        L1_2 = L1_1
        L0_2 = L0_2[L1_2]
        L0_2 = L0_2.anim
        if not L0_2 then
          break
        end
      end
      L0_2 = math
      L0_2 = L0_2.random
      L1_2 = Coords
      L1_2 = L1_2.List
      L1_2 = #L1_2
      L0_2 = L0_2(L1_2)
      L1_1 = L0_2
      L0_2 = Debug
      L1_2 = "Scenario or Anim Found | New Index: "
      L2_2 = L1_1
      L1_2 = L1_2 .. L2_2
      L2_2 = "warn"
      L0_2(L1_2, L2_2)
    end
    L0_2 = Coords
    L0_2 = L0_2.List
    L1_2 = L1_1
    L0_2 = L0_2[L1_2]
    L0_2 = L0_2.pedCoords
    L2_1 = L0_2
    L0_2 = Coords
    L0_2 = L0_2.List
    L1_2 = L1_1
    L0_2 = L0_2[L1_2]
    L0_2 = L0_2.camCoords
    if L0_2 then
      L0_2 = "random"
      L3_1 = L0_2
    end
  end
  L0_2 = L2_1
  return L0_2
end
SetCoords = L4_1
function L4_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L0_2 = PlayerPedId
  L0_2 = L0_2()
  L1_2 = SetTimeMultiCharacter
  L2_2 = true
  L1_2(L2_2)
  L1_2 = SetCoords
  L1_2 = L1_2()
  L2_2 = SetEntityCoordsNoOffset
  L3_2 = L0_2
  L4_2 = L1_2.x
  L5_2 = L1_2.y
  L6_2 = L1_2.z
  L7_2 = false
  L8_2 = false
  L9_2 = false
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  L2_2 = FreezeEntityPosition
  L3_2 = L0_2
  L4_2 = true
  L2_2(L3_2, L4_2)
  L2_2 = SetEntityHeading
  L3_2 = L0_2
  L4_2 = L1_2.w
  L2_2(L3_2, L4_2)
  L2_2 = RequestCollisionAtCoord
  L3_2 = L1_2.x
  L4_2 = L1_2.y
  L5_2 = L1_2.z
  L2_2(L3_2, L4_2, L5_2)
  while true do
    L2_2 = HasCollisionLoadedAroundEntity
    L3_2 = L0_2
    L2_2 = L2_2(L3_2)
    if L2_2 then
      break
    end
    L2_2 = RequestCollisionAtCoord
    L3_2 = L1_2.x
    L4_2 = L1_2.y
    L5_2 = L1_2.z
    L2_2(L3_2, L4_2, L5_2)
    L2_2 = Debug
    L3_2 = "Colission Loading"
    L2_2(L3_2)
    L2_2 = Wait
    L3_2 = 0
    L2_2(L3_2)
  end
  L2_2 = SetEntityVisible
  L3_2 = L0_2
  L4_2 = false
  L5_2 = false
  L2_2(L3_2, L4_2, L5_2)
  L2_2 = Debug
  L3_2 = "Colission is loaded!!"
  L2_2(L3_2)
  L2_2 = Debug
  L3_2 = "Func: SetPlayerAndCamera() User and camera positions are set."
  L2_2(L3_2)
  L2_2 = CreateCamera
  L3_2 = L0_2
  L2_2(L3_2)
end
SetPlayerAndCamera = L4_1
function L4_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L1_2 = GetEntityHeading
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L1_2 = L1_2 + 180.0
  L2_2 = GetOffsetFromEntityInWorldCoords
  L3_2 = A0_2
  L4_2 = 0.0
  L5_2 = 2.0
  L6_2 = 0.0
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  L3_2 = L3_1
  if "single" == L3_2 then
    L3_2 = Config
    L3_2 = L3_2.Coords
    L3_2 = L3_2.Single
    L2_2 = L3_2.camCoords
  else
    L3_2 = L3_1
    if "random" == L3_2 then
      L3_2 = Coords
      L3_2 = L3_2.List
      L4_2 = L1_1
      L3_2 = L3_2[L4_2]
      L2_2 = L3_2.camCoords
    end
  end
  L3_2 = Wait
  L4_2 = 10
  L3_2(L4_2)
  L3_2 = CreateCamWithParams
  L4_2 = "DEFAULT_SCRIPTED_CAMERA"
  L5_2 = L2_2.x
  L6_2 = L2_2.y
  L6_2 = L6_2 - 0.3
  L7_2 = L2_2.z
  L7_2 = L7_2 + 0.4
  L8_2 = 2.5
  L9_2 = 0.0
  L10_2 = L1_2
  L11_2 = 30.0
  L12_2 = false
  L13_2 = 0
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
  L0_1 = L3_2
  L3_2 = ShakeCam
  L4_2 = L0_1
  L5_2 = "HAND_SHAKE"
  L6_2 = 0.2
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = Debug
  L4_2 = "CreateCamera() Camera created."
  L3_2(L4_2)
  L3_2 = CameraDOF
  L4_2 = L0_1
  L3_2(L4_2)
end
CreateCamera = L4_1
function L4_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = SetCamUseShallowDofMode
  L2_2 = A0_2
  L3_2 = true
  L1_2(L2_2, L3_2)
  L1_2 = SetCamNearDof
  L2_2 = A0_2
  L3_2 = 1.0
  L1_2(L2_2, L3_2)
  L1_2 = SetCamFarDof
  L2_2 = A0_2
  L3_2 = 20.0
  L1_2(L2_2, L3_2)
  L1_2 = SetCamDofStrength
  L2_2 = A0_2
  L3_2 = 10.0
  L1_2(L2_2, L3_2)
  L1_2 = SetCamActive
  L2_2 = A0_2
  L3_2 = true
  L1_2(L2_2, L3_2)
  L1_2 = RenderScriptCams
  L2_2 = true
  L3_2 = false
  L4_2 = 1
  L5_2 = true
  L6_2 = true
  L1_2(L2_2, L3_2, L4_2, L5_2, L6_2)
  L1_2 = Debug
  L2_2 = "CameraDOF Set"
  L1_2(L2_2)
  L1_2 = Wait
  L2_2 = 100
  L1_2(L2_2)
  L1_2 = ShutdownLoadingScreen
  L1_2()
  L1_2 = ShutdownLoadingScreenNui
  L1_2()
  while true do
    L1_2 = GetIsLoadingScreenActive
    L1_2 = L1_2()
    if not L1_2 then
      break
    end
    L1_2 = ShutdownLoadingScreen
    L1_2()
    L1_2 = ShutdownLoadingScreenNui
    L1_2()
    L1_2 = Wait
    L2_2 = 0
    L1_2(L2_2)
  end
  L1_2 = Debug
  L2_2 = "Loading Screen OFF"
  L1_2(L2_2)
  L1_2 = TriggerEvent
  L2_2 = "um-multicharacter:client:GetCharacters"
  L1_2(L2_2)
  L1_2 = DoScreenFadeIn
  L2_2 = 500
  L1_2(L2_2)
  while true do
    L1_2 = IsScreenFadedIn
    L1_2 = L1_2()
    if L1_2 then
      break
    end
    L1_2 = Wait
    L2_2 = 0
    L1_2(L2_2)
  end
  L1_2 = ClearPeds
  L2_2 = true
  L1_2(L2_2)
  L1_2 = HideRadar
  L2_2 = true
  L1_2(L2_2)
end
CameraDOF = L4_1
function L4_1()
  local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.PerformanceMode
  if L0_2 then
    return
  end
  L0_2 = L0_1
  if not L0_2 then
    return
  end
  L0_2 = CreateThread
  function L1_2()
    local L0_3, L1_3
    while true do
      L0_3 = DoesCamExist
      L1_3 = L0_1
      L0_3 = L0_3(L1_3)
      if not L0_3 then
        break
      end
      L0_3 = SetUseHiDof
      L0_3()
      L0_3 = Wait
      L1_3 = 0
      L0_3(L1_3)
    end
  end
  L0_2(L1_2)
end
SetUseHideDofLoop = L4_1
function L4_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = SendNUIMessage
  L1_2 = {}
  L1_2.ui = false
  L2_2 = Config
  L2_2 = L2_2.BackgroundMusic
  L1_2.bgMusic = L2_2
  L0_2(L1_2)
  L0_2 = SetNui
  L1_2 = false
  L0_2(L1_2)
  L0_2 = SetTimecycleModifier
  L1_2 = "default"
  L0_2(L1_2)
  L0_2 = SetCamActive
  L1_2 = L0_1
  L2_2 = false
  L0_2(L1_2, L2_2)
  L0_2 = DestroyCam
  L1_2 = L0_1
  L2_2 = true
  L0_2(L1_2, L2_2)
  L0_2 = RenderScriptCams
  L1_2 = false
  L2_2 = false
  L3_2 = 1
  L4_2 = true
  L5_2 = true
  L0_2(L1_2, L2_2, L3_2, L4_2, L5_2)
  L0_2 = ClearPeds
  L1_2 = false
  L0_2(L1_2)
  L0_2 = SetTimeMultiCharacter
  L1_2 = false
  L0_2(L1_2)
  L0_2 = FreezeEntityPosition
  L1_2 = PlayerPedId
  L1_2 = L1_2()
  L2_2 = false
  L0_2(L1_2, L2_2)
  L0_2 = HideRadar
  L1_2 = false
  L0_2(L1_2)
  L0_2 = Animation
  L0_2 = L0_2.Stop
  L0_2()
  L0_2 = nil
  L1_2 = nil
  L2_2 = nil
  L3_2 = nil
  L3_1 = L3_2
  L2_1 = L2_2
  L1_1 = L1_2
  L0_1 = L0_2
  L0_2 = Debug
  L1_2 = "ClearAndPlay() Camera and player positions are cleared."
  L0_2(L1_2)
  L0_2 = TriggerEvent
  L1_2 = "um-clearCacheSkin"
  L0_2(L1_2)
end
ClearAndPlay = L4_1
function L4_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = L0_1
  if L0_2 then
    L0_2 = ShakeCam
    L1_2 = L0_1
    L2_2 = "DEATH_FAIL_IN_EFFECT_SHAKE"
    L3_2 = 0.5
    L0_2(L1_2, L2_2, L3_2)
  end
end
CamShake = L4_1
