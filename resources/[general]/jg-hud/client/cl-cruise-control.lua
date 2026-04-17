local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1
IsCruiseControlEnabled = false
L0_1 = 0.0
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  if not A1_2 then
    A1_2 = 0.01
  end
  L2_2 = GetEntityForwardVector
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L3_2 = GetEntityVelocity
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L4_2 = math
  L4_2 = L4_2.sqrt
  L5_2 = L3_2.x
  L5_2 = L5_2 ^ 2
  L6_2 = L3_2.y
  L6_2 = L6_2 ^ 2
  L5_2 = L5_2 + L6_2
  L6_2 = L3_2.z
  L6_2 = L6_2 ^ 2
  L5_2 = L5_2 + L6_2
  L4_2 = L4_2(L5_2)
  if L4_2 < 1.0 then
    L5_2 = false
    L6_2 = 0.0
    return L5_2, L6_2
  end
  L5_2 = {}
  L6_2 = L3_2.x
  L6_2 = L6_2 / L4_2
  L5_2.x = L6_2
  L6_2 = L3_2.y
  L6_2 = L6_2 / L4_2
  L5_2.y = L6_2
  L6_2 = L3_2.z
  L6_2 = L6_2 / L4_2
  L5_2.z = L6_2
  L6_2 = L2_2.x
  L7_2 = L5_2.x
  L6_2 = L6_2 * L7_2
  L7_2 = L2_2.y
  L8_2 = L5_2.y
  L7_2 = L7_2 * L8_2
  L6_2 = L6_2 + L7_2
  L7_2 = L2_2.z
  L8_2 = L5_2.z
  L7_2 = L7_2 * L8_2
  L6_2 = L6_2 + L7_2
  L7_2 = math
  L7_2 = L7_2.acos
  L8_2 = math
  L8_2 = L8_2.max
  L9_2 = -1
  L10_2 = math
  L10_2 = L10_2.min
  L11_2 = 1
  L12_2 = L6_2
  L10_2, L11_2, L12_2 = L10_2(L11_2, L12_2)
  L8_2, L9_2, L10_2, L11_2, L12_2 = L8_2(L9_2, L10_2, L11_2, L12_2)
  L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
  L8_2 = math
  L8_2 = L8_2.deg
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L9_2 = A1_2 * 180
  L9_2 = L8_2 > L9_2
  L10_2 = L9_2
  L11_2 = L8_2
  return L10_2, L11_2
end
function L2_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = IsControlPressed
  L2_2 = 2
  L3_2 = 76
  L1_2 = L1_2(L2_2, L3_2)
  if not L1_2 then
    L1_2 = IsControlPressed
    L2_2 = 2
    L3_2 = 63
    L1_2 = L1_2(L2_2, L3_2)
    if not L1_2 then
      L1_2 = IsControlPressed
      L2_2 = 2
      L3_2 = 64
      L1_2 = L1_2(L2_2, L3_2)
    end
  end
  return L1_2
end
function L3_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = Config
  L2_2 = L2_2.EnableCruiseControl
  if not L2_2 then
    return
  end
  L2_2 = IsCruiseControlEnabled
  if L2_2 then
    IsCruiseControlEnabled = false
    return
  end
  if not A0_2 and -1 ~= A1_2 then
    return
  end
  L2_2 = GetVehicleType
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if "land" ~= L2_2 then
    return
  end
  L2_2 = GetEntitySpeed
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if L2_2 < 1.0 then
    return
  end
  L2_2 = GetIsVehicleEngineRunning
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if not L2_2 then
    return
  end
  L2_2 = L1_1
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if L2_2 then
    return
  end
  L2_2 = L2_1
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if L2_2 then
    return
  end
  IsCruiseControlEnabled = true
  L2_2 = GetEntitySpeed
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L0_1 = L2_2
  L2_2 = CreateThread
  function L3_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
    while true do
      L0_3 = cache
      L0_3 = L0_3.vehicle
      if not L0_3 then
        break
      end
      L0_3 = IsCruiseControlEnabled
      if not L0_3 then
        break
      end
      L0_3 = IsHudRunning
      if not L0_3 then
        break
      end
      L0_3 = GetIsVehicleEngineRunning
      L1_3 = A0_2
      L0_3 = L0_3(L1_3)
      L1_3 = GetEntitySpeed
      L2_3 = cache
      L2_3 = L2_3.vehicle
      L1_3 = L1_3(L2_3)
      L2_3 = IsControlPressed
      L3_3 = 2
      L4_3 = 76
      L2_3 = L2_3(L3_3, L4_3)
      if not L2_3 then
        L2_3 = IsControlPressed
        L3_3 = 2
        L4_3 = 63
        L2_3 = L2_3(L3_3, L4_3)
        if not L2_3 then
          L2_3 = IsControlPressed
          L3_3 = 2
          L4_3 = 64
          L2_3 = L2_3(L3_3, L4_3)
        end
      end
      if L0_3 then
        if L2_3 then
          goto lbl_48
        end
        L3_3 = L0_1
        L3_3 = L3_3 - 1.5
        if not (L1_3 < L3_3) then
          goto lbl_48
        end
      end
      IsCruiseControlEnabled = false
      L3_3 = Wait
      L4_3 = 500
      L3_3(L4_3)
      do break end
      ::lbl_48::
      if not L2_3 then
        L3_3 = IsVehicleOnAllWheels
        L4_3 = cache
        L4_3 = L4_3.vehicle
        L3_3 = L3_3(L4_3)
        if L3_3 then
          L3_3 = L0_1
          if L1_3 < L3_3 then
            L3_3 = SetVehicleForwardSpeed
            L4_3 = cache
            L4_3 = L4_3.vehicle
            L5_3 = L0_1
            L3_3(L4_3, L5_3)
          end
        end
      end
      L3_3 = IsControlJustPressed
      L4_3 = 1
      L5_3 = 246
      L3_3 = L3_3(L4_3, L5_3)
      if L3_3 then
        L3_3 = GetEntitySpeed
        L4_3 = cache
        L4_3 = L4_3.vehicle
        L3_3 = L3_3(L4_3)
        L0_1 = L3_3
      end
      L3_3 = IsControlJustPressed
      L4_3 = 2
      L5_3 = 72
      L3_3 = L3_3(L4_3, L5_3)
      if L3_3 then
        IsCruiseControlEnabled = false
        L3_3 = Wait
        L4_3 = 500
        L3_3(L4_3)
        break
      end
      L3_3 = Wait
      L4_3 = 50
      L3_3(L4_3)
    end
  end
  L2_2(L3_2)
end
ToggleCruiseControl = L3_1
L3_1 = Config
L3_1 = L3_1.EnableCruiseControl
if L3_1 then
  L3_1 = Config
  L3_1 = L3_1.CruiseControlKeybind
  if L3_1 then
    L3_1 = RegisterCommand
    L4_1 = "toggle_cruise"
    function L5_1()
      local L0_2, L1_2, L2_2
      L0_2 = ToggleCruiseControl
      L1_2 = cache
      L1_2 = L1_2.vehicle
      L2_2 = cache
      L2_2 = L2_2.seat
      L0_2(L1_2, L2_2)
    end
    L6_1 = false
    L3_1(L4_1, L5_1, L6_1)
    L3_1 = RegisterKeyMapping
    L4_1 = "toggle_cruise"
    L5_1 = "Toggle cruise control"
    L6_1 = "keyboard"
    L7_1 = Config
    L7_1 = L7_1.CruiseControlKeybind
    if not L7_1 then
      L7_1 = "J"
    end
    L3_1(L4_1, L5_1, L6_1, L7_1)
  end
end
