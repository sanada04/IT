-- qb-core を ox_core より先に検出（両方 ensure している QBCore サーバー向け。ox 単体は ox_core のみ起動で選ばれる）
local bridgeResources = {
    { "ND_Core", "nd" },
    { "qbx_core", "qbx" },
    { "qb-core", "qb" },
    { "ox_core", "ox" },
    -- { "es_extended", "esx" },
}

-- Target ブリッジは未使用（client は exports.ox_target 固定）。ターゲット統一は server.cfg 側で調整。
local targetResources = {
    "ox_target",
}

function ND_AmbulanceGetBridgePath()
    for i=1, #bridgeResources do
        local info = bridgeResources[i]
        if GetResourceState(info[1]):find("start") then
            lib.print.info(("Found active framework: ^6%s"):format(info[1]))
            return ("bridge.framework.%s.%s"):format(info[2], lib.context)
        end
    end

    lib.print.info("No matching framework found, defaulting to ^6standalone mode.")
    return ("bridge.framework.standalone.%s"):format(lib.context)
end

local function getBridgeTarget()
    for i=1, #targetResources do
        local target = targetResources[i]
        if GetResourceState(target):find("start") then
            lib.print.info(("Found interaction resource: ^6%s"):format(target))
            return ("bridge.target.%s"):format(target)
        end
    end

    lib.print.info("No matching target resource found, defaulting to ^6standalone mode.")
    return "bridge.target.standalone"
end

if IsDuplicityVersion() then
    -- Bridge is set in server/bridge.lua after framework resources are up.
else
    Bridge = lib.load(ND_AmbulanceGetBridgePath())
end

--- ox_inventory のクライアント item export は `fn(nil, ...)` で呼ばれる。
function ND_AmbulanceNormalizeOxInvClientExport(a, b, c)
	if a == nil then
		return b, c
	end
	return a, b
end

-- if lib.context == "client" then
--     Target = lib.load(getBridgeTarget())
-- end