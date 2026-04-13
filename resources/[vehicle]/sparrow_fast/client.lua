local SPAWN_EVENT = 'sparrow_fast:spawn'
local MODEL_CANDIDATES = {
    'sparrow',
    'seasparrow2',
    'seasparrow',
    'seasparrow3'
}

local speedConfig = {
    fInitialDriveForce = 3.2,
    fInitialDriveMaxFlatVel = 9999.0,
    fBrakeForce = 3.0,
    fBrakeBiasFront = 0.52,
    fTractionCurveMax = 6.0,
    fTractionCurveMin = 5.2,
    fInitialDragCoeff = 0.1
}

local RUNTIME_MAX_SPEED = 99999.0
local EXTRA_BOOST_FORCE = 3
local spawnedFastVehicle = 0

local function loadModel(model)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        return false
    end

    RequestModel(model)

    local timeoutAt = GetGameTimer() + 10000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeoutAt then
            return false
        end
        Wait(0)
    end

    return true
end

local function resolveUsableModel()
    for _, modelName in ipairs(MODEL_CANDIDATES) do
        local model = GetHashKey(modelName)
        if loadModel(model) then
            return model, modelName
        end
    end

    return nil, nil
end

local function applyFastHandling(vehicle)
    for field, value in pairs(speedConfig) do
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', field, value)
    end

    -- Remove runtime top-speed limiter for this spawned vehicle only.
    SetEntityMaxSpeed(vehicle, RUNTIME_MAX_SPEED)
    ModifyVehicleTopSpeed(vehicle, 1000.0)
end

CreateThread(function()
    while true do
        Wait(0)

        if spawnedFastVehicle ~= 0 and DoesEntityExist(spawnedFastVehicle) then
            -- Re-apply in case other resources reset top-speed limits.
            SetEntityMaxSpeed(spawnedFastVehicle, RUNTIME_MAX_SPEED)
            ModifyVehicleTopSpeed(spawnedFastVehicle, 1000.0)

            local ped = PlayerPedId()
            if GetVehiclePedIsIn(ped, false) == spawnedFastVehicle and GetPedInVehicleSeat(spawnedFastVehicle, -1) == ped then
                -- INPUT_VEH_ACCELERATE: press W / RT
                if IsControlPressed(0, 71) then
                    ApplyForceToEntityCenterOfMass(spawnedFastVehicle, 1, 0.0, EXTRA_BOOST_FORCE, 0.0, true, true, true, false)
                end
            end
        else
            Wait(250)
        end
    end
end)

local function spawnFastSparrow()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local model, modelName = resolveUsableModel()
    if not model then
        TriggerEvent('chat:addMessage', {
            color = {255, 80, 80},
            args = {'sparrow_fast', 'モデル読み込み失敗: sparrow / seasparrow系が見つかりません'}
        })
        return
    end

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z + 1.0, heading, true, false)
    if vehicle == 0 then
        TriggerEvent('chat:addMessage', {
            color = {255, 80, 80},
            args = {'sparrow_fast', 'ヘリの生成に失敗しました'}
        })
        SetModelAsNoLongerNeeded(model)
        return
    end

    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetPedIntoVehicle(ped, vehicle, -1)

    applyFastHandling(vehicle)
    spawnedFastVehicle = vehicle
    SetModelAsNoLongerNeeded(model)

    TriggerEvent('chat:addMessage', {
        color = {80, 255, 120},
        args = {'sparrow_fast', ('高速版を生成しました: %s'):format(modelName)}
    })
end

RegisterNetEvent(SPAWN_EVENT, spawnFastSparrow)
