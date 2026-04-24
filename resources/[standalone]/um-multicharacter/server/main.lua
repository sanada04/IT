local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1
L0_1 = Framework
L1_1 = L0_1
L0_1 = L0_1.Core
L0_1(L1_1)
L0_1 = {}
L1_1 = {}
L2_1 = require
L3_1 = "server.list.deletelist"
L2_1 = L2_1(L3_1)
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2
  L2_2 = Framework
  L3_2 = L2_2
  L2_2 = L2_2.GetIdentifier
  L4_2 = A0_2
  L2_2, L3_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    return
  end
  L4_2 = GetPlayerIdentifierByType
  L5_2 = A0_2
  L6_2 = "license2"
  L4_2 = L4_2(L5_2, L6_2)
  L3_2 = L4_2 or L3_2
  if not L4_2 then
    L3_2 = L2_2
  end
  L4_2 = MySQL
  L4_2 = L4_2.scalar
  L4_2 = L4_2.await
  L5_2 = "SELECT license FROM players WHERE citizenid = ? LIMIT 1"
  L6_2 = {}
  L7_2 = A1_2
  L6_2[1] = L7_2
  L4_2 = L4_2(L5_2, L6_2)
  if L2_2 == L4_2 or L3_2 == L4_2 then
    L5_2 = "SHOW TABLES LIKE ?"
    L6_2 = "SHOW COLUMNS FROM %s LIKE ?"
    L7_2 = "DELETE FROM %s WHERE %s = ?"
    L8_2 = L2_1
    L8_2 = #L8_2
    L9_2 = {}
    L10_2 = 1
    L11_2 = L8_2
    L12_2 = 1
    for L13_2 = L10_2, L11_2, L12_2 do
      L14_2 = L2_1
      L14_2 = L14_2[L13_2]
      L15_2 = MySQL
      L15_2 = L15_2.scalar
      L15_2 = L15_2.await
      L16_2 = L5_2
      L17_2 = {}
      L18_2 = L14_2.table
      L17_2[1] = L18_2
      L15_2 = L15_2(L16_2, L17_2)
      L16_2 = L14_2.table
      if L15_2 == L16_2 then
        L16_2 = MySQL
        L16_2 = L16_2.scalar
        L16_2 = L16_2.await
        L18_2 = L6_2
        L17_2 = L6_2.format
        L19_2 = L14_2.table
        L17_2 = L17_2(L18_2, L19_2)
        L18_2 = {}
        L19_2 = L14_2.column
        L18_2[1] = L19_2
        L16_2 = L16_2(L17_2, L18_2)
        if L16_2 then
          L17_2 = L14_2.type
          L17_2 = A1_2 or L17_2
          if "citizenid" ~= L17_2 or not A1_2 then
            L17_2 = GetPlayerIdentifierByType
            L18_2 = A0_2
            L19_2 = L14_2.type
            L17_2 = L17_2(L18_2, L19_2)
          end
          L18_2 = table
          L18_2 = L18_2.insert
          L19_2 = L9_2
          L20_2 = {}
          L22_2 = L7_2
          L21_2 = L7_2.format
          L23_2 = L14_2.table
          L24_2 = L14_2.column
          L21_2 = L21_2(L22_2, L23_2, L24_2)
          L20_2.query = L21_2
          L21_2 = {}
          L22_2 = L17_2
          L21_2[1] = L22_2
          L20_2.values = L21_2
          L18_2(L19_2, L20_2)
        else
          L17_2 = Debug
          L18_2 = "Column "
          L19_2 = L14_2.column
          L20_2 = " does not exist in table "
          L21_2 = L14_2.table
          L18_2 = L18_2 .. L19_2 .. L20_2 .. L21_2
          L17_2(L18_2)
        end
      else
        L16_2 = Debug
        L17_2 = "Table "
        L18_2 = L14_2.table
        L19_2 = " does not exist."
        L17_2 = L17_2 .. L18_2 .. L19_2
        L16_2(L17_2)
      end
    end
    L10_2 = #L9_2
    if L10_2 > 0 then
      L10_2 = MySQL
      L10_2 = L10_2.transaction
      L10_2 = L10_2.await
      L11_2 = L9_2
      L10_2 = L10_2(L11_2)
      if L10_2 then
        L11_2 = TriggerClientEvent
        L12_2 = "qb-multicharacter:client:chooseChar"
        L13_2 = A0_2
        L11_2(L12_2, L13_2)
        L11_2 = Debug
        L12_2 = "Character Deleted"
        L13_2 = A1_2
        L12_2 = L12_2 .. L13_2
        L11_2(L12_2)
        L11_2 = AddLogs
        L12_2 = A0_2
        L13_2 = "[DELETE]"
        L14_2 = "Character Deleted | CitizenID: "
        L15_2 = A1_2
        L14_2 = L14_2 .. L15_2
        L15_2 = "red"
        L16_2 = "deletecharacter"
        L11_2(L12_2, L13_2, L14_2, L15_2, L16_2)
      end
    end
  else
    L5_2 = AddLogs
    L6_2 = A0_2
    L7_2 = "[EXPLOIT!!!!]"
    L8_2 = "User tried to delete character that does not belong to him"
    L9_2 = "red"
    L10_2 = "exploit"
    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
    L5_2 = SetTimeout
    L6_2 = 5000
    function L7_2()
      local L0_3, L1_3, L2_3
      L0_3 = DropPlayer
      L1_3 = A0_2
      L2_3 = "Exploit Attempt 2"
      L0_3(L1_3, L2_3)
    end
    L5_2(L6_2, L7_2)
  end
end
L4_1 = lib
L4_1 = L4_1.callback
L4_1 = L4_1.register
L5_1 = "um-multicharacter:server:GetCharacters"
function L6_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  if not A0_2 then
    return
  end
  L1_2 = {}
  L2_2 = GetNumberCharactersSlot
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L3_2 = Framework
  L4_2 = L3_2
  L3_2 = L3_2.GetPlayerQuery
  L5_2 = A0_2
  L3_2 = L3_2(L4_2, L5_2)
  L4_2 = L3_2[1]
  if nil ~= L4_2 then
    L4_2 = 1
    L5_2 = #L3_2
    L6_2 = 1
    for L7_2 = L4_2, L5_2, L6_2 do
      L8_2 = L3_2[L7_2]
      L9_2 = json
      L9_2 = L9_2.decode
      L10_2 = L3_2[L7_2]
      L10_2 = L10_2.charinfo
      L9_2 = L9_2(L10_2)
      L8_2.charinfo = L9_2
      L8_2 = L3_2[L7_2]
      L9_2 = json
      L9_2 = L9_2.decode
      L10_2 = L3_2[L7_2]
      L10_2 = L10_2.money
      L9_2 = L9_2(L10_2)
      L8_2.money = L9_2
      L8_2 = L3_2[L7_2]
      L9_2 = json
      L9_2 = L9_2.decode
      L10_2 = L3_2[L7_2]
      L10_2 = L10_2.job
      L9_2 = L9_2(L10_2)
      L8_2.job = L9_2
      L8_2 = L3_2[L7_2]
      L8_2 = L8_2.cid
      if not L8_2 then
        L8_2 = tonumber
        L9_2 = L3_2[L7_2]
        L9_2 = L9_2.charinfo
        L9_2 = L9_2.cid
        L8_2 = L8_2(L9_2)
      end
      L9_2 = L3_2[L7_2]
      L1_2[L8_2] = L9_2
    end
    L4_2 = Debug
    L5_2 = "Characters loaded for "
    L6_2 = GetPlayerName
    L7_2 = A0_2
    L6_2 = L6_2(L7_2)
    L7_2 = " ("
    L8_2 = A0_2
    L9_2 = ")"
    L5_2 = L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2
    L4_2(L5_2)
    L4_2 = L1_2
    L5_2 = L2_2
    return L4_2, L5_2
  else
    L4_2 = Debug
    L5_2 = "Not Characters Data | New Player"
    L4_2(L5_2)
    L4_2 = nil
    L5_2 = Config
    L5_2 = L5_2.DefaultSlots
    return L4_2, L5_2
  end
end
L4_1(L5_1, L6_1)
L4_1 = lib
L4_1 = L4_1.callback
L4_1 = L4_1.register
L5_1 = "um-multicharacter:server:loadUserData"
function L6_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  if not A0_2 then
    return
  end
  L2_2 = A0_2
  L3_2 = Framework
  L4_2 = L3_2
  L3_2 = L3_2.Login
  L5_2 = L2_2
  L6_2 = A1_2.citizenid
  L3_2 = L3_2(L4_2, L5_2, L6_2)
  if L3_2 then
    repeat
      L3_2 = Wait
      L4_2 = 10
      L3_2(L4_2)
      L3_2 = L0_1
      L3_2 = L3_2[L2_2]
    until L3_2
    L3_2 = print
    L4_2 = "^2[PLAY GAME]^7 "
    L5_2 = GetPlayerName
    L6_2 = L2_2
    L5_2 = L5_2(L6_2)
    L6_2 = " (Citizen ID: "
    L7_2 = A1_2.citizenid
    L8_2 = ") user has joined the server "
    L4_2 = L4_2 .. L5_2 .. L6_2 .. L7_2 .. L8_2
    L3_2(L4_2)
    L3_2 = Framework
    L4_2 = L3_2
    L3_2 = L3_2.RefreshCommand
    L5_2 = L2_2
    L3_2(L4_2, L5_2)
    L3_2 = loadHouseData
    L4_2 = L2_2
    L3_2(L4_2)
    L3_2 = GetCharacterReadySpawnUI
    L4_2 = L2_2
    L5_2 = A1_2
    L3_2(L4_2, L5_2)
    L3_2 = SetPlayerRoutingBucket
    L4_2 = L2_2
    L5_2 = 0
    L3_2(L4_2, L5_2)
    L3_2 = AddLogs
    L4_2 = L2_2
    L5_2 = "[PLAY GAME]"
    L6_2 = "User has joined the server | CitizenID: "
    L7_2 = A1_2.citizenid
    L6_2 = L6_2 .. L7_2
    L7_2 = "green"
    L8_2 = "playgame"
    L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
  end
end
L4_1(L5_1, L6_1)
L4_1 = lib
L4_1 = L4_1.callback
L4_1 = L4_1.register
L5_1 = "um-multicharacter:server:createCharacter"
function L6_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  if not A0_2 then
    return
  end
  L2_2 = L1_1
  L2_2 = L2_2[A0_2]
  if not L2_2 then
    L2_2 = AddLogs
    L3_2 = A0_2
    L4_2 = "[EXPLOIT!!!!]"
    L5_2 = "User using cheats!!!!!"
    L6_2 = "red"
    L7_2 = "exploit"
    L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
    L2_2 = DropPlayer
    L3_2 = A0_2
    L4_2 = "Exploit Attempt 3"
    L2_2(L3_2, L4_2)
    return
  end
  L2_2 = L1_1
  L2_2[A0_2] = nil
  L2_2 = A0_2
  L3_2 = {}
  L4_2 = A1_2.cid
  L3_2.cid = L4_2
  L3_2.charinfo = A1_2
  L4_2 = Framework
  L5_2 = L4_2
  L4_2 = L4_2.Login
  L6_2 = L2_2
  L7_2 = false
  L8_2 = L3_2
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
  if L4_2 then
    repeat
      L4_2 = Wait
      L5_2 = 10
      L4_2(L5_2)
      L4_2 = L0_1
      L4_2 = L4_2[L2_2]
    until L4_2
    L4_2 = print
    L5_2 = "^2[CREATE CHARACTER]^7 "
    L6_2 = GetPlayerName
    L7_2 = L2_2
    L6_2 = L6_2(L7_2)
    L7_2 = " User has created new character"
    L5_2 = L5_2 .. L6_2 .. L7_2
    L4_2(L5_2)
    L4_2 = Framework
    L5_2 = L4_2
    L4_2 = L4_2.RefreshCommand
    L6_2 = L2_2
    L4_2(L5_2, L6_2)
    L4_2 = loadHouseData
    L5_2 = L2_2
    L4_2(L5_2)
    L4_2 = GetApartmentInsideStartSpawnUI
    L5_2 = L2_2
    L6_2 = L3_2
    L4_2(L5_2, L6_2)
    L4_2 = GiveStarterItems
    L5_2 = L2_2
    L4_2(L5_2)
    L4_2 = SetPlayerRoutingBucket
    L5_2 = L2_2
    L6_2 = 0
    L4_2(L5_2, L6_2)
  end
  L4_2 = AddLogs
  L5_2 = L2_2
  L6_2 = "[CREATE]"
  L7_2 = "User has created new character | Name: "
  L8_2 = A1_2
  if L8_2 then
    L8_2 = L8_2.firstname
  end
  L9_2 = " | "
  L10_2 = A1_2
  if L10_2 then
    L10_2 = L10_2.lastname
  end
  L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2
  L8_2 = "purple"
  L9_2 = "createcharacter"
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
L4_1(L5_1, L6_1)
L4_1 = lib
L4_1 = L4_1.callback
L4_1 = L4_1.register
L5_1 = "um-multicharacter:server:deleteCharacter"
function L6_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  if not A0_2 or not A1_2 then
    return
  end
  L2_2 = L3_1
  L3_2 = A0_2
  L4_2 = A1_2
  L2_2(L3_2, L4_2)
end
L4_1(L5_1, L6_1)
L4_1 = RegisterNetEvent
L5_1 = "um-multicharacter:server:disconnect"
function L6_1()
  local L0_2, L1_2, L2_2
  L0_2 = DropPlayer
  L1_2 = source
  L2_2 = "Multicharacter Disconnect"
  L0_2(L1_2, L2_2)
end
L4_1(L5_1, L6_1)
L4_1 = AddEventHandler
L5_1 = Framework
L5_1 = L5_1.Events
L5_1 = L5_1.loadedSP
function L6_1(A0_2)
  local L1_2, L2_2
  L1_2 = Wait
  L2_2 = 1000
  L1_2(L2_2)
  L1_2 = A0_2.PlayerData
  L2_2 = L1_2.source
  L1_2 = L0_1
  L1_2[L2_2] = true
end
L4_1(L5_1, L6_1)
L4_1 = AddEventHandler
L5_1 = Framework
L5_1 = L5_1.Events
L5_1 = L5_1.unload
function L6_1(A0_2)
  local L1_2
  L1_2 = L0_1
  L1_2[A0_2] = false
end
L4_1(L5_1, L6_1)
L4_1 = Config
L4_1 = L4_1.Dob
L4_1 = L4_1.Lowest
L5_1 = Config
L5_1 = L5_1.Dob
L5_1 = L5_1.Highest
L6_1 = Config
L6_1 = L6_1.Dob
L6_1 = L6_1.Notify
function L7_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = string
  L1_2 = L1_2.find
  L2_2 = A0_2
  L3_2 = "[\"'%;%=%*]"
  return L1_2(L2_2, L3_2)
end
L8_1 = lib
L8_1 = L8_1.callback
L8_1 = L8_1.register
L9_1 = "um-multicharacter:callback:inputCheck"
function L10_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  if not A0_2 or not A1_2 then
    return
  end
  L2_2 = string
  L2_2 = L2_2.sub
  L3_2 = A1_2.birthdate
  L4_2 = 1
  L5_2 = 4
  L2_2 = L2_2(L3_2, L4_2, L5_2)
  L3_2 = tonumber
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  L4_2 = L4_1
  if not (L3_2 > L4_2) then
    L3_2 = tonumber
    L4_2 = L2_2
    L3_2 = L3_2(L4_2)
    L4_2 = L5_1
    if not (L3_2 < L4_2) then
      goto lbl_38
    end
  end
  L3_2 = TriggerClientEvent
  L4_2 = "ox_lib:notify"
  L5_2 = A0_2
  L6_2 = {}
  L7_2 = L6_1.invalid
  L8_2 = L7_2
  L7_2 = L7_2.format
  L9_2 = L2_2
  L7_2 = L7_2(L8_2, L9_2)
  L6_2.title = L7_2
  L6_2.type = "error"
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = false
  do return L3_2 end
  ::lbl_38::
  L3_2 = {}
  L4_2 = A1_2.cid
  L5_2 = A1_2.gender
  L6_2 = A1_2.firstname
  L7_2 = A1_2.lastname
  L8_2 = A1_2.nationality
  L9_2 = A1_2.birthdate
  L3_2[1] = L4_2
  L3_2[2] = L5_2
  L3_2[3] = L6_2
  L3_2[4] = L7_2
  L3_2[5] = L8_2
  L3_2[6] = L9_2
  L4_2 = 1
  L5_2 = #L3_2
  L6_2 = 1
  for L7_2 = L4_2, L5_2, L6_2 do
    L8_2 = L3_2[L7_2]
    if L8_2 then
      L9_2 = L7_1
      L10_2 = L8_2
      L9_2 = L9_2(L10_2)
      if not L9_2 then
        goto lbl_75
      end
    end
    L9_2 = TriggerClientEvent
    L10_2 = "ox_lib:notify"
    L11_2 = A0_2
    L12_2 = {}
    L13_2 = L6_1.invalid
    L14_2 = L13_2
    L13_2 = L13_2.format
    L15_2 = L8_2 or L15_2
    if not L8_2 then
      L15_2 = "null"
    end
    L13_2 = L13_2(L14_2, L15_2)
    L12_2.title = L13_2
    L12_2.type = "error"
    L9_2(L10_2, L11_2, L12_2)
    L9_2 = false
    do return L9_2 end
    ::lbl_75::
  end
  L4_2 = L1_1
  L4_2 = L4_2[A0_2]
  if not L4_2 then
    L4_2 = L1_1
    L4_2[A0_2] = true
  end
  L4_2 = true
  return L4_2
end
L8_1(L9_1, L10_1)
