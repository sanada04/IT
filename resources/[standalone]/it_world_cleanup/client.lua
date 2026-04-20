local targets = {
    {
        model = 'prop_com_gar_door_01',
        coords = vector3(1204.555, -3110.386, 6.557831),
        radius = 20.0,
    },
    {
        model = 'v_ilev_bl_shutter2',
        coords = vector3(3621.4751, 3750.9524, 28.6901),
        radius = 20.0,
    },
    {
        model = 'v_ilev_bl_doorpool',
        coords = vector3(3525.1230, 3701.6741, 20.9897),
        radius = 5.0,
    },
}

local function getModelHash(model)
    if type(model) == 'number' then return model end
    return GetHashKey(model)
end

local function removeTarget(entry)
    local hash = getModelHash(entry.model)
    local x, y, z = entry.coords.x, entry.coords.y, entry.coords.z
    local radius = entry.radius or 10.0

    -- Some runtimes don't provide RemoveWorldModel, so we rely on model hide natives.
    if type(RemoveWorldModel) == 'function' then
        RemoveWorldModel(hash, radius, x, y, z)
    end
    CreateModelHide(x, y, z, radius, hash, true)
    CreateModelHideExcludingScriptObjects(x, y, z, radius, hash, true)

    -- Remove any spawned instance nearby.
    local obj = GetClosestObjectOfType(x, y, z, radius, hash, false, false, false)
    if obj ~= 0 then
        SetEntityAsMissionEntity(obj, true, true)
        DeleteObject(obj)
    end
end

CreateThread(function()
    Wait(1500)

    -- Initial passes for first stream-in.
    for _ = 1, 3 do
        for i = 1, #targets do
            removeTarget(targets[i])
        end
        Wait(500)
    end

    -- Keep removing on stream changes.
    while true do
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)
        for i = 1, #targets do
            local entry = targets[i]
            if #(pcoords - entry.coords) < 350.0 then
                removeTarget(entry)
            end
        end
        Wait(5000)
    end
end)
