Config = {}

Config.Language = "ja"

Config.Debug = true

-- NPC 生成・E キー反応など「拠点として近い」とみなす距離（m）
Config.RenderDistance = 22.0
-- マーカーだけこの距離まで描画（遠くから返却地点が分かるように）。短いと近づかないと見えない
Config.MarkerDrawDistance = 120.0

-- 返却マーカー（車に乗って返却地点付近のとき）FiveM: 36 = MarkerType 車シンボル
Config.RentalReturnMarkerType = 36
Config.RentalReturnMarkerScale = vector3(1.2, 1.2, 1.2)

-- qb-vehiclekeys（vehiclekeys:client:SetOwner → AcquireVehicleKeys）
Config.GiveKeys = function(plate)
    if plate and plate ~= '' then
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
    end
end

-- 燃料: SetFuel(vehicle, 0–100) があるスクリプト名（例: cdn-fuel, LegacyFuel, ps-fuel）。不要なら false
Config.FuelResource = 'cdn-fuel'
Config.RentalFuelPercent = 100

function Config.ApplyRentalFuel(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    local res = Config.FuelResource
    if not res or res == '' or res == false then return end
    if GetResourceState(res) ~= 'started' then return end
    local level = tonumber(Config.RentalFuelPercent) or 100
    if level > 100 then level = 100 end
    if level < 0 then level = 0 end
    pcall(function()
        exports[res]:SetFuel(vehicle, level)
    end)
end

Config.Rental = {
    time = 1000, -- Max minutes a player can have the car out until they get no refund for returning it.
    plateFormat = "RNT ...", -- The plate format for rented cars. ( _ = Letter, . = Number )
    -- ナンバーの先頭が plateFormat の「ランダム前の固定部分」と一致する車をレンタル車とみなす
    crimeNoticeEnabled = true,
    crimeNoticeText = 'この車両は犯罪利用できません',
}

Config.Locations = {
    {
        title = "レンタル車両",
        blip = { -- Set to nil for no blip.
            label = "レンタル会社 (車両)",
            id = 225,
            scale = 0.85,
            color = 2,
            display = 4,
        },
        locations = {
            interact = {
                coords = vector3(-491.2607, -250.7301, 34.8),
                heading = 24.2280,
                ped = `ig_siemonyetarian` -- Set to nil to use markers.
            },
            spawn = {
                coords = vector3(-490.1074, -254.1345, 35.6566),
                heading = 291.9156
            },
        },
        -- 車両は resources/[vehicle]/scooter（vehicles.meta の gameName: gcscoot / carcols 同梱）を ensure してください
        vehicles = {
            {
                label = "スクーター",
                model = `gcscoot`,
                price = 75,
                groups = nil -- {["police"] = 4}
            },
        },
    },
}
