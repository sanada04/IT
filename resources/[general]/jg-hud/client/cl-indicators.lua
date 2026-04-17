local L0_1, L1_1, L2_1, L3_1, L4_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2
  if not A0_2 or 0 == A0_2 then
    L1_2 = {}
    L2_2 = false
    L3_2 = false
    L1_2[1] = L2_2
    L1_2[2] = L3_2
    return L1_2
  end
  L1_2 = Entity
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L1_2 = L1_2.state
  if L1_2 then
    L1_2 = L1_2.indicate
  end
  if not L1_2 then
    L1_2 = {}
    L2_2 = false
    L3_2 = false
    L1_2[1] = L2_2
    L1_2[2] = L3_2
  end
  return L1_2
end
GetIndicatingState = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2
  if not A0_2 or 0 == A0_2 then
    L2_2 = false
    return L2_2
  end
  L2_2 = Entity
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L2_2 = L2_2.state
  L2_2 = L2_2.indicate
  if not L2_2 then
    L2_2 = false
    return L2_2
  end
  L2_2 = Entity
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L2_2 = L2_2.state
  L2_2 = L2_2.indicate
  L3_2 = L2_2[1]
  if L3_2 then
    L3_2 = L2_2[2]
    if L3_2 and "hazards" == A1_2 then
      L3_2 = true
      return L3_2
    end
  end
  L3_2 = L2_2[1]
  if L3_2 then
    L3_2 = L2_2[2]
    if not L3_2 and "right" == A1_2 then
      L3_2 = true
      return L3_2
    end
  end
  L3_2 = L2_2[1]
  if not L3_2 then
    L3_2 = L2_2[2]
    if L3_2 and "left" == A1_2 then
      L3_2 = true
      return L3_2
    end
  end
  L3_2 = false
  return L3_2
end
IsVehicleIndicating = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = cache
  L1_2 = L1_2.vehicle
  if L1_2 then
    L1_2 = cache
    L1_2 = L1_2.seat
    if -1 == L1_2 then
      goto lbl_11
    end
  end
  L1_2 = false
  do return L1_2 end
  ::lbl_11::
  L1_2 = IsPauseMenuActive
  L1_2 = L1_2()
  if L1_2 then
    L1_2 = false
    return L1_2
  end
  L1_2 = {}
  if "left" == A0_2 then
    L2_2 = IsVehicleIndicating
    L3_2 = cache
    L3_2 = L3_2.vehicle
    L4_2 = "left"
    L2_2 = L2_2(L3_2, L4_2)
    if not L2_2 then
      L2_2 = {}
      L3_2 = false
      L4_2 = true
      L2_2[1] = L3_2
      L2_2[2] = L4_2
      L1_2 = L2_2
  end
  else
    if "right" == A0_2 then
      L2_2 = IsVehicleIndicating
      L3_2 = cache
      L3_2 = L3_2.vehicle
      L4_2 = "right"
      L2_2 = L2_2(L3_2, L4_2)
      if not L2_2 then
        L2_2 = {}
        L3_2 = true
        L4_2 = false
        L2_2[1] = L3_2
        L2_2[2] = L4_2
        L1_2 = L2_2
    end
    else
      if "hazards" == A0_2 then
        L2_2 = IsVehicleIndicating
        L3_2 = cache
        L3_2 = L3_2.vehicle
        L4_2 = "hazards"
        L2_2 = L2_2(L3_2, L4_2)
        if not L2_2 then
          L2_2 = {}
          L3_2 = true
          L4_2 = true
          L2_2[1] = L3_2
          L2_2[2] = L4_2
          L1_2 = L2_2
      end
      else
        L2_2 = {}
        L3_2 = false
        L4_2 = false
        L2_2[1] = L3_2
        L2_2[2] = L4_2
        L1_2 = L2_2
      end
    end
  end
  L2_2 = Entity
  L3_2 = cache
  L3_2 = L3_2.vehicle
  L2_2 = L2_2(L3_2)
  L2_2 = L2_2.state
  L3_2 = L2_2
  L2_2 = L2_2.set
  L4_2 = "indicate"
  L5_2 = L1_2
  L6_2 = true
  L2_2(L3_2, L4_2, L5_2, L6_2)
end
Indicate = L0_1
L0_1 = AddStateBagChangeHandler
L1_1 = "indicate"
L2_1 = ""
function L3_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L3_2 = GetEntityFromStateBagName
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  if 0 == L3_2 then
    return
  end
  L4_2 = ipairs
  L5_2 = A2_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = SetVehicleIndicatorLights
    L11_2 = L3_2
    L12_2 = L8_2 - 1
    L13_2 = L9_2
    L10_2(L11_2, L12_2, L13_2)
    L10_2 = SendNUIMessage
    L11_2 = {}
    L11_2.type = "vehicleStatusUpdate"
    L12_2 = {}
    L12_2.indicators = A2_2
    L11_2.data = L12_2
    L10_2(L11_2)
  end
end
L0_1(L1_1, L2_1, L3_1)
L0_1 = Config
L0_1 = L0_1.IndicatorLeftKeybind
if L0_1 then
  L0_1 = RegisterCommand
  L1_1 = "indicate_left"
  function L2_1()
    local L0_2, L1_2
    L0_2 = Indicate
    L1_2 = "left"
    L0_2(L1_2)
  end
  L0_1(L1_1, L2_1)
  L0_1 = RegisterKeyMapping
  L1_1 = "indicate_left"
  L2_1 = "Vehicle indicate left"
  L3_1 = "keyboard"
  L4_1 = Config
  L4_1 = L4_1.IndicatorLeftKeybind
  if not L4_1 then
    L4_1 = "LEFT"
  end
  L0_1(L1_1, L2_1, L3_1, L4_1)
end
L0_1 = Config
L0_1 = L0_1.IndicatorRightKeybind
if L0_1 then
  L0_1 = RegisterCommand
  L1_1 = "indicate_right"
  function L2_1()
    local L0_2, L1_2
    L0_2 = Indicate
    L1_2 = "right"
    L0_2(L1_2)
  end
  L0_1(L1_1, L2_1)
  L0_1 = RegisterKeyMapping
  L1_1 = "indicate_right"
  L2_1 = "Vehicle indicate right"
  L3_1 = "keyboard"
  L4_1 = Config
  L4_1 = L4_1.IndicatorRightKeybind
  if not L4_1 then
    L4_1 = "RIGHT"
  end
  L0_1(L1_1, L2_1, L3_1, L4_1)
end
L0_1 = Config
L0_1 = L0_1.IndicatorHazardsKeybind
if L0_1 then
  L0_1 = RegisterCommand
  L1_1 = "hazards"
  function L2_1()
    local L0_2, L1_2
    L0_2 = Indicate
    L1_2 = "hazards"
    L0_2(L1_2)
  end
  L0_1(L1_1, L2_1)
  L0_1 = RegisterKeyMapping
  L1_1 = "hazards"
  L2_1 = "Vehicle hazards"
  L3_1 = "keyboard"
  L4_1 = Config
  L4_1 = L4_1.IndicatorHazardsKeybind
  if not L4_1 then
    L4_1 = "UP"
  end
  L0_1(L1_1, L2_1, L3_1, L4_1)
end
