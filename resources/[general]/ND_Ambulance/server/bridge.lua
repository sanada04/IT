--- ox_inventory はサーバー export を `fn(nil, event, item, inventory, slot)` で呼ぶ（modules/items/shared.lua の useExport）。
function ND_AmbulanceNormalizeOxInvExport(event, item, inventory, slot, data)
	if event == nil and type(item) == "string" then
		return item, inventory, slot, data
	end
	return event, item, inventory, slot, data
end

local deadline = GetGameTimer() + 120000

while GetGameTimer() < deadline do
    local path = ND_AmbulanceGetBridgePath()
    if not path:find("standalone") then
        break
    end
    Wait(100)
end

local path = ND_AmbulanceGetBridgePath()
local ok, err = pcall(function()
    Bridge = lib.load(path)
end)

if not ok then
    error(("[ND_Ambulance] Bridge load failed (%s): %s"):format(path, tostring(err)))
end

if not Bridge then
    error(("[ND_Ambulance] Bridge module returned nil (%s)"):format(path))
end
