local QBCore      = exports['qb-core']:GetCoreObject()
local isOpen      = false
local textUIShown = false
local spawnedProps = {}

-- ── Prop 生成 ──────────────────────────────────────────────────────────────────

local function spawnProps()
    local hash = GetHashKey(Config.PropModel)
    RequestModel(hash)

    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Citizen.Wait(50)
    end

    if not HasModelLoaded(hash) then
        print('[casino-slots] Prop モデルの読み込みに失敗しました: ' .. Config.PropModel)
        return
    end

    for _, slot in ipairs(Config.Slots) do
        local ox = Config.PropOffset.x
        local oy = Config.PropOffset.y
        local oz = Config.PropOffset.z
        local prop = CreateObject(hash,
            slot.coords.x + ox,
            slot.coords.y + oy,
            slot.coords.z + oz,
            false, false, false)
        SetEntityHeading(prop, slot.heading)
        FreezeEntityPosition(prop, true)
        SetEntityCollision(prop, true, true)
        SetEntityInvincible(prop, true)
        table.insert(spawnedProps, prop)
    end

    SetModelAsNoLongerNeeded(hash)
end

local function deleteProps()
    for _, prop in ipairs(spawnedProps) do
        if DoesEntityExist(prop) then DeleteObject(prop) end
    end
    spawnedProps = {}
end

AddEventHandler('onClientResourceStop', function(res)
    if res == GetCurrentResourceName() then deleteProps() end
end)

Citizen.CreateThread(function()
    -- インテリアのストリーミング待ち
    Citizen.Wait(3000)
    spawnProps()
end)

-- ── 近距離インタラクション ────────────────────────────────────────────────────

local function openSlot()
    if isOpen then return end
    isOpen = true
    lib.hideTextUI()
    textUIShown = false

    local player = QBCore.Functions.GetPlayerData()
    SendNUIMessage({
        action  = 'open',
        bets    = Config.BetAmounts,
        balance = player.money['cash'],
        sounds  = Config.Sounds,
        chance  = { enabled = Config.Chance.enabled, spins = Config.Chance.spins },
    })
    SetNuiFocus(true, true)
end

Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local playerCoords = GetEntityCoords(PlayerPedId())
        local found = false

        for _, slot in ipairs(Config.Slots) do
            if #(playerCoords - slot.coords) < 3.0 then
                sleep = 0
                found = true
                if #(playerCoords - slot.coords) < Config.InteractDistance then
                    if not textUIShown and not isOpen then
                        lib.showTextUI('[E] スロットマシンを操作する')
                        textUIShown = true
                    end
                    if IsControlJustPressed(0, 38) and not isOpen then
                        openSlot()
                    end
                else
                    if textUIShown then lib.hideTextUI(); textUIShown = false end
                end
                break
            end
        end

        if not found and textUIShown then
            lib.hideTextUI()
            textUIShown = false
        end

        Citizen.Wait(sleep)
    end
end)

-- ── NUI コールバック ──────────────────────────────────────────────────────────

RegisterNUICallback('spin', function(data, cb)
    local result = lib.callback.await('casino-slots:spin', false, tonumber(data.bet))
    cb(result)
end)

RegisterNUICallback('close', function(_, cb)
    isOpen = false
    SetNuiFocus(false, false)
    if textUIShown then lib.hideTextUI(); textUIShown = false end
    cb({})
end)

RegisterNUICallback('getBalance', function(_, cb)
    local player = QBCore.Functions.GetPlayerData()
    cb({ balance = player.money['cash'] })
end)

-- ── サウンド ──────────────────────────────────────────────────────────────────
-- NUI から playSound('key') で呼ばれる

RegisterNUICallback('playSound', function(data, cb)
    local def = Config.Sounds[data.sound]
    if def and def.type == 'gta' then
        local useSet = (def.set ~= 'none' and def.set ~= '') and def.set or nil
        PlaySoundFrontend(-1, def.name, useSet, true)
    end
    cb({})
end)
