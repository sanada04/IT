local ufo = {
    base = { veh = 'hydra', fakeveh = 'p_spinning_anus_s' },
    vehPR = { x = 0.0, y = 0.0, z = -0.6, xrot = 0.0, yrot = 0.0, zrot = 180.0 },
}

local buttons = {
    { 'Leave the vehicle', 23 },
    { 'Toggle stationary mode', 51 },
    { 'Toggle wheels', 113 }
}

local isUsingUfo = false

local function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function InstructionnalButtons(buttonList)
    local scaleform = RequestScaleformMovie('instructional_buttons')
    while not HasScaleformMovieLoaded(scaleform) do Wait(10) end

    PushScaleformMovieFunction(scaleform, 'CLEAR_ALL')
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, 'SET_CLEAR_SPACE')
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    for k, v in ipairs(buttonList) do
        PushScaleformMovieFunction(scaleform, 'SET_DATA_SLOT')
        PushScaleformMovieFunctionParameterInt(k)
        PushScaleformMovieFunctionParameterString(GetControlInstructionalButton(2, v[2], true))
        PushScaleformMovieMethodParameterString(v[1])
        PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, 'SET_BACKGROUND_COLOUR')
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

local function loadModel(hash)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        return false
    end
    RequestModel(hash)
    local timeoutAt = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeoutAt then
            return false
        end
        Wait(10)
    end
    return true
end

local function StartActivity(v)
    if isUsingUfo then
        notify('~y~UFOは既に使用中です')
        return
    end

    local playerPed = PlayerPedId()
    local vehHash = GetHashKey(v.base.veh)
    local objHash = GetHashKey(v.base.fakeveh)

    if not loadModel(vehHash) then
        notify('~r~車両モデルの読み込みに失敗')
        return
    end
    if not loadModel(objHash) then
        notify('~r~UFOオブジェクトの読み込みに失敗')
        return
    end

    local spawnCoords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    -- no such entity 警告回避のためローカルエンティティとして生成
    local veh = CreateVehicle(vehHash, spawnCoords.x, spawnCoords.y, spawnCoords.z + 1.0, heading, false, false)
    if veh == 0 then
        notify('~r~UFO車両の生成に失敗')
        return
    end

    local fakeveh = CreateObject(objHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
    if fakeveh == 0 then
        DeleteVehicle(veh)
        notify('~r~UFOオブジェクトの生成に失敗')
        return
    end

    isUsingUfo = true
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', false)
    local buttonsToDraw = InstructionnalButtons(buttons)

    SetEntityInvincible(veh, true)
    SetVehicleOnGroundProperly(veh)
    AttachEntityToEntity(fakeveh, veh, 0, v.vehPR.x, v.vehPR.y, v.vehPR.z, v.vehPR.xrot, v.vehPR.yrot, v.vehPR.zrot, false, false, false, false, 2, true)
    TaskWarpPedIntoVehicle(playerPed, veh, -1)
    SetModelAsNoLongerNeeded(vehHash)
    SetModelAsNoLongerNeeded(objHash)

    CreateThread(function()
        while DoesEntityExist(veh) and GetVehiclePedIsIn(playerPed, false) == veh do
            Wait(0)
            DrawScaleformMovieFullscreen(buttonsToDraw, 255, 255, 255, 255, 0)

            local coordsCam = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -100.0, 10.0)
            local coordsPly = GetEntityCoords(playerPed)
            SetCamCoord(cam, coordsCam.x, coordsCam.y, coordsCam.z)
            PointCamAtCoord(cam, coordsPly.x, coordsPly.y, coordsPly.z)
            SetCamActive(cam, true)
            RenderScriptCams(true, true, 500, true, true)
        end

        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(cam, false)
        if DoesEntityExist(veh) then DeleteVehicle(veh) end
        if DoesEntityExist(fakeveh) then DeleteObject(fakeveh) end
        isUsingUfo = false
    end)
end

RegisterCommand('ufo', function()
    StartActivity(ufo)
end, false)