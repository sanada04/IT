Config = Config or {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.Locale = "ja"

Config.AvailableJobs = {                                     -- Only used when not using qb-jobs.
    ['trucker'] = { ['label'] = 'トラックドライバー', ['isManaged'] = false },
    ['taxi'] = { ['label'] = 'タクシー運転手', ['isManaged'] = false },
    ['tow'] = { ['label'] = 'レッカー運転手', ['isManaged'] = false },
    ['reporter'] = { ['label'] = '記者', ['isManaged'] = false },
    ['garbage'] = { ['label'] = '清掃員', ['isManaged'] = false },
    ['bus'] = { ['label'] = 'バス運転手', ['isManaged'] = false },
    ['hotdog'] = { ['label'] = 'ホットドッグ屋台', ['isManaged'] = false }
}

Config.Cityhalls = {
    { -- Cityhall 1
        coords = vec3(-550.4013, -192.7052, 38.2193),
        showBlip = true,
        blipData = {
            sprite = 487,
            display = 4,
            scale = 0.8,
            colour = 0,
            title = '市役所'
        },
        licenses = {
            ['id_card'] = {
                label = '身分証明書',
                cost = 10000,
            },
            ['driver_license'] = {
                label = '運転免許証',
                cost = 10000,
                metadata = 'driver'
            },
        }
    },
}

Config.DrivingSchools = {
    { -- Driving School 1
        coords = vec3(240.3, -1379.89, 33.74),
        showBlip = true,
        blipData = {
            sprite = 225,
            display = 4,
            scale = 0.65,
            colour = 3,
            title = 'Driving School'
        },
        instructors = {
            'DJD56142',
            'DXT09752',
            'SRI85140',
        }
    },
}

Config.Peds = {
    -- Cityhall Ped
    {
        model = 'a_m_m_hasjew_01',
        coords = vec4(-550.4013, -192.7052, 37.22, 204.7302),
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        cityhall = true,
        zoneOptions = { -- Used for when UseTarget is false
            length = 3.0,
            width = 3.0,
            debugPoly = false
        }
    },
    -- Driving School Ped
    {
        model = 'a_m_m_eastsa_02',
        coords = vec4(240.91, -1379.2, 32.74, 138.96),
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        drivingschool = true,
        zoneOptions = { -- Used for when UseTarget is false
            length = 3.0,
            width = 3.0
        }
    }
}
