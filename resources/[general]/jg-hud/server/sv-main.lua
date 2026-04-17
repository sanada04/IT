if not Config.UseCustomSeatbeltIntegration then
  SetConvarReplicated("game_enableFlyThroughWindscreen", "true")
end

CreateThread(function()
  Wait(10000)
  pcall(function()
    if GetResourceState("jg-vehicleindicators") == "started" then
      StopResource("jg-vehicleindicators")
    end
  end)
end)