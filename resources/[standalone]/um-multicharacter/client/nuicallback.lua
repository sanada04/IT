local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
L0_1 = Framework
L1_1 = L0_1
L0_1 = L0_1.Core
L0_1(L1_1)
L0_1 = {}
L1_1 = RegisterNetEvent
L2_1 = "um-clearCacheSkin"
function L3_1()
  local L0_2, L1_2
  L0_2 = {}
  L0_1 = L0_2
  L0_2 = Debug
  L1_2 = "Skin cache cleared"
  L0_2(L1_2)
end
L1_1(L2_1, L3_1)
L1_1 = false
L2_1 = RegisterNUICallback
L3_1 = "characterGenerate"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = L1_1
  if not L2_2 then
    L2_2 = SetEntityVisible
    L3_2 = cache
    L3_2 = L3_2.ped
    L4_2 = false
    L5_2 = false
    L2_2(L3_2, L4_2, L5_2)
    L2_2 = true
    L1_1 = L2_2
  end
  if not A0_2 then
    L2_2 = warn
    L3_2 = "Citizenid is nil"
    L2_2(L3_2)
    return
  end
  L2_2 = L0_1
  L2_2 = L2_2[A0_2]
  if not L2_2 then
    L2_2 = lib
    L2_2 = L2_2.callback
    L2_2 = L2_2.await
    L3_2 = "um-multicharacter:server:getSkin"
    L4_2 = false
    L5_2 = A0_2
    L2_2, L3_2 = L2_2(L3_2, L4_2, L5_2)
    if L2_2 and L3_2 then
      L4_2 = L0_1
      L5_2 = {}
      L5_2.modelSM = L2_2
      L5_2.skinData = L3_2
      L4_2[A0_2] = L5_2
      L4_2 = Debug
      L5_2 = "Skin data loaded"
      L4_2(L5_2)
    else
      L4_2 = SetEntityVisible
      L5_2 = cache
      L5_2 = L5_2.ped
      L6_2 = false
      L7_2 = false
      L4_2(L5_2, L6_2, L7_2)
      L4_2 = warn
      L5_2 = "Failed to load skin data, check the SQL > your character skin data"
      L4_2(L5_2)
      L4_2 = A1_2
      L5_2 = 1
      return L4_2(L5_2)
    end
  end
  L2_2 = L0_1
  L2_2 = L2_2[A0_2]
  if L2_2 then
    L2_2 = L0_1
    L2_2 = L2_2[A0_2]
    L3_2 = SetModel
    L4_2 = L2_2.modelSM
    L3_2(L4_2)
    L3_2 = ClothingExports
    L4_2 = PlayerPedId
    L4_2 = L4_2()
    L5_2 = L2_2.skinData
    L3_2(L4_2, L5_2)
    L3_2 = cache
    L4_2 = L3_2
    L3_2 = L3_2.set
    L5_2 = "ped"
    L6_2 = PlayerPedId
    L6_2, L7_2 = L6_2()
    L3_2(L4_2, L5_2, L6_2, L7_2)
    L3_2 = AnimationPlay
    L3_2()
    L3_2 = SetEntityVisible
    L4_2 = cache
    L4_2 = L4_2.ped
    L5_2 = true
    L6_2 = false
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = Debug
    L4_2 = "Character generated"
    L3_2(L4_2)
  end
  L2_2 = A1_2
  L3_2 = 1
  L2_2(L3_2)
  L2_2 = Particle
  L2_2()
end
L2_1(L3_1, L4_1)
function L2_1()
  local L0_2, L1_2, L2_2
  L0_2 = SetNui
  L1_2 = false
  L0_2(L1_2)
  L0_2 = SendNUIMessage
  L1_2 = {}
  L1_2.ui = false
  L2_2 = Config
  L2_2 = L2_2.BackgroundMusic
  L1_2.bgMusic = L2_2
  L0_2(L1_2)
  while true do
    L0_2 = IsNuiFocused
    L0_2 = L0_2()
    if not L0_2 then
      break
    end
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
  end
  L0_2 = CamShake
  L0_2()
  L0_2 = DoScreenFadeOut
  L1_2 = 2000
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
end
L3_1 = RegisterNUICallback
L4_1 = "createNewCharacter"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
  L2_2 = lib
  L2_2 = L2_2.callback
  L2_2 = L2_2.await
  L3_2 = "um-multicharacter:callback:inputCheck"
  L4_2 = 2000
  L5_2 = A0_2
  L2_2 = L2_2(L3_2, L4_2, L5_2)
  if not L2_2 then
    return
  end
  L3_2 = L2_1
  L3_2()
  L3_2 = A0_2
  L4_2 = L3_2.gender
  if "male" == L4_2 then
    L3_2.gender = 0
    L4_2 = SetModel
    L5_2 = "mp_m_freemode_01"
    L4_2(L5_2)
  else
    L4_2 = L3_2.gender
    if "female" == L4_2 then
      L3_2.gender = 1
      L4_2 = SetModel
      L5_2 = "mp_f_freemode_01"
      L4_2(L5_2)
    end
  end
  L4_2 = lib
  L4_2 = L4_2.callback
  L4_2 = L4_2.await
  L5_2 = "um-multicharacter:server:createCharacter"
  L6_2 = 5000
  L7_2 = L3_2
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = ClearAndPlay
  L4_2()
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "playGame"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
  L2_2 = L2_1
  L2_2()
  L2_2 = A0_2.data
  L3_2 = lib
  L3_2 = L3_2.callback
  L3_2 = L3_2.await
  L4_2 = "um-multicharacter:server:loadUserData"
  L5_2 = 5000
  L6_2 = L2_2
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = ClearAndPlay
  L3_2()
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "photoFilter"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
  L2_2 = Debug
  L3_2 = "Filter: "
  L4_2 = A0_2
  L3_2 = L3_2 .. L4_2
  L2_2(L3_2)
  L2_2 = SetTimecycleModifier
  L3_2 = A0_2
  L2_2(L3_2)
  L2_2 = SetTimecycleModifierStrength
  L3_2 = 1.0
  L2_2(L3_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "deleteCharacter"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
  if not A0_2 then
    return
  end
  L2_2 = L2_1
  L2_2()
  L2_2 = lib
  L2_2 = L2_2.callback
  L2_2 = L2_2.await
  L3_2 = "um-multicharacter:server:deleteCharacter"
  L4_2 = 5000
  L5_2 = A0_2
  L2_2(L3_2, L4_2, L5_2)
  L2_2 = ClearAndPlay
  L2_2()
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "exit"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
  L2_2 = TriggerServerEvent
  L3_2 = "um-multicharacter:server:disconnect"
  L2_2(L3_2)
end
L3_1(L4_1, L5_1)
