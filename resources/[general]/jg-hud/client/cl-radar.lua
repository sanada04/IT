local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1
L0_1 = {}
L1_1 = {}
L2_1 = {}
L3_1 = -0.0045
L4_1 = 0.002
L5_1 = 0.15
L6_1 = 0.188888
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap = L2_1
L2_1 = {}
L3_1 = 0.0
L4_1 = -0.01
L5_1 = 0.12
L6_1 = 0.2
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap_mask = L2_1
L2_1 = {}
L3_1 = -0.0305
L4_1 = 0.04
L5_1 = 0.267
L6_1 = 0.272
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap_blur = L2_1
L0_1.square = L1_1
L1_1 = {}
L2_1 = {}
L3_1 = -0.0045
L4_1 = 0.002
L5_1 = 0.15
L6_1 = 0.188888
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap = L2_1
L2_1 = {}
L3_1 = 0.0
L4_1 = -0.01
L5_1 = 0.12
L6_1 = 0.2
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap_mask = L2_1
L2_1 = {}
L3_1 = -0.0305
L4_1 = 0.04
L5_1 = 0.267
L6_1 = 0.272
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap_blur = L2_1
L0_1.rounded = L1_1
L1_1 = {}
L2_1 = {}
L3_1 = -0.008
L4_1 = 0.005
L5_1 = 0.12
L6_1 = 0.202
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap = L2_1
L2_1 = {}
L3_1 = 0.0
L4_1 = 0.0
L5_1 = 0.111
L6_1 = 0.2
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap_mask = L2_1
L2_1 = {}
L3_1 = -0.021
L4_1 = 0.04
L5_1 = 0.192
L6_1 = 0.272
L2_1[1] = L3_1
L2_1[2] = L4_1
L2_1[3] = L5_1
L2_1[4] = L6_1
L1_1.minimap_blur = L2_1
L0_1.circular = L1_1
function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = GetNUIScreenResolution
  L0_2, L1_2 = L0_2()
  L2_2 = GetActiveScreenResolution
  L2_2, L3_2 = L2_2()
  L4_2 = L0_2 ~= L2_2 or L1_2 ~= L3_2
  return L4_2
end
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L1_2 = GetNUIScreenResolution
  L1_2, L2_2 = L1_2()
  L3_2 = 0.0
  L4_2 = -0.05
  if A0_2 then
    L5_2 = GetNUIAspectRatio
    L5_2 = L5_2()
    L6_2 = 1.7777777777777777
    if L5_2 > L6_2 then
      L7_2 = L6_2 - L5_2
      L3_2 = L7_2 / 3.6
    end
  end
  L5_2 = 1400
  if L2_2 < L5_2 then
    L4_2 = -0.06
  end
  L5_2 = 1240
  if L2_2 < L5_2 then
    L4_2 = -0.07
  end
  L5_2 = 1050
  if L2_2 < L5_2 then
    L4_2 = -0.09
  end
  L5_2 = 950
  if L2_2 < L5_2 then
    L4_2 = -0.09
  end
  L5_2 = 850
  if L2_2 < L5_2 then
    L4_2 = -0.1
  end
  L5_2 = 750
  if L2_2 < L5_2 then
    L4_2 = -0.11
  end
  L5_2 = 650
  if L2_2 < L5_2 then
    L4_2 = -0.14
  end
  L5_2 = L3_2
  L6_2 = L4_2
  return L5_2, L6_2
end
function L3_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2, A7_2)
  local L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L8_2 = 1.0
  L9_2 = L2_1
  L10_2 = A7_2
  L9_2, L10_2 = L9_2(L10_2)
  L11_2 = GetNUIScreenResolution
  L11_2, L12_2 = L11_2()
  L13_2 = GetNUIAspectRatio
  L13_2 = L13_2()
  L14_2 = 1.7777777777777777
  if A6_2 then
    L8_2 = A6_2 / A2_2
  end
  if A3_2 then
    L15_2 = A3_2 / L11_2
    L16_2 = L13_2 / L14_2
    L15_2 = L15_2 * L16_2
    L9_2 = L9_2 + L15_2
  end
  if A4_2 then
    L15_2 = A6_2 or L15_2
    if not A6_2 then
      L15_2 = A2_2
    end
    L15_2 = L15_2 - A2_2
    L15_2 = A4_2 + L15_2
    L15_2 = L15_2 / L12_2
    L10_2 = L10_2 + L15_2
  end
  L15_2 = L9_2
  L16_2 = L10_2
  L17_2 = L8_2
  return L15_2, L16_2, L17_2
end
function L4_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
  L1_2 = L2_1
  L2_2 = A0_2
  L1_2, L2_2 = L1_2(L2_2)
  L3_2 = GetSafeZoneSize
  L3_2 = L3_2()
  L4_2 = SetScriptGfxAlign
  L5_2 = string
  L5_2 = L5_2.byte
  L6_2 = "L"
  L5_2 = L5_2(L6_2)
  L6_2 = string
  L6_2 = L6_2.byte
  L7_2 = "B"
  L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2 = L6_2(L7_2)
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2)
  L4_2 = GetNUIAspectRatio
  L4_2 = L4_2()
  L5_2 = 1.7777777777777777
  L6_2 = GetScriptGfxPosition
  L7_2 = 0.0
  L8_2 = -0.186888
  L6_2, L7_2 = L6_2(L7_2, L8_2)
  L8_2 = GetScriptGfxPosition
  L9_2 = L4_2 / L5_2
  L9_2 = L1_2 / L9_2
  L9_2 = 0.0 + L9_2
  L10_2 = -0.186888 + L2_2
  L8_2, L9_2 = L8_2(L9_2, L10_2)
  L10_2 = ResetScriptGfxAlign
  L10_2()
  L10_2 = GetActiveScreenResolution
  L10_2, L11_2 = L10_2()
  L12_2 = GetNUIScreenResolution
  L12_2, L13_2 = L12_2()
  if L4_2 > 2 then
    L4_2 = 1.7777777777777777
  end
  L14_2 = L12_2 * L8_2
  L15_2 = L13_2 * L9_2
  L16_2 = L1_1
  L16_2 = L16_2()
  if L16_2 then
    L16_2 = 1920 * L11_2
    L16_2 = L16_2 / 1080
    L16_2 = L10_2 - L16_2
    L16_2 = L16_2 / 2
    L14_2 = L14_2 + L16_2
    L16_2 = L13_2 / L11_2
    L12_2 = L10_2 * L16_2
  end
  L16_2 = 1.0
  L16_2 = L16_2 / L12_2
  L17_2 = 4 * L4_2
  L17_2 = L12_2 / L17_2
  L16_2 = L16_2 * L17_2
  if L4_2 > 2 then
    L17_2 = 0.76
    if L17_2 then
      goto lbl_85
    end
  end
  L17_2 = 1.8
  if L4_2 > L17_2 then
    L17_2 = 0.995
    if L17_2 then
      goto lbl_85
    end
  end
  L17_2 = 1
  ::lbl_85::
  L16_2 = L16_2 * L17_2
  L17_2 = 1
  L17_2 = L17_2 / L3_2
  L17_2 = L12_2 * L17_2
  L18_2 = L12_2 * L6_2
  L18_2 = L18_2 * 2
  L17_2 = L17_2 - L18_2
  L16_2 = L16_2 * L17_2
  L17_2 = L13_2 / 5.5
  L18_2 = L14_2
  L19_2 = L15_2
  L20_2 = L16_2
  L21_2 = L17_2
  return L18_2, L19_2, L20_2, L21_2
end
function L5_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2)
  local L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2
  L7_2 = L4_1
  L8_2 = A5_2
  L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
  L11_2 = lib
  L11_2 = L11_2.requestStreamedTextureDict
  L12_2 = "jgradar"
  L11_2(L12_2)
  if "circular" == A0_2 then
    L11_2 = "radarmasksm-circular"
    if L11_2 then
      goto lbl_19
    end
  end
  if "square" == A0_2 then
    L11_2 = "radarmasksm-square"
    if L11_2 then
      goto lbl_19
    end
  end
  L11_2 = "radarmasksm-rounded"
  ::lbl_19::
  L12_2 = AddReplaceTexture
  L13_2 = "platform:/textures/graphics"
  L14_2 = "radarmasksm"
  L15_2 = "jgradar"
  L16_2 = L11_2
  L12_2(L13_2, L14_2, L15_2, L16_2)
  L12_2 = AddReplaceTexture
  L13_2 = "platform:/textures/graphics"
  L14_2 = "radarmask1g"
  L15_2 = "jgradar"
  L16_2 = L11_2
  L12_2(L13_2, L14_2, L15_2, L16_2)
  L12_2 = SetStreamedTextureDictAsNoLongerNeeded
  L13_2 = "jgradar"
  L12_2(L13_2)
  L12_2 = L1_1
  L12_2 = L12_2()
  if L12_2 then
    L12_2 = GetSafeZoneSize
    L12_2 = L12_2()
    L13_2 = 1
    L12_2 = L13_2 - L12_2
    L12_2 = 1920 * L12_2
    L7_2 = L12_2 / 2
  end
  L12_2 = L3_1
  L13_2 = L7_2
  L14_2 = L8_2
  L15_2 = L10_2
  L16_2 = A1_2
  L17_2 = A2_2
  L18_2 = A3_2
  L19_2 = A4_2
  L20_2 = A5_2
  L12_2, L13_2, L14_2 = L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2)
  L15_2 = pairs
  L16_2 = L0_1
  L16_2 = L16_2[A0_2]
  L15_2, L16_2, L17_2, L18_2 = L15_2(L16_2)
  for L19_2, L20_2 in L15_2, L16_2, L17_2, L18_2 do
    L21_2 = SetMinimapComponentPosition
    L22_2 = L19_2
    L23_2 = "L"
    L24_2 = "B"
    L25_2 = L20_2[1]
    L25_2 = L25_2 * L14_2
    L25_2 = L25_2 + L12_2
    L26_2 = L20_2[2]
    L26_2 = L26_2 * L14_2
    L26_2 = L26_2 + L13_2
    L27_2 = L20_2[3]
    L27_2 = L27_2 * L14_2
    L28_2 = L20_2[4]
    L28_2 = L28_2 * L14_2
    L21_2(L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2)
  end
  L15_2 = SetBlipAlpha
  L16_2 = GetNorthRadarBlip
  L16_2 = L16_2()
  if A6_2 then
    L17_2 = 255
    if L17_2 then
      goto lbl_95
    end
  end
  L17_2 = 0
  ::lbl_95::
  L15_2(L16_2, L17_2)
  L15_2 = SetMinimapClipType
  if "circular" == A0_2 then
    L16_2 = 1
    if L16_2 then
      goto lbl_103
    end
  end
  L16_2 = 0
  ::lbl_103::
  L15_2(L16_2)
  L15_2 = SetBigmapActive
  L16_2 = true
  L17_2 = false
  L15_2(L16_2, L17_2)
  L15_2 = Wait
  L16_2 = 1
  L15_2(L16_2)
  L15_2 = SetBigmapActive
  L16_2 = false
  L17_2 = false
  L15_2(L16_2, L17_2)
  L15_2 = L7_2
  L16_2 = L8_2
  L17_2 = L9_2
  L18_2 = L10_2
  return L15_2, L16_2, L17_2, L18_2
end
SetRadarMaskAndPos = L5_1
L5_1 = false
function L6_1()
  local L0_2, L1_2
  L0_2 = L5_1
  if L0_2 then
    return
  end
  L0_2 = true
  L5_1 = L0_2
  L0_2 = CreateThread
  function L1_2()
    local L0_3, L1_3
    while true do
      L0_3 = IsHudRunning
      if not L0_3 then
        break
      end
      L0_3 = DisplayRadarConditionally
      L0_3()
      L0_3 = Wait
      L1_3 = 2000
      L0_3(L1_3)
    end
    L0_3 = false
    L5_1 = L0_3
  end
  L0_2(L1_2)
end
CreateRadarThread = L6_1
L6_1 = HideHudComponentThisFrame
L7_1 = false
function L8_1()
  local L0_2, L1_2
  L0_2 = Config
  if L0_2 then
    L0_2 = L0_2.HideBaseGameHudComponents
  end
  if not L0_2 then
    return
  end
  L0_2 = L7_1
  if L0_2 then
    return
  end
  L0_2 = true
  L7_1 = L0_2
  L0_2 = CreateThread
  function L1_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3
    while true do
      L0_3 = IsHudRunning
      if not L0_3 then
        break
      end
      L0_3 = ipairs
      L1_3 = Config
      if L1_3 then
        L1_3 = L1_3.HideBaseGameHudComponents
      end
      if not L1_3 then
        L1_3 = {}
      end
      L0_3, L1_3, L2_3, L3_3 = L0_3(L1_3)
      for L4_3, L5_3 in L0_3, L1_3, L2_3, L3_3 do
        L6_3 = L6_1
        L7_3 = L5_3
        L6_3(L7_3)
      end
      L0_3 = Wait
      L1_3 = 1
      L0_3(L1_3)
    end
    L0_3 = false
    L7_1 = L0_3
  end
  L0_2(L1_2)
end
CreateHideHudComponentsThread = L8_1
