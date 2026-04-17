IsSeatbeltOn = true
local seatbeltThreadCreated = false
local useMstSeatbelt = Config.UseCustomSeatbeltIntegration and GetResourceState("mst_seatbelt") == "started"

---Can vehicle class have a seatbelt? Disabled for bikes, motorcycles boats etc by default
---@param vehicle integer
---@return boolean canHaveSeatbelt
local function canVehicleClassHaveSeatbelt(vehicle)
  if not Config.EnableSeatbelt then return false end

  if not vehicle or not DoesEntityExist(vehicle) then
    return false
  end
  
  local vehicleClass = GetVehicleClass(vehicle)
  
  local seatbeltCompatibleClasses = {
    [0] = true,  -- Compacts
    [1] = true,  -- Sedans
    [2] = true,  -- SUVs
    [3] = true,  -- Coupes
    [4] = true,  -- Muscle
    [5] = true,  -- Sports Classics
    [6] = true,  -- Sports
    [7] = true,  -- Super
    [9] = true,  -- Off-road
    [10] = true, -- Industrial
    [11] = true, -- Utility
    [12] = true, -- Vans
    [17] = true, -- Service
    [18] = true, -- Emergency
    [19] = true, -- Military
    [20] = true, -- Commercial
  }
  
  return seatbeltCompatibleClasses[vehicleClass] or false
end

---Is a seatbelt allowed in this particular vehicle? Checks emergency vehicles, passenger seats etc
---@param vehicle integer
---@return boolean isSeatbeltAllowed
local function isSeatbeltAllowed(vehicle)
  if not Config.EnableSeatbelt then return false end
  if not vehicle then return false end
  
  if not canVehicleClassHaveSeatbelt(vehicle) then
    return false
  end

  if Config.DisablePassengerSeatbelts and cache.seat ~= -1 then
    return false
  end
  
  if Config.DisableSeatbeltInEmergencyVehicles then
    local vehicleClass = GetVehicleClass(vehicle)
    if vehicleClass == 18 then
      return false
    end
  end
  
  return true
end

---Simple built in seatbelt system using "fly through windscreen" natives
---@param willBeYeeted boolean
local function setWhetherPedWillFlyThroughWindscreen(willBeYeeted)
  local min = willBeYeeted and Config.MinSpeedMphEjectionSeatbeltOff or Config.MinSpeedMphEjectionSeatbeltOn
  local minConverted = min / 2.237

  SetFlyThroughWindscreenParams(minConverted, 0.0, 0.0, 10.0)
  SetPedConfigFlag(cache.ped, 32, willBeYeeted)
end

---Toggle seatbelt main function
---@param vehicle integer
---@param toggle boolean
function ToggleSeatbelt(vehicle, toggle)
  if not vehicle or not isSeatbeltAllowed(vehicle) then
    return
  end

  IsSeatbeltOn = toggle
  LocalPlayer.state:set("seatbelt", toggle)

  if useMstSeatbelt then
    Framework.Client.ToggleSeatbelt(vehicle, toggle)
    return
  end

  if Config.UseCustomSeatbeltIntegration then
    Framework.Client.ToggleSeatbelt(vehicle, toggle)
  else
    setWhetherPedWillFlyThroughWindscreen(not toggle)
  end
end

---Thread to disable exiting vehicle when seatbelt is on
local function startSeatbeltExitPreventionThread()
  if not Config.PreventExitWhileBuckled then return end
  if seatbeltThreadCreated then return end
  seatbeltThreadCreated = true
  
  CreateThread(function()  
    while cache.vehicle do
      if IsSeatbeltOn then
        DisableControlAction(0, 75, true)
        DisableControlAction(27, 75, true)
      end
      
      Wait(1)
    end
    
    seatbeltThreadCreated = false
  end)
end

---When entering vehicle
---@param vehicle integer
local function onEnterVehicle(vehicle)
  if not isSeatbeltAllowed(vehicle) then
    if not useMstSeatbelt then
      setWhetherPedWillFlyThroughWindscreen(false)
    end
    IsSeatbeltOn = true
    LocalPlayer.state:set("seatbelt", true)
    return
  end

  if useMstSeatbelt then
    IsSeatbeltOn = false
    LocalPlayer.state:set("seatbelt", false)
    CreateThread(function()
      Wait(200)
      if cache.vehicle and vehicle == cache.vehicle and exports["mst_seatbelt"] and exports["mst_seatbelt"].HasSeatbelt then
        local currentState = exports["mst_seatbelt"]:HasSeatbelt()
        IsSeatbeltOn = currentState
        LocalPlayer.state:set("seatbelt", currentState)
      end
    end)
  else
    ToggleSeatbelt(vehicle, false)
  end

  if not useMstSeatbelt then
    startSeatbeltExitPreventionThread()
  end
end

if Config.EnableSeatbelt then
  lib.onCache("vehicle", onEnterVehicle)

  CreateThread(function()
    if cache.vehicle then
      onEnterVehicle(cache.vehicle)
    end
  end)
end

if Config.EnableSeatbelt and Config.SeatbeltKeybind then
  RegisterCommand("toggle_seatbelt", function()
    if useMstSeatbelt and exports["mst_seatbelt"] and exports["mst_seatbelt"].ToggleSeatbelt then
      exports["mst_seatbelt"]:ToggleSeatbelt()
    else
      ToggleSeatbelt(cache.vehicle, not IsSeatbeltOn)
    end
  end, false)

  RegisterKeyMapping("toggle_seatbelt", "Toggle vehicle seatbelt", "keyboard", Config.SeatbeltKeybind or "B")
end

if useMstSeatbelt then
  RegisterNetEvent('mst_seatbelt:client:toggleSeatbelt', function(seatbeltOn)
    IsSeatbeltOn = seatbeltOn
    LocalPlayer.state:set("seatbelt", seatbeltOn)
  end)

  CreateThread(function()
    Wait(500)
    if cache.vehicle and exports["mst_seatbelt"] and exports["mst_seatbelt"].HasSeatbelt then
      local currentState = exports["mst_seatbelt"]:HasSeatbelt()
      IsSeatbeltOn = currentState
      LocalPlayer.state:set("seatbelt", currentState)
    end
  end)
end
