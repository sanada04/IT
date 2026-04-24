Config = {}

-- マーカー共通設定
Config.MarkerType = 1
Config.MarkerSize  = vector3(2.5, 2.5, 0.5)

-- プレビュー用カメラ設定
Config.PreviewCameraRadius = 5.5
Config.PreviewCameraHeight = 1.8
Config.PreviewCameraFOV    = 50.0
Config.PreviewRotateSpeed  = 0.35
Config.PreviewSpawn        = vector4(-75.2854, -819.1025, 326.1750, 0.0) -- 全体デフォルト（ショップ個別指定が無い場合のみ使用）

-- 購入車両の初期保管先（qb-garages の garage 名）
Config.DefaultGarage = 'pillboxgarage'
Config.ShopGarages = {
    normal = 'pillboxgarage',
    luxury = 'pillboxgarage',
}

-- ===== ショップ定義 =====
Config.Shops = {
    {
        id    = 'normal',
        label = '普通車ディーラー',
        coords = vector4(-47.4, -1104.8, 26.4, 335.0),
        purchaseSpawn = vector4(-14.6993, -1098.1191, 26.6762, 158.3191), -- 購入時スポーン座標
        previewSpawn = vector4(-75.2854, -819.1025, 326.1750, 0.0), -- 普通車ディーラーの3Dプレビュー座標
        blip = {
            sprite = 326,
            color  = 3,    -- 青
            scale  = 0.7,
        },
        markerColor = { r = 30, g = 144, b = 255, a = 180 },
        -- このショップで表示するカテゴリー（allは必須）
        categories = { 'all', 'compact', 'sedan', 'suv', 'sports', 'muscle', 'truck', 'van' },
    },
    {
        id    = 'luxury',
        label = '高級車ディーラー',
        -- ※ 座標はサーバーに合わせて変更してください
        coords = vector4(-1254.4291, -349.7122, 36.9075, 296.0078),
        purchaseSpawn = vector4(-1234.4775, -346.1918, 37.3328, 24.9227), -- 購入時スポーン座標
        previewSpawn = vector4(-1237.4441, -350.9486, 37.3328, 353.1113), -- 高級車ディーラーの3Dプレビュー座標
        blip = {
            sprite = 523,
            color  = 46,   -- 金
            scale  = 0.7,
        },
        markerColor = { r = 220, g = 165, b = 0, a = 180 },
        categories = { 'all', 'luxury', 'gt', 'supercar' },
    },
}

-- ===== カテゴリー定義（全ショップ共通） =====
Config.Categories = {
    { id = 'all',      label = '全車種',         icon = 'ALL' },
    -- 普通車ディーラー用
    { id = 'compact',  label = '軽自動車',       icon = 'KEI' },
    { id = 'sedan',    label = 'セダン',         icon = 'SDN' },
    { id = 'suv',      label = 'SUV',            icon = 'SUV' },
    { id = 'sports',   label = 'スポーツ',       icon = 'SPT' },
    { id = 'muscle',   label = 'マッスル',       icon = 'MSL' },
    { id = 'truck',    label = 'トラック',       icon = 'TRK' },
    { id = 'van',      label = 'バン',           icon = 'VAN' },
    -- 高級車ディーラー用
    { id = 'luxury',   label = 'ラグジュアリー', icon = 'LUX' },
    { id = 'gt',       label = 'グランツーリスモ',icon = 'GT'  },
    { id = 'supercar', label = 'スーパーカー',   icon = 'SUP' },
}

-- ===== 車両リスト =====
-- shop = 'normal'  → 普通車ディーラー
-- shop = 'luxury'  → 高級車ディーラー
Config.Vehicles = {

    -- ==============================
    -- 普通車ディーラー
    -- ==============================

    -- 軽自動車
    { model = 'asbo',    label = 'Karin Asbo',         price = 280000,  category = 'compact', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/asbo.webp',
      stats = { speed = 55, accel = 50, brake = 60, handling = 58 } },
    { model = 'issi2',   label = 'Weeny Issi Classic', price = 320000,  category = 'compact', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/issi2.webp',
      stats = { speed = 58, accel = 55, brake = 62, handling = 65 } },
    { model = 'prairie', label = 'Declasse Prairie',   price = 260000,  category = 'compact', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/prairie.webp',
      stats = { speed = 50, accel = 45, brake = 58, handling = 55 } },

    -- セダン
    { model = 'asea',     label = 'Karin Asea',     price = 450000, category = 'sedan', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/asea.webp',
      stats = { speed = 65, accel = 62, brake = 65, handling = 68 } },
    { model = 'fugitive', label = 'Vapid Fugitive', price = 520000, category = 'sedan', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/fugitive.webp',
      stats = { speed = 68, accel = 65, brake = 68, handling = 70 } },
    { model = 'primo',    label = 'Albany Primo',   price = 380000, category = 'sedan', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/primo.webp',
      stats = { speed = 60, accel = 55, brake = 62, handling = 60 } },
    { model = 'stanier',  label = 'Vapid Stanier',  price = 420000, category = 'sedan', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/stanier.webp',
      stats = { speed = 62, accel = 58, brake = 64, handling = 62 } },

    -- SUV
    { model = 'baller',    label = 'Gallivanter Baller', price = 850000, category = 'suv', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/baller.webp',
      stats = { speed = 72, accel = 68, brake = 65, handling = 60 } },
    { model = 'granger',   label = 'Declasse Granger',   price = 780000, category = 'suv', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/granger.webp',
      stats = { speed = 70, accel = 65, brake = 65, handling = 62 } },
    { model = 'cavalcade', label = 'Albany Cavalcade',   price = 920000, category = 'suv', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/cavalcade.webp',
      stats = { speed = 73, accel = 70, brake = 66, handling = 63 } },
    { model = 'fq2',       label = 'Benefactor FQ 2',    price = 680000, category = 'suv', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/fq2.webp',
      stats = { speed = 68, accel = 64, brake = 65, handling = 66 } },

    -- スポーツ
    { model = 'sultan', label = 'Karin Sultan',         price = 1200000, category = 'sports', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/sultan.webp',
      stats = { speed = 82, accel = 80, brake = 78, handling = 85 } },
    { model = 'jester', label = 'Dinka Jester Classic', price = 1450000, category = 'sports', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/jester.webp',
      stats = { speed = 85, accel = 83, brake = 80, handling = 82 } },

    -- マッスル
    { model = 'dominator', label = 'Vapid Dominator',  price = 980000, category = 'muscle', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/dominator.webp',
      stats = { speed = 80, accel = 82, brake = 72, handling = 70 } },
    { model = 'gauntlet',  label = 'Bravado Gauntlet', price = 950000, category = 'muscle', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/gauntlet.webp',
      stats = { speed = 79, accel = 80, brake = 71, handling = 68 } },
    { model = 'vigero',    label = 'Declasse Vigero',  price = 820000, category = 'muscle', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/vigero.webp',
      stats = { speed = 76, accel = 78, brake = 70, handling = 65 } },

    -- トラック
    { model = 'bison',     label = 'Vapid Bison',        price = 650000, category = 'truck', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/bison.webp',
      stats = { speed = 62, accel = 60, brake = 58, handling = 55 } },
    { model = 'sandking2', label = 'Vapid Sandking SWB', price = 900000, category = 'truck', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/sandking2.webp',
      stats = { speed = 68, accel = 65, brake = 60, handling = 58 } },
    { model = 'rebel2',    label = 'Canis Rebel',         price = 780000, category = 'truck', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/rebel2.webp',
      stats = { speed = 65, accel = 63, brake = 59, handling = 56 } },

    -- バン
    { model = 'minivan', label = 'Declasse Minivan', price = 550000, category = 'van', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/minivan.webp',
      stats = { speed = 60, accel = 55, brake = 60, handling = 55 } },
    { model = 'rumpo',   label = 'Bravado Rumpo',    price = 480000, category = 'van', shop = 'normal',
      img = 'https://docs.fivem.net/vehicles/rumpo.webp',
      stats = { speed = 58, accel = 52, brake = 58, handling = 53 } },

    -- ==============================
    -- 高級車ディーラー
    -- ==============================

    -- ラグジュアリー（高級セダン・エグゼクティブ）
    { model = 'cognoscenti', label = 'Enus Cognoscenti',        price = 2800000, category = 'luxury', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/cognoscenti.webp',
      stats = { speed = 72, accel = 68, brake = 72, handling = 74 } },
    { model = 'schafter2',   label = 'Benefactor Schafter V12', price = 1850000, category = 'luxury', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/schafter2.webp',
      stats = { speed = 75, accel = 72, brake = 74, handling = 76 } },
    { model = 'felon',       label = 'Lampadati Felon',         price = 1600000, category = 'luxury', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/felon.webp',
      stats = { speed = 70, accel = 68, brake = 71, handling = 72 } },
    { model = 'exemplar',    label = 'Dewbauchee Exemplar',     price = 2200000, category = 'luxury', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/exemplar.webp',
      stats = { speed = 76, accel = 74, brake = 73, handling = 78 } },

    -- グランツーリスモ（高性能GT）
    { model = 'comet2',    label = 'Pfister Comet',          price = 3200000, category = 'gt', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/comet2.webp',
      stats = { speed = 87, accel = 85, brake = 82, handling = 88 } },
    { model = 'zr380',     label = 'Annis ZR380',            price = 3800000, category = 'gt', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/zr380.webp',
      stats = { speed = 88, accel = 86, brake = 83, handling = 87 } },
    { model = 'schwarzer', label = 'Benefactor Schwartzer',  price = 2900000, category = 'gt', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/schwarzer.webp',
      stats = { speed = 84, accel = 82, brake = 80, handling = 84 } },
    { model = 'feltzer3',  label = 'Benefactor Feltzer',     price = 2600000, category = 'gt', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/feltzer3.webp',
      stats = { speed = 83, accel = 81, brake = 80, handling = 83 } },

    -- スーパーカー
    { model = 'entityxf', label = 'Overflod Entity XF', price = 7500000, category = 'supercar', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/entityxf.webp',
      stats = { speed = 97, accel = 95, brake = 90, handling = 92 } },
    { model = 'adder',    label = 'Truffade Adder',     price = 8200000, category = 'supercar', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/adder.webp',
      stats = { speed = 99, accel = 96, brake = 88, handling = 90 } },
    { model = 'zentorno', label = 'Pegassi Zentorno',   price = 7200000, category = 'supercar', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/zentorno.webp',
      stats = { speed = 96, accel = 95, brake = 90, handling = 93 } },
    { model = 'osiris',   label = 'Pegassi Osiris',     price = 6500000, category = 'supercar', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/osiris.webp',
      stats = { speed = 95, accel = 94, brake = 91, handling = 92 } },
    { model = 'reaper',   label = 'Dewbauchee Reaper',  price = 7800000, category = 'supercar', shop = 'luxury',
      img = 'https://docs.fivem.net/vehicles/reaper.webp',
      stats = { speed = 98, accel = 96, brake = 92, handling = 94 } },
}
