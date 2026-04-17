local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1
L0_1 = {}
L1_1 = pairs
L2_1 = Config
L2_1 = L2_1.WeaponNames
if not L2_1 then
  L2_1 = {}
end
L1_1, L2_1, L3_1, L4_1 = L1_1(L2_1)
for L5_1 in L1_1, L2_1, L3_1, L4_1 do
  L6_1 = joaat
  L7_1 = L5_1
  L6_1 = L6_1(L7_1)
  L0_1[L6_1] = L5_1
end
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L1_2 = Config
  L1_2 = L1_2.ShowComponents
  if L1_2 then
    L1_2 = L1_2.weapon
  end
  if not L1_2 then
    L1_2 = false
    return L1_2
  end
  if nil == A0_2 then
    L1_2 = cache
    A0_2 = L1_2.weapon
  end
  if not A0_2 then
    L1_2 = false
    return L1_2
  end
  L1_2 = L0_1
  L1_2 = L1_2[A0_2]
  L2_2 = Config
  L2_2 = L2_2.WeaponNames
  if L2_2 then
    L2_2 = L2_2[L1_2]
  end
  L3_2 = GetCurrentPedVehicleWeapon
  L4_2 = cache
  L4_2 = L4_2.ped
  L3_2, L4_2 = L3_2(L4_2)
  if L3_2 then
    L2_2 = "Vehicle Weapon"
  end
  if L3_2 then
    L5_2 = GetVehicleWeaponRestrictedAmmo
    L6_2 = cache
    L6_2 = L6_2.vehicle
    L7_2 = L4_2
    L5_2 = L5_2(L6_2, L7_2)
    if L5_2 then
      goto lbl_46
    end
  end
  L5_2 = GetAmmoInPedWeapon
  L6_2 = cache
  L6_2 = L6_2.ped
  L7_2 = A0_2
  L5_2 = L5_2(L6_2, L7_2)
  ::lbl_46::
  L6_2 = GetAmmoInClip
  L7_2 = cache
  L7_2 = L7_2.ped
  L8_2 = A0_2
  L6_2, L7_2 = L6_2(L7_2, L8_2)
  L8_2 = {}
  L8_2.weaponHash = L1_2
  L8_2.weaponName = L2_2
  L9_2 = L5_2 - L7_2
  L8_2.reserveAmmo = L9_2
  L8_2.clipAmmo = L7_2
  return L8_2
end
GetWeaponData = L1_1
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = SendNUIMessage
  L2_2 = {}
  L2_2.type = "weaponData"
  L3_2 = GetWeaponData
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L2_2.weaponData = L3_2
  L1_2(L2_2)
end
L2_1 = false
function L3_1()
  local L0_2, L1_2
  L0_2 = CreateThread
  function L1_2()
    local L0_3, L1_3
    L0_3 = Wait
    L1_3 = 10
    L0_3(L1_3)
    L0_3 = Config
    L0_3 = L0_3.ShowComponents
    if L0_3 then
      L0_3 = L0_3.weapon
    end
    if not L0_3 then
      return
    end
    L0_3 = cache
    L0_3 = L0_3.ped
    if L0_3 then
      L0_3 = cache
      L0_3 = L0_3.weapon
      if L0_3 then
        goto lbl_21
      end
    end
    do return end
    ::lbl_21::
    L0_3 = L2_1
    if L0_3 then
      return
    end
    L0_3 = true
    L2_1 = L0_3
    while true do
      L0_3 = cache
      L0_3 = L0_3.ped
      if not L0_3 then
        break
      end
      L0_3 = cache
      L0_3 = L0_3.weapon
      if not L0_3 then
        break
      end
      L0_3 = IsHudRunning
      if not L0_3 then
        break
      end
      L0_3 = Wait
      L1_3 = 1000
      L0_3(L1_3)
      L0_3 = L1_1
      L1_3 = cache
      L1_3 = L1_3.weapon
      L0_3(L1_3)
    end
    L0_3 = false
    L2_1 = L0_3
  end
  L0_2(L1_2)
end
function L4_1()
  local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.ShowComponents
  if L0_2 then
    L0_2 = L0_2.weapon
  end
  if L0_2 then
    L0_2 = cache
    L0_2 = L0_2.weapon
    if L0_2 then
      L0_2 = L1_1
      L1_2 = cache
      L1_2 = L1_2.weapon
      L0_2(L1_2)
      L0_2 = L3_1
      L0_2()
    end
  end
end
CheckWeaponOnLoad = L4_1
L4_1 = Config
L4_1 = L4_1.ShowComponents
if L4_1 then
  L4_1 = L4_1.weapon
end
if L4_1 then
  L4_1 = lib
  L4_1 = L4_1.onCache
  L5_1 = "weapon"
  function L6_1(A0_2)
    local L1_2, L2_2
    L1_2 = L1_1
    L2_2 = A0_2
    L1_2(L2_2)
    L1_2 = L3_1
    L1_2()
  end
  L4_1(L5_1, L6_1)
  L4_1 = AddEventHandler
  L5_1 = "CEventGunShot"
  function L6_1(A0_2, A1_2)
    local L2_2, L3_2
    L2_2 = cache
    L2_2 = L2_2.ped
    if A1_2 ~= L2_2 then
      return
    end
    L2_2 = L1_1
    L3_2 = cache
    L3_2 = L3_2.weapon
    L2_2(L3_2)
    L2_2 = L3_1
    L2_2()
  end
  L4_1(L5_1, L6_1)
end
