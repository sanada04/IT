local L0_1, L1_1, L2_1, L3_1
IsSettingsOpen = false
L0_1 = nil
function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L0_2 = nil
  L1_2 = LoadResourceFile
  L2_2 = GetCurrentResourceName
  L2_2 = L2_2()
  L3_2 = Config
  L3_2 = L3_2.DefaultSettingsData
  L1_2 = L1_2(L2_2, L3_2)
  if L1_2 then
    L2_2 = json
    L2_2 = L2_2.decode
    L3_2 = L1_2
    L2_2 = L2_2(L3_2)
    L0_2 = L2_2
  else
    L2_2 = print
    L3_2 = "Default settings error: Could not find %s file"
    L4_2 = L3_2
    L3_2 = L3_2.format
    L5_2 = Config
    L5_2 = L5_2.DefaultSettingsData
    L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L3_2(L4_2, L5_2)
    L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  end
  L2_2 = nil
  L3_2 = nil
  if L0_2 then
    L4_2 = type
    L5_2 = L0_2
    L4_2 = L4_2(L5_2)
    if "table" == L4_2 then
      L2_2 = L0_2.layout
      L3_2 = L0_2.settings
    end
  end
  L4_2 = Config
  L4_2 = L4_2.DevDeleteAllUserSettingsOnStart
  if L4_2 then
    L4_2 = DeleteResourceKvp
    L5_2 = "%slayout"
    L6_2 = L5_2
    L5_2 = L5_2.format
    L7_2 = Config
    L7_2 = L7_2.DefaultSettingsKvpPrefix
    if not L7_2 then
      L7_2 = "hud-"
    end
    L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L5_2(L6_2, L7_2)
    L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
    L4_2 = DeleteResourceKvp
    L5_2 = "%ssettings"
    L6_2 = L5_2
    L5_2 = L5_2.format
    L7_2 = Config
    L7_2 = L7_2.DefaultSettingsKvpPrefix
    if not L7_2 then
      L7_2 = "hud-"
    end
    L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L5_2(L6_2, L7_2)
    L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  end
  L4_2 = L2_2 or L4_2
  if not L2_2 then
    L4_2 = {}
  end
  L5_2 = json
  L5_2 = L5_2.decode
  L6_2 = GetResourceKvpString
  L7_2 = "%slayout"
  L8_2 = L7_2
  L7_2 = L7_2.format
  L9_2 = Config
  L9_2 = L9_2.DefaultSettingsKvpPrefix
  if not L9_2 then
    L9_2 = "hud-"
  end
  L7_2, L8_2, L9_2, L10_2, L11_2 = L7_2(L8_2, L9_2)
  L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2, L11_2)
  if not L6_2 then
    L6_2 = "{}"
  end
  L5_2 = L5_2(L6_2)
  L6_2 = Config
  L6_2 = L6_2.AllowUsersToEditLayout
  if L6_2 then
    L6_2 = next
    L7_2 = L5_2
    L6_2 = L6_2(L7_2)
    if nil ~= L6_2 then
      L4_2 = L5_2
    end
  end
  UserLayoutData = L4_2
  L6_2 = L3_2 or L6_2
  if not L3_2 then
    L6_2 = {}
  end
  L7_2 = json
  L7_2 = L7_2.decode
  L8_2 = GetResourceKvpString
  L9_2 = "%ssettings"
  L10_2 = L9_2
  L9_2 = L9_2.format
  L11_2 = Config
  L11_2 = L11_2.DefaultSettingsKvpPrefix
  if not L11_2 then
    L11_2 = "hud-"
  end
  L9_2, L10_2, L11_2 = L9_2(L10_2, L11_2)
  L8_2 = L8_2(L9_2, L10_2, L11_2)
  if not L8_2 then
    L8_2 = "{}"
  end
  L7_2 = L7_2(L8_2)
  L8_2 = Config
  L8_2 = L8_2.AllowPlayersToEditSettings
  if L8_2 then
    L8_2 = next
    L9_2 = L7_2
    L8_2 = L8_2(L9_2)
    if nil ~= L8_2 then
      L6_2 = L7_2
    end
  end
  L8_2 = L7_2 or L8_2
  if L7_2 then
    L8_2 = L7_2.performanceMode
  end
  if L8_2 then
    L8_2 = L7_2 or L8_2
    if L7_2 then
      L8_2 = L7_2.performanceMode
    end
    L6_2.performanceMode = L8_2
    L8_2 = L7_2 or L8_2
    if L7_2 then
      L8_2 = L7_2.performanceMode
    end
    L0_1 = L8_2
  end
  UserSettingsData = L6_2
  L8_2 = L4_2
  L9_2 = L6_2
  L10_2 = L0_2
  return L8_2, L9_2, L10_2
end
GetAllHudSettings = L1_1
L1_1 = RegisterCommand
L2_1 = Config
L2_1 = L2_1.OpenSettingsCommand
if not L2_1 then
  L2_1 = "settings"
end
function L3_1()
  local L0_2, L1_2, L2_2
  L0_2 = ToggleVehicleControl
  L1_2 = false
  L0_2(L1_2)
  L0_2 = DisplayRadar
  L1_2 = false
  L0_2(L1_2)
  L0_2 = TriggerScreenblurFadeIn
  L1_2 = 500
  L0_2(L1_2)
  L0_2 = SetNuiFocus
  L1_2 = true
  L2_2 = true
  L0_2(L1_2, L2_2)
  L0_2 = SendNUIMessage
  L1_2 = {}
  L1_2.type = "showSettings"
  L0_2(L1_2)
  IsSettingsOpen = true
end
L1_1(L2_1, L3_1)
L1_1 = RegisterNUICallback
L2_1 = "close-settings"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  IsSettingsOpen = false
  L2_2 = TriggerScreenblurFadeOut
  L3_2 = 500
  L2_2(L3_2)
  L2_2 = SetNuiFocus
  L3_2 = false
  L4_2 = false
  L2_2(L3_2, L4_2)
  L2_2 = DisplayRadarConditionally
  L2_2()
  L2_2 = A1_2
  L3_2 = true
  L2_2(L3_2)
end
L1_1(L2_1, L3_1)
L1_1 = RegisterNUICallback
L2_1 = "save-hud-layout"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = IsHudRunning
  if not L2_2 then
    L2_2 = A1_2
    L3_2 = false
    return L2_2(L3_2)
  end
  if not A0_2 then
    L2_2 = A1_2
    L3_2 = false
    return L2_2(L3_2)
  end
  L2_2 = string
  L2_2 = L2_2.format
  L3_2 = "%sMinimap"
  L4_2 = UserSettingsData
  if L4_2 then
    L4_2 = L4_2.radarStyle
  end
  if not L4_2 then
    L4_2 = "rounded"
  end
  L2_2 = L2_2(L3_2, L4_2)
  L2_2 = A0_2[L2_2]
  L3_2 = SetRadarMaskAndPos
  L4_2 = UserSettingsData
  if L4_2 then
    L4_2 = L4_2.radarStyle
  end
  if not L4_2 then
    L4_2 = "rounded"
  end
  L5_2 = L2_2 or L5_2
  if L2_2 then
    L5_2 = L2_2.offset
    if L5_2 then
      L5_2 = L5_2.offsetX
    end
  end
  L6_2 = L2_2 or L6_2
  if L2_2 then
    L6_2 = L2_2.offset
    if L6_2 then
      L6_2 = L6_2.offsetY
    end
  end
  L7_2 = L2_2 or L7_2
  if L2_2 then
    L7_2 = L2_2.dimensions
    if L7_2 then
      L7_2 = L7_2.width
    end
  end
  L8_2 = L2_2 or L8_2
  if L2_2 then
    L8_2 = L2_2.dimensions
    if L8_2 then
      L8_2 = L8_2.height
    end
  end
  L9_2 = UserSettingsData
  if L9_2 then
    L9_2 = L9_2.ignoreAspectRatioLimit
  end
  L10_2 = UserSettingsData
  if L10_2 then
    L10_2 = L10_2.showNorthBlip
  end
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L7_2 = SetResourceKvp
  L8_2 = "%slayout"
  L9_2 = L8_2
  L8_2 = L8_2.format
  L10_2 = Config
  L10_2 = L10_2.DefaultSettingsKvpPrefix
  if not L10_2 then
    L10_2 = "hud-"
  end
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = json
  L9_2 = L9_2.encode
  L10_2 = A0_2
  L9_2, L10_2 = L9_2(L10_2)
  L7_2(L8_2, L9_2, L10_2)
  UserLayoutData = A0_2
  L7_2 = A1_2
  L8_2 = {}
  L9_2 = {}
  L9_2.left = L3_2
  L9_2.top = L4_2
  L9_2.width = L5_2
  L9_2.height = L6_2
  L8_2.bounds = L9_2
  L7_2(L8_2)
end
L1_1(L2_1, L3_1)
L1_1 = RegisterNUICallback
L2_1 = "save-hud-settings"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = IsHudRunning
  if not L2_2 then
    L2_2 = A1_2
    L3_2 = false
    return L2_2(L3_2)
  end
  if not A0_2 then
    L2_2 = A1_2
    L3_2 = false
    return L2_2(L3_2)
  end
  L2_2 = A0_2.radarStyle
  L3_2 = UserSettingsData
  L3_2 = L3_2.radarStyle
  if L2_2 == L3_2 then
    L2_2 = A0_2.ignoreAspectRatioLimit
    L3_2 = UserSettingsData
    L3_2 = L3_2.ignoreAspectRatioLimit
    if L2_2 == L3_2 then
      L2_2 = A0_2.showNorthBlip
      L3_2 = UserSettingsData
      L3_2 = L3_2.showNorthBlip
      if L2_2 == L3_2 then
        goto lbl_85
      end
    end
  end
  L2_2 = UserLayoutData
  L3_2 = string
  L3_2 = L3_2.format
  L4_2 = "%sMinimap"
  L5_2 = A0_2.radarStyle
  L3_2 = L3_2(L4_2, L5_2)
  L2_2 = L2_2[L3_2]
  L3_2 = SetRadarMaskAndPos
  L4_2 = A0_2.radarStyle
  if not L4_2 then
    L4_2 = "rounded"
  end
  L5_2 = L2_2 or L5_2
  if L2_2 then
    L5_2 = L2_2.offset
    if L5_2 then
      L5_2 = L5_2.offsetX
    end
  end
  L6_2 = L2_2 or L6_2
  if L2_2 then
    L6_2 = L2_2.offset
    if L6_2 then
      L6_2 = L6_2.offsetY
    end
  end
  L7_2 = L2_2 or L7_2
  if L2_2 then
    L7_2 = L2_2.dimensions
    if L7_2 then
      L7_2 = L7_2.width
    end
  end
  L8_2 = L2_2 or L8_2
  if L2_2 then
    L8_2 = L2_2.dimensions
    if L8_2 then
      L8_2 = L8_2.height
    end
  end
  L9_2 = A0_2.ignoreAspectRatioLimit
  if not L9_2 then
    L9_2 = false
  end
  L10_2 = A0_2.showNorthBlip
  if not L10_2 then
    L10_2 = false
  end
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L7_2 = A1_2
  L8_2 = {}
  L9_2 = {}
  L9_2.left = L3_2
  L9_2.top = L4_2
  L9_2.width = L5_2
  L9_2.height = L6_2
  L8_2.bounds = L9_2
  L7_2(L8_2)
  ::lbl_85::
  L2_2 = SetResourceKvp
  L3_2 = "%ssettings"
  L4_2 = L3_2
  L3_2 = L3_2.format
  L5_2 = Config
  L5_2 = L5_2.DefaultSettingsKvpPrefix
  if not L5_2 then
    L5_2 = "hud-"
  end
  L3_2 = L3_2(L4_2, L5_2)
  L4_2 = json
  L4_2 = L4_2.encode
  L5_2 = A0_2
  L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L4_2(L5_2)
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  UserSettingsData = A0_2
  L2_2 = IsHudRunning
  if L2_2 then
    L2_2 = A0_2 or L2_2
    if A0_2 then
      L2_2 = A0_2.performanceMode
    end
    L3_2 = L0_1
    if L2_2 ~= L3_2 then
      L2_2 = A0_2.performanceMode
      L0_1 = L2_2
      IsHudRunning = false
      L2_2 = Wait
      L3_2 = 100
      L2_2(L3_2)
      L2_2 = StartThreads
      L2_2()
      L2_2 = IsSettingsOpen
      if L2_2 then
        L2_2 = DisplayRadar
        L3_2 = false
        L2_2(L3_2)
      end
    end
  end
  L2_2 = A1_2
  L3_2 = false
  L2_2(L3_2)
end
L1_1(L2_1, L3_1)
