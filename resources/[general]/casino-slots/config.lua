Config = {}

-- スロット台の設置座標
Config.Slots = {
    { coords = vector3(929.32, 41.89, 71.17), heading = 0.0 },
    { coords = vector3(932.80, 41.89, 71.17), heading = 0.0 },
    { coords = vector3(936.28, 41.89, 71.17), heading = 0.0 },
    { coords = vector3(939.76, 41.89, 71.17), heading = 0.0 },
    { coords = vector3(943.24, 41.89, 71.17), heading = 0.0 },
    { coords = vector3(887.1205, 14.6115, 78.8951), heading = 0.0 },
}

-- E キーで操作できる距離（メートル）
Config.InteractDistance = 1.8

-- ── Prop ────────────────────────────────────────────────────────────────────
-- スロット台の Prop モデル名
-- 候補: 'prop_slot_mach_01'  'prop_slot_mach_02'
--       'hei_prop_casino_slot_a'  'hei_prop_casino_slot_b'
Config.PropModel = 'vw_prop_casino_slot_01a'

-- Prop の位置オフセット（ずれを微調整する場合に変更）
-- Config.PropOffset = vector3(0.0, 0.0, 0.0)

-- ── 賭け金 ──────────────────────────────────────────────────────────────────
Config.BetAmounts = { 1000000, 10000000 }

-- ── シンボル（weight が低いほどレア） ────────────────────────────────────────
Config.Symbols = {
    { id = 'cherry',  label = 'CHERRY',  char = '🍒', weight = 28 },
    { id = 'lemon',   label = 'LEMON',   char = '🍋', weight = 22 },
    { id = 'orange',  label = 'ORANGE',  char = '🍊', weight = 18 },
    { id = 'grape',   label = 'GRAPE',   char = '🍇', weight = 14 },
    { id = 'star',    label = 'STAR',    char = '⭐',  weight = 10 },
    { id = 'diamond', label = 'DIAMOND', char = '💎',  weight = 5  },
    { id = 'seven',   label = 'SEVEN',   char = '7',   weight = 3  },
}

-- ── 配当倍率 ─────────────────────────────────────────────────────────────────
Config.Payouts = {
    three_seven   = 100,
    three_diamond = 50,
    three_star    = 20,
    three_same    = 8,
    two_seven     = 5,
    two_diamond   = 3,
    two_same      = 2,
}

-- ── 確変（CHANCE MODE） ───────────────────────────────────────────────────────
Config.Chance = {
    enabled   = true,
    triggerOn = { 'jackpot', 'bigwin' }, -- どの当選で確変突入するか
    spins     = 10,                      -- 確変中のスピン数

    -- 確変中のシンボル重み（通常より高レア寄りに）
    symbolWeights = {
        cherry  = 14,
        lemon   = 12,
        orange  = 10,
        grape   = 9,
        star    = 20,   -- 通常10 → 20
        diamond = 18,   -- 通常5  → 18
        seven   = 15,   -- 通常3  → 15
    }
}

-- ── サウンド ──────────────────────────────────────────────────────────────────
-- type = 'gta' : GTA V 内部サウンド（set + name を指定）
--                  set = 'none' でサウンドセットなし
-- type = 'mp3' : 外部 MP3 ファイル（html/sounds/ フォルダに配置）
--                  file   = 'sounds/win.mp3'  ← html/ からの相対パス
--                  volume = 0.0 〜 1.0（省略時は 1.0）
Config.Sounds = {
    bet     = { type = 'mp3', file = 'sounds/bet.mp3', volume = 0.5 }, -- ベット時
    spin    = { type = 'mp3', file = 'sounds/spin.mp3', volume = 0.3 }, -- リール回転中（繰り返し）
    stop    = { type = 'mp3', file = 'sounds/stop.mp3', volume = 0.5 }, -- リール停止
    win     = { type = 'mp3', file = 'sounds/win.mp3', volume = 0.5 }, -- 小当たり
    bigwin  = { type = 'mp3', file = 'sounds/bigwin.mp3', volume = 0.5 }, -- 大当たり
    jackpot = { type = 'mp3', file = 'sounds/jackpot.mp3', volume = 0.5 }, -- ジャックポット
    lose    = { type = 'mp3', file = 'sounds/lose.mp3', volume = 0.5 }, -- ハズレ
    chance  = { type = 'mp3', file = 'sounds/chance.mp3', volume = 0.5 }, -- 確変突入

    -- MP3 使用例 (html/sounds/ にファイルを置いて該当行を置き換える):
    -- win     = { type = 'mp3', file = 'sounds/win.mp3',     volume = 0.9 },
    -- bigwin  = { type = 'mp3', file = 'sounds/bigwin.mp3',  volume = 1.0 },
    -- jackpot = { type = 'mp3', file = 'sounds/jackpot.mp3', volume = 1.0 },
    -- chance  = { type = 'mp3', file = 'sounds/chance.mp3',  volume = 1.0 },
}

-- スピン後のクールダウン（ミリ秒）
Config.SpinCooldown = 500

Config.Debug = false
