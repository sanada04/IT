Config = {}
Config.Locale = "ja"
Config.Currency = "¥"
Config.NumberFormat = "ja-JP" -- follows [language]-[country code]
Config.CustomPedAvatarUrl = false -- pedAvatar を無効化する場合は false のままでOK

-- Integrations
Config.Framework = "QBCore" -- or "QBCore", "Qbox", "ESX"
Config.FuelSystem = "cdn-fuel" -- or "LegacyFuel", "lc_fuel", "ps-fuel", "lj-fuel", "ox_fuel", "cdn-fuel", "hyon_gas_station", "okokGasStation", "nd_fuel", "myFuel", "ti_fuel", "Renewed-Fuel", "rcore_fuel", "none"

-- Measurements
Config.SpeedMeasurement = "kph" -- or "kph"
Config.DistanceMeasurement = "meters" -- or "meters"

-- Cruise Control
Config.EnableCruiseControl = true
Config.CruiseControlKeybind = "J"

-- Seatbelt
Config.EnableSeatbelt = true
Config.UseCustomSeatbeltIntegration = true -- Enable to use a third-party seatbelt script via Framework.Client.ToggleSeatbelt (in framework/cl-functions.lua)
Config.SeatbeltKeybind = "B"
Config.PreventExitWhileBuckled = true
Config.DisablePassengerSeatbelts = false
Config.MinSpeedMphEjectionSeatbeltOff = 20.0
Config.MinSpeedMphEjectionSeatbeltOn = 100.0
Config.DisableSeatbeltInEmergencyVehicles = true

-- Default component displays
Config.ShowMinimapOnFoot = true
Config.ShowMinimapInVehicle = true
Config.ShowCompassOnFoot = true
Config.ShowComponents = {
  pedAvatar = false, -- アバター要素を完全に非表示（マイク表示のみ）
  voiceOrRadio = true,
  serverId = true,
  time = true,
  job = true,
  gang = false,
  bankBalance = true,
  cashBalance = true,
  dirtyMoneyBalance = true,
  weapon = true,
  serverLogo = true -- You can enable this and then change the server-logo.png in the root folder
}

-- If ShowComponents.serverLogo & Config.AllowUsersToEditLayout are enabled, should players be able to edit the logo's visibility/position?
Config.AllowServerLogoEditing = true

-- Vehicle Control
Config.VehicleControlKeybind = "F6"
Config.AllowPassengersToUseVehicleControl = true -- Passengers are only able to toggle their own window, door or change seats

-- Other keybinds; set them to false to disable
Config.EngineToggleKeybind = "G"
Config.BoatAnchorKeybind = "J"
Config.IndicatorLeftKeybind = "LEFT"
Config.IndicatorRightKeybind = "RIGHT"
Config.IndicatorHazardsKeybind = "UP"

-- Commands
Config.OpenSettingsCommand = "hud"
Config.ToggleHudCommand = "togglehud"

-- Nearest postal
-- Credit to https://github.com/DevBlocky/nearest-postal - see license in data/nearest-postal/LICENSE
Config.ShowNearestPostal = false
Config.NearestPostalsData = "data/nearest-postal/ocrp-postals.json"

-- Learn more about configuring default settings: https://docs.jgscripts.com/hud/default-settings
Config.DefaultSettingsData = "data/default-settings.json"
Config.DefaultSettingsKvpPrefix = "hud-" -- This is really useful for essentially "resetting" everyone's currently saved settings, especially if you've added a new default-settings.json profile. You can set this to like "hud-v2-" for example so that everyone's existing data starts fresh with your new profile.
Config.AllowPlayersToEditSettings = true
Config.AllowUsersToEditLayout = true

-- Dev/debug settings
Config.UpdateRadarZoom = true -- Enable this if radar is flicking/disappearing
Config.DevDeleteAllUserSettingsOnStart = false -- Delete player existing KVP when they log in?
Config.Debug = false