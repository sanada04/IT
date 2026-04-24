local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1
L0_1 = Framework
L1_1 = L0_1
L0_1 = L0_1.Core
L0_1(L1_1)
L0_1 = false
L1_1 = {}
L2_1 = Config
if L2_1 then
  L2_1 = L2_1.Pages
end
L1_1.pages = L2_1
L2_1 = Config
if L2_1 then
  L2_1 = L2_1.Speech
end
L1_1.speech = L2_1
L2_1 = Config
if L2_1 then
  L2_1 = L2_1.BackgroundMusic
end
L1_1.bgMusic = L2_1
L2_1 = Config
if L2_1 then
  L2_1 = L2_1.CinematicMode
end
L1_1.cinematicMode = L2_1
L2_1 = Config
L2_1 = L2_1.DeleteButton
L1_1.deleteButtonStatus = L2_1
L2_1 = require
L3_1 = "locales."
L4_1 = Config
L4_1 = L4_1.Lang
L3_1 = L3_1 .. L4_1
L2_1 = L2_1(L3_1)
L1_1.lang = L2_1
L2_1 = CreateThread
function L3_1()
  local L0_2, L1_2, L2_2
  while true do
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
    L0_2 = NetworkIsSessionStarted
    L0_2 = L0_2()
    if L0_2 then
      L0_2 = L0_1
      if L0_2 then
        L0_2 = Wait
        L1_2 = 300
        L0_2(L1_2)
        L0_2 = pcall
        function L1_2()
          local L0_3, L1_3, L2_3
          L0_3 = exports
          L0_3 = L0_3.spawnmanager
          L1_3 = L0_3
          L0_3 = L0_3.setAutoSpawn
          L2_3 = false
          L0_3(L1_3, L2_3)
        end
        L0_2(L1_2)
        L0_2 = Debug
        L1_2 = "Network Player Active | Auto Spawn False |"
        L2_2 = PlayerId
        L2_2 = L2_2()
        L1_2 = L1_2 .. L2_2
        L0_2(L1_2)
        L0_2 = TriggerEvent
        L1_2 = "qb-multicharacter:client:chooseChar"
        L0_2(L1_2)
        break
      end
    end
  end
end
L2_1(L3_1)
L2_1 = RegisterNUICallback
L3_1 = "jsReady"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = true
  L0_1 = L2_2
  L2_2 = Debug
  L3_2 = "JS Ready"
  L2_2(L3_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNetEvent
L3_1 = "qb-multicharacter:client:chooseChar"
function L4_1()
  local L0_2, L1_2
  L0_2 = UMShutDownNui
  L0_2()
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNetEvent
L3_1 = "um-multicharacter:client:GetCharacters"
function L4_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = SetNui
  L1_2 = false
  L0_2(L1_2)
  L0_2 = SetFollowPedCamViewMode
  L1_2 = 2
  L0_2(L1_2)
  L0_2 = lib
  L0_2 = L0_2.callback
  L0_2 = L0_2.await
  L1_2 = "um-multicharacter:server:GetCharacters"
  L2_2 = 5000
  L0_2, L1_2 = L0_2(L1_2, L2_2)
  if L0_2 then
    L2_2 = lib
    L2_2 = L2_2.callback
    L2_2 = L2_2.await
    L3_2 = "um-multicharacter:callback:CustomDeleteCharacterAccess"
    L2_2 = L2_2(L3_2)
    L3_2 = SendNUIMessage
    L4_2 = {}
    L4_2.ui = true
    L4_2.myCharacters = L0_2
    L5_2 = L1_1.lang
    L4_2.Lang = L5_2
    L4_2.totalSlots = L1_2
    L5_2 = L2_2 or L5_2
    if not L2_2 then
      L5_2 = L1_1
      if L5_2 then
        L5_2 = L5_2.deleteButtonStatus
      end
    end
    L4_2.deleteButtonStatus = L5_2
    L5_2 = L1_1.pages
    L4_2.pagesList = L5_2
    L5_2 = L1_1.speech
    L4_2.speechList = L5_2
    L5_2 = L1_1.bgMusic
    L4_2.bgMusic = L5_2
    L5_2 = L1_1.cinematicMode
    L4_2.cinematicMode = L5_2
    L3_2(L4_2)
    L3_2 = Debug
    L4_2 = "Characters Received"
    L3_2(L4_2)
    L3_2 = Debug
    L4_2 = "Total Number of Slots:"
    L5_2 = L1_2
    L4_2 = L4_2 .. L5_2
    L3_2(L4_2)
    L3_2 = SetNui
    L4_2 = true
    L3_2(L4_2)
  else
    L2_2 = SendNUIMessage
    L3_2 = {}
    L3_2.ui = true
    L4_2 = L1_1.lang
    L3_2.Lang = L4_2
    L3_2.totalSlots = L1_2
    L4_2 = L1_1.pages
    L3_2.pagesList = L4_2
    L4_2 = L1_1.bgMusic
    L3_2.bgMusic = L4_2
    L4_2 = L1_1.cinematicMode
    L3_2.cinematicMode = L4_2
    L2_2(L3_2)
    L2_2 = Debug
    L3_2 = "Character Not Found | New Character Screen Introduced"
    L4_2 = "warn"
    L2_2(L3_2, L4_2)
    L2_2 = Debug
    L3_2 = "Character Not Found | Number of Slots:"
    L4_2 = L1_2
    L3_2 = L3_2 .. L4_2
    L4_2 = "warn"
    L2_2(L3_2, L4_2)
    L2_2 = SetNui
    L3_2 = true
    L2_2(L3_2)
  end
  L2_2 = SetUseHideDofLoop
  L2_2()
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNetEvent
L3_1 = "um-multicharacter:client:defaultSpawn"
function L4_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = GetInvokingResource
  L0_2 = L0_2()
  if L0_2 then
    return
  end
  L0_2 = SetNui
  L1_2 = false
  L0_2(L1_2)
  L0_2 = DoScreenFadeOut
  L1_2 = 500
  L0_2(L1_2)
  L0_2 = Wait
  L1_2 = 2000
  L0_2(L1_2)
  L0_2 = Config
  L0_2 = L0_2.NewPlayerNoApartmentStartCoords
  L1_2 = SetEntityCoords
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = L0_2.x
  L4_2 = L0_2.y
  L5_2 = L0_2.z
  L1_2(L2_2, L3_2, L4_2, L5_2)
  L1_2 = SetEntityHeading
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = L0_2.w
  L1_2(L2_2, L3_2)
  L1_2 = TriggerServerEvent
  L2_2 = Framework
  L2_2 = L2_2.Events
  L2_2 = L2_2.loadedS
  L1_2(L2_2)
  L1_2 = TriggerEvent
  L2_2 = Framework
  L2_2 = L2_2.Events
  L2_2 = L2_2.loadedC
  L1_2(L2_2)
  L1_2 = TriggerServerEvent
  L2_2 = Framework
  L2_2 = L2_2.Events
  L2_2 = L2_2.houseS
  L3_2 = 0
  L4_2 = false
  L1_2(L2_2, L3_2, L4_2)
  L1_2 = TriggerServerEvent
  L2_2 = Framework
  L2_2 = L2_2.Events
  L2_2 = L2_2.apartS
  L3_2 = 0
  L4_2 = 0
  L5_2 = false
  L1_2(L2_2, L3_2, L4_2, L5_2)
  L1_2 = Wait
  L2_2 = 500
  L1_2(L2_2)
  L1_2 = SetEntityVisible
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = true
  L1_2(L2_2, L3_2)
  L1_2 = Wait
  L2_2 = 500
  L1_2(L2_2)
  L1_2 = DoScreenFadeIn
  L2_2 = 500
  L1_2(L2_2)
  L1_2 = TriggerEvent
  L2_2 = "qb-weathersync:client:EnableSync"
  L1_2(L2_2)
  L1_2 = TriggerEvent
  L2_2 = Config
  L2_2 = L2_2.NewPlayerNoApartmentStartClothingUI
  L1_2(L2_2)
end
L2_1(L3_1, L4_1)
function L2_1()
  local L0_2, L1_2, L2_2
  L0_2 = SetTimeout
  L1_2 = 1000
  function L2_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3
    L0_3 = "anim@scripted@heist@ig25_beach@male@"
    L1_3 = lib
    L1_3 = L1_3.requestAnimDict
    L2_3 = L0_3
    L1_3(L2_3)
    L1_3 = GetEntityCoords
    L2_3 = cache
    L2_3 = L2_3.ped
    L1_3 = L1_3(L2_3)
    L2_3 = GetEntityHeading
    L3_3 = cache
    L3_3 = L3_3.ped
    L2_3 = L2_3(L3_3)
    L3_3 = vector4
    L4_3 = L1_3.x
    L5_3 = L1_3.y
    L6_3 = L1_3.z
    L6_3 = L6_3 - 1
    L7_3 = L2_3
    L3_3 = L3_3(L4_3, L5_3, L6_3, L7_3)
    L4_3 = NetworkCreateSynchronisedScene
    L5_3 = L3_3.x
    L6_3 = L3_3.y
    L7_3 = L3_3.z
    L8_3 = 0.0
    L9_3 = 0.0
    L10_3 = L3_3.w
    L11_3 = 2
    L12_3 = false
    L13_3 = false
    L14_3 = 8.0
    L15_3 = 1000.0
    L16_3 = 1.0
    L4_3 = L4_3(L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3)
    L5_3 = NetworkAddPedToSynchronisedScene
    L6_3 = cache
    L6_3 = L6_3.ped
    L7_3 = L4_3
    L8_3 = L0_3
    L9_3 = "action"
    L10_3 = 1000.0
    L11_3 = 8.0
    L12_3 = 0
    L13_3 = 0
    L14_3 = 1000.0
    L15_3 = 8192
    L5_3(L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
    L5_3 = CreateCam
    L6_3 = "DEFAULT_ANIMATED_CAMERA"
    L7_3 = true
    L5_3 = L5_3(L6_3, L7_3)
    L6_3 = PlayCamAnim
    L7_3 = L5_3
    L8_3 = "action_camera"
    L9_3 = L0_3
    L10_3 = L3_3.x
    L11_3 = L3_3.y
    L12_3 = L3_3.z
    L13_3 = 0.0
    L14_3 = 0.0
    L15_3 = L3_3.w
    L16_3 = false
    L17_3 = 2
    L6_3(L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
    L6_3 = RenderScriptCams
    L7_3 = true
    L8_3 = false
    L9_3 = 0
    L10_3 = true
    L11_3 = false
    L6_3(L7_3, L8_3, L9_3, L10_3, L11_3)
    L6_3 = NetworkStartSynchronisedScene
    L7_3 = L4_3
    L6_3(L7_3)
    L6_3 = NetworkGetLocalSceneFromNetworkId
    L7_3 = L4_3
    L6_3 = L6_3(L7_3)
    while -1 == L6_3 do
      L7_3 = Wait
      L8_3 = 0
      L7_3(L8_3)
      L7_3 = NetworkGetLocalSceneFromNetworkId
      L8_3 = L4_3
      L7_3 = L7_3(L8_3)
      L6_3 = L7_3
    end
    repeat
      L7_3 = Wait
      L8_3 = 0
      L7_3(L8_3)
      L7_3 = GetSynchronizedScenePhase
      L8_3 = L6_3
      L7_3 = L7_3(L8_3)
      L8_3 = 0.85
    until L7_3 > L8_3
    L7_3 = StopRenderingScriptCamsUsingCatchUp
    L8_3 = false
    L9_3 = 4.0
    L10_3 = 3
    L7_3(L8_3, L9_3, L10_3)
    L7_3 = DestroyCam
    L8_3 = L5_3
    L9_3 = false
    L7_3(L8_3, L9_3)
    L7_3 = FreezeEntityPosition
    L8_3 = cache
    L8_3 = L8_3.ped
    L9_3 = false
    L7_3(L8_3, L9_3)
    L7_3 = RemoveAnimDict
    L8_3 = L0_3
    L7_3(L8_3)
  end
  L0_2(L1_2, L2_2)
end
function L3_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = FreezeEntityPosition
  L1_2 = cache
  L1_2 = L1_2.ped
  L2_2 = true
  L0_2(L1_2, L2_2)
  L0_2 = DoScreenFadeOut
  L1_2 = 0
  L0_2(L1_2)
  L0_2 = TriggerScreenblurFadeIn
  L1_2 = 10
  L0_2(L1_2)
  L0_2 = IsPlayerSwitchInProgress
  L0_2 = L0_2()
  if not L0_2 then
    L0_2 = SwitchOutPlayer
    L1_2 = cache
    L1_2 = L1_2.ped
    L2_2 = 0
    L3_2 = 1
    L0_2(L1_2, L2_2, L3_2)
  end
  while true do
    L0_2 = GetPlayerSwitchState
    L0_2 = L0_2()
    if 5 == L0_2 then
      break
    end
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
  end
  L0_2 = DoScreenFadeIn
  L1_2 = 1000
  L0_2(L1_2)
  while true do
    L0_2 = IsScreenFadedIn
    L0_2 = L0_2()
    if L0_2 then
      break
    end
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
  end
  L0_2 = L2_1
  L0_2()
  L0_2 = SwitchInPlayer
  L1_2 = cache
  L1_2 = L1_2.ped
  L0_2(L1_2)
  while true do
    L0_2 = GetPlayerSwitchState
    L0_2 = L0_2()
    if 12 == L0_2 then
      break
    end
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
  end
  L0_2 = TriggerScreenblurFadeOut
  L1_2 = 100
  L0_2(L1_2)
  L0_2 = FreezeEntityPosition
  L1_2 = cache
  L1_2 = L1_2.ped
  L2_2 = false
  L0_2(L1_2, L2_2)
end
L4_1 = RegisterNetEvent
L5_1 = "um-multicharacter:client:spawnLastCoords"
function L6_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = GetInvokingResource
  L1_2 = L1_2()
  if L1_2 then
    return
  end
  L1_2 = SetNui
  L2_2 = false
  L1_2(L2_2)
  L1_2 = Wait
  L2_2 = 1000
  L1_2(L2_2)
  L1_2 = GetResourceState
  L2_2 = "ps-housing"
  L1_2 = L1_2(L2_2)
  if "started" == L1_2 then
    L1_2 = lib
    L1_2 = L1_2.callback
    L1_2 = L1_2.await
    L2_2 = "ps-housing:cb:GetOwnedApartment"
    L3_2 = source
    L4_2 = A0_2
    if L4_2 then
      L4_2 = L4_2.citizenid
    end
    L1_2 = L1_2(L2_2, L3_2, L4_2)
    if L1_2 then
      L2_2 = TriggerEvent
      L3_2 = "apartments:client:SetHomeBlip"
      L4_2 = L1_2
      if L4_2 then
        L4_2 = L4_2.type
      end
      L2_2(L3_2, L4_2)
    end
  end
  L1_2 = Framework
  L2_2 = L1_2
  L1_2 = L1_2.GetPlayerData
  L1_2 = L1_2(L2_2)
  L2_2 = L1_2
  if L2_2 then
    L2_2 = L2_2.metadata
  end
  L2_2 = L2_2.inside
  L3_2 = SetEntityCoords
  L4_2 = PlayerPedId
  L4_2 = L4_2()
  L5_2 = A0_2.x
  L6_2 = A0_2.y
  L7_2 = A0_2.z
  L7_2 = L7_2 - 1
  L3_2(L4_2, L5_2, L6_2, L7_2)
  L3_2 = SetEntityHeading
  L4_2 = PlayerPedId
  L4_2 = L4_2()
  L5_2 = A0_2
  if L5_2 then
    L5_2 = L5_2.w
  end
  if not L5_2 then
    L5_2 = 0.0
  end
  L3_2(L4_2, L5_2)
  L3_2 = L2_2
  if L3_2 then
    L3_2 = L3_2.house
  end
  if nil ~= L3_2 then
    L3_2 = L2_2.house
    L4_2 = TriggerEvent
    L5_2 = Framework
    L5_2 = L5_2.Events
    L5_2 = L5_2.house
    L6_2 = L3_2
    L4_2(L5_2, L6_2)
  else
    L3_2 = L2_2
    if L3_2 then
      L3_2 = L3_2.apartment
    end
    L3_2 = L3_2.apartmentType
    if nil == L3_2 then
      L3_2 = L2_2.apartment
      L3_2 = L3_2.apartmentId
      if nil == L3_2 then
        goto lbl_101
      end
    end
    L3_2 = L2_2.apartment
    L3_2 = L3_2.apartmentType
    L4_2 = L2_2.apartment
    L4_2 = L4_2.apartmentId
    L5_2 = TriggerEvent
    L6_2 = Framework
    L6_2 = L6_2.Events
    L6_2 = L6_2.apart
    L7_2 = L3_2
    L8_2 = L4_2
    L5_2(L6_2, L7_2, L8_2)
    goto lbl_119
    ::lbl_101::
    L3_2 = L2_2
    if L3_2 then
      L3_2 = L3_2.propertyId
    end
    if not L3_2 then
      L3_2 = L2_2
      if L3_2 then
        L3_2 = L3_2.property_id
      end
      if not L3_2 then
        goto lbl_119
      end
    end
    L3_2 = TriggerServerEvent
    L4_2 = "ps-housing:server:enterProperty"
    L5_2 = tostring
    L6_2 = L2_2.propertyId
    L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
    L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
  end
  ::lbl_119::
  L3_2 = TriggerServerEvent
  L4_2 = Framework
  L4_2 = L4_2.Events
  L4_2 = L4_2.loadedS
  L3_2(L4_2)
  L3_2 = TriggerEvent
  L4_2 = Framework
  L4_2 = L4_2.Events
  L4_2 = L4_2.loadedC
  L3_2(L4_2)
  L3_2 = RequestCollisionAtCoord
  L4_2 = A0_2.x
  L5_2 = A0_2.y
  L6_2 = A0_2.z
  L3_2(L4_2, L5_2, L6_2)
  while true do
    L3_2 = HasCollisionLoadedAroundEntity
    L4_2 = PlayerPedId
    L4_2, L5_2, L6_2, L7_2, L8_2 = L4_2()
    L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
    if L3_2 then
      break
    end
    L3_2 = RequestCollisionAtCoord
    L4_2 = A0_2.x
    L5_2 = A0_2.y
    L6_2 = A0_2.z
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = Debug
    L4_2 = "Colission Loading Last Location"
    L3_2(L4_2)
    L3_2 = Wait
    L4_2 = 0
    L3_2(L4_2)
  end
  L3_2 = Wait
  L4_2 = 500
  L3_2(L4_2)
  L3_2 = Config
  L3_2 = L3_2.NoSpawnMenuOnlyLastLocation
  L3_2 = L3_2.gtaVNativeAndCutScene
  if L3_2 then
    L3_2 = L3_1
    L3_2()
    return
  end
  L3_2 = DoScreenFadeIn
  L4_2 = 1000
  L3_2(L4_2)
end
L4_1(L5_1, L6_1)
L4_1 = RegisterNetEvent
L5_1 = "um-multicharacter:client:logout"
function L6_1()
  local L0_2, L1_2
  L0_2 = GetInvokingResource
  L0_2 = L0_2()
  if L0_2 then
    return
  end
  L0_2 = TriggerEvent
  L1_2 = "um-clearCacheSkin"
  L0_2(L1_2)
  L0_2 = TriggerEvent
  L1_2 = "qb-multicharacter:client:chooseChar"
  L0_2(L1_2)
end
L4_1(L5_1, L6_1)
