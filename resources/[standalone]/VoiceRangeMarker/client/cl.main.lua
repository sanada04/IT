local voiceModes = {}

local function fetchVoiceModes()
	TriggerEvent('pma-voice:settingsCallback', function(voiceSettings)
		if voiceSettings and voiceSettings.voiceModes then
			voiceModes = voiceSettings.voiceModes
		end
	end)
end

CreateThread(function()
	local deadline = GetGameTimer() + 10000
	while GetResourceState('pma-voice') ~= 'started' and GetGameTimer() < deadline do
		Wait(100)
	end
	if GetResourceState('pma-voice') == 'started' then
		Wait(0)
		fetchVoiceModes()
	end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
	if resourceName == 'pma-voice' then
		Wait(250)
		fetchVoiceModes()
	end
end)

local proximityRangeTimeout = 0;
local proximityRangeMarkerReachTimeOut = false
function CreateProximityRangeTimeout()
    proximityRangeTimeout = 2
	Citizen.CreateThread(function ()
		repeat
			Wait(1000)
			proximityRangeTimeout -= 1
		until (proximityRangeTimeout <= 0)
		proximityRangeMarkerReachTimeOut = true
		Wait(1)
		proximityRangeMarkerReachTimeOut = false
	end)
end

function CreateProximityRange(proximityRange)
	proximityRangeMarkerReachTimeOut = true
	Wait(1)
	proximityRangeMarkerReachTimeOut = false
	if proximityRangeTimeout <= 0 then 
        CreateProximityRangeTimeout()
    end
    proximityRangeTimeout = 2
	Citizen.CreateThread(function()
		while not proximityRangeMarkerReachTimeOut do
			Wait(0)
			Client.DrawMarker(proximityRange)
		end
	end)
end

AddEventHandler('pma-voice:setTalkingMode', function(mode)
	local range
	if voiceModes[mode] then
		range = voiceModes[mode][1]
	else
		local proximityState = LocalPlayer.state.proximity
		if type(proximityState) == 'table' then
			range = proximityState.distance
		end
	end
	if type(range) == 'number' then
		CreateProximityRange(range)
	end
end)