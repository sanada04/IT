Config = {}

-- Sandy Shores Airfield — large flat open area for the mission
Config.MissionArea   = vector3(1750.0, 3280.0, 41.5)
Config.MaxPartySize  = 8

Config.Difficulties = {
    easy   = { label = 'イージー',    waves = 3,  perWave = 5,  health = 150,  armor = 0,   ufos = 1 },
    normal = { label = 'ノーマル',   waves = 5,  perWave = 10, health = 300,  armor = 50,  ufos = 2 },
    hard   = { label = 'ハード',     waves = 7,  perWave = 25, health = 600,  armor = 100, ufos = 2 },
    extra  = { label = 'エクストラ', waves = 10, perWave = 50, health = 1200, armor = 200, ufos = 3 },
}

-- エイリアン敵モデル（ロードできなかった場合は次を試す）
Config.EnemyModels = {
    'u_m_y_alien',      -- GTA Vエイリアン (メイン)
    'g_m_y_armour_01',  -- フォールバック
    's_m_y_marine_01',  -- フォールバック
}

Config.PlayerWeapons = {
    { name = 'WEAPON_ASSAULTRIFLE', ammo = 999 },
    { name = 'WEAPON_PUMPSHOTGUN',  ammo = 300 },
    { name = 'WEAPON_PISTOL50',     ammo = 999 },
    { name = 'WEAPON_RPG',          ammo = 10  },
    { name = 'WEAPON_SNIPERRIFLE',  ammo = 150 },
}

-- UFO hover positions (offsets from mission center)
Config.UfoOffsets = {
    { x =  0,   y =  60, z = 85 },
    { x = -70,  y = -40, z = 90 },
    { x =  70,  y = -40, z = 88 },
}

-- Enemy spawn ring (offsets from mission center, ground level)
Config.EnemyDropOffsets = {
    { x =  0,   y =  55 },
    { x = -35,  y =  40 },
    { x =  35,  y =  40 },
    { x = -55,  y =   0 },
    { x =  55,  y =   0 },
    { x = -35,  y = -40 },
    { x =  35,  y = -40 },
    { x =   0,  y = -55 },
    { x = -20,  y =  55 },
    { x =  20,  y =  55 },
    { x = -20,  y = -55 },
    { x =  20,  y = -55 },
}

-- Health pack positions (offsets from mission center)
Config.HealthPackOffsets = {
    { x =  0,  y =  0  },
    { x =  20, y =  0  },
    { x = -20, y =  0  },
    { x =  0,  y =  20 },
    { x =  0,  y = -20 },
    { x =  25, y =  25 },
    { x = -25, y = -25 },
}

-- Player teleport offsets (up to 8 players)
Config.PlayerSpawnOffsets = {
    { x =  5,  y =  0  },
    { x = -5,  y =  0  },
    { x =  0,  y =  5  },
    { x =  0,  y = -5  },
    { x =  7,  y =  7  },
    { x = -7,  y =  7  },
    { x =  7,  y = -7  },
    { x = -7,  y = -7  },
}

Config.HealthPackModel           = 'prop_ld_health_pack'
Config.HealthPackDistance        = 2.5
Config.HealthPackFloatHeight     = 0.5   -- 地面から浮かせる高さ (m)
Config.HealthPackRespawnInterval = 30    -- 回復パック再出現までの秒数
Config.HealthPackMax             = 7     -- 同時存在できる最大個数

Config.WaveStartDelay   = 2000   -- ms from mission start to first wave announce
Config.WaveClearDelay   = 1000   -- ms after last kill before next wave announce
Config.CountdownSeconds = 3      -- countdown before each wave spawns

-- NPC quest giver
Config.NpcCoords       = vector4(-273.2987, -1918.9829, 29.9461, 319.5805)
Config.NpcModel        = 's_m_m_marine_01'
Config.NpcInteractDist = 2.5

-- Invite radius (m) and timeout (s)
Config.InviteRadius  = 15.0
Config.InviteTimeout = 20
