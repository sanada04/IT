local L0_1, L1_1, L2_1, L3_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  if not A0_2 then
    L2_2 = Debug
    L3_2 = "Source is nil"
    L4_2 = "error"
    return L2_2(L3_2, L4_2)
  end
  L2_2 = tonumber
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L2_2 = L2_2 + 1000
  L3_2 = A1_2 or L3_2
  if not A1_2 then
    L3_2 = "UNKWN"
  end
  L4_2 = SetPlayerRoutingBucket
  L5_2 = A0_2
  L6_2 = L2_2
  L4_2(L5_2, L6_2)
  L4_2 = Debug
  L5_2 = L3_2
  L6_2 = " Player Routing Bucket Set: "
  L7_2 = tostring
  L8_2 = source
  L7_2 = L7_2(L8_2)
  L8_2 = " - "
  L9_2 = L2_2
  L10_2 = ""
  L5_2 = L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2
  L4_2(L5_2)
end
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "um-multi:bucket:setRandomBucket"
function L3_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = L0_1
  L2_2 = A0_2
  L3_2 = "Started: "
  L1_2(L2_2, L3_2)
end
L1_1(L2_1, L3_1)
L1_1 = RegisterNetEvent
L2_1 = Framework
L2_1 = L2_1.Events
L2_1 = L2_1.logout
function L3_1()
  local L0_2, L1_2, L2_2
  L0_2 = L0_1
  L1_2 = source
  L2_2 = "Logout Event House"
  L0_2(L1_2, L2_2)
end
L1_1(L2_1, L3_1)
