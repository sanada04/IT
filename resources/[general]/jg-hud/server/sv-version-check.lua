local resourceName = "jg-hud"
local versionUrl = "https://raw.githubusercontent.com/jgscripts/versions/main/" .. resourceName .. ".txt"

-- Compare two semantic versions (e.g., "1.2.3" vs "1.2.4")
local function compareVersions(currentVersion, latestVersion)
  local currentParts = {}
  local latestParts = {}
  
  -- Parse current version into parts
  for part in string.gmatch(currentVersion, "[^.]+") do
    table.insert(currentParts, tonumber(part))
  end
  -- Parse latest version into parts
  for part in string.gmatch(latestVersion, "[^.]+") do
    table.insert(latestParts, tonumber(part))
  end
  
  -- Compare each part
  local maxLength = math.max(#currentParts, #latestParts)
  for i = 1, maxLength do
    local currentPart = currentParts[i] or 0
    local latestPart = latestParts[i] or 0
    
    if currentPart < latestPart then
      return true  -- Update available
    end
  end
  
  return false  -- Already on latest
end

-- Check GitHub for latest version
PerformHttpRequest(versionUrl, function(statusCode, response, headers)
  if statusCode ~= 200 then
    print("^1Unable to perform update check")
    return
  end
  
  local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
  if not currentVersion then
    return
  end
  
  -- Skip check for dev versions
  if currentVersion == "dev" then
    print("^3Using dev version")
    return
  end
  
  -- Extract version from response
  local latestVersion = response:match("^[^\n]+")
  if not latestVersion then
    return
  end
  
  -- Compare versions (skip first character 'v' if present)
  local currentVer = currentVersion:sub(2)
  local latestVer = latestVersion:sub(2)
  
  if compareVersions(currentVer, latestVer) then
    print("^3Update available for " .. resourceName .. "! (current: ^1" .. currentVersion .. "^3, latest: ^2" .. latestVersion .. "^3)")
    print("^3Release notes: discord.gg/jgscripts")
  end
end, "GET")
-- Check artifact version for known issues
CreateThread(function()
  local version = GetConvar("version", "unknown")
  local artifactVersion = string.match(version, "v%d+%.%d+%.%d+%.(%d+)")
  
  local artifactUrl = "https://artifacts.jgscripts.com/check?artifact=" .. artifactVersion
  
  PerformHttpRequest(artifactUrl, function(statusCode, response, headers, errorCode)
    if statusCode ~= 200 or errorCode then
      print("^1Could not check artifact version^0")
      return
    end
    
    if not response then
      return
    end
    
    local data = json.decode(response)
    
    if data.status == "BROKEN" then
      print("^1WARNING: The current FXServer version you are using (artifacts version) has known issues. Please update to the latest stable artifacts: https://artifacts.jgscripts.com^0")
      print("^0Artifact version:^3 " .. artifactVersion .. "\n^0Known issues:^3 " .. data.reason .. "^0")
      return
    end
end)
end)
