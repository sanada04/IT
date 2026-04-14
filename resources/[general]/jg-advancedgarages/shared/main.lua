Functions = {}

local configLocale = Config.Locale
if not configLocale then
    configLocale = "en"
end
Locale = Locales[configLocale]
if not Locale then
    print(("^3[jg-advancedgarages]^7 Locale '%s' not found, falling back to 'en'."):format(tostring(configLocale)))
    Locale = Locales["en"] or {}
end

Globals = {
    OutsideVehicles = {}
}
function debugPrint(message, logType, ...)
    if not Config.Debug then
        return
    end
    
    local prefix = "^2[DEBUG]^7"
    if logType == "warning" then
        prefix = "^3[WARNING]^7"
    end
    
    local args = {...}
    local output = ""
    
    for i = 1, #args do
        local argType = type(args[i])
        if argType == "table" then
            output = output .. json.encode(args[i])
        elseif argType ~= "string" then
            output = output .. tostring(args[i])
        else
            output = output .. args[i]
        end
        
        if i ~= #args then
            output = output .. " "
        end
    end
    
    print(prefix, message, output)
end
function setVehiclePlateText(vehicle, plateText)
    local advancedParkingState = GetResourceState("AdvancedParking")
    if advancedParkingState == "started" then
        exports.AdvancedParking:UpdatePlate(vehicle, plateText)
    else
        SetVehicleNumberPlateText(vehicle, plateText)
    end
end
function convertJSTimestamp(timestampString)
    local monthMap = {
        Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6,
        Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12
    }
    
    local pattern = "%a+%s+(%a+)%s+(%d+)%s+(%d+)%s+(%d+):(%d+):(%d+)"
    local month, day, year, hour, min, sec = timestampString:match(pattern)
    
    local dateTable = {
        year = tonumber(year),
        month = monthMap[month],
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    }
    
    return os.time(dateTable)
end
function convertModelToHash(model)
    local modelType = type(model)
    if modelType == "string" then
        local hash = joaat(model)
        if hash then
            return hash
        end
    end
    return model
end
function round(number, decimals)
    decimals = decimals or 0
    local multiplier = 10 ^ decimals
    return math.floor(number * multiplier + 0.5) / multiplier
end
function isItemInList(list, item)
    if #list == 0 then
        return false
    end
    
    for _, listItem in ipairs(list) do
        if listItem == item then
            return true
        end
    end
    
    return false
end
function isValidGTAPlate(plateText)
    if #plateText <= 8 then
        if plateText:match("^[%w%s]*$") then
            return true
        end
    end
    return false
end
function tableKeys(tableInput)
    local keys = {}
    for key, _ in pairs(tableInput) do
        keys[#keys + 1] = key
    end
    return keys
end
CreateThread(function()
    for modelName, label in pairs(Config.VehicleLabels) do
        Config.VehicleLabels[tostring(joaat(modelName))] = label
    end
end)
