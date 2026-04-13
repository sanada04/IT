Config = {}

-- 表示言語 "ja" = 日本語, "en" = English
Config.Locale = "ja"

-- NPC（宝商人）：金属探知機のレンタル・ランキング確認
Config.NPC = {
    model = "a_m_y_beach_01",
    coords = vector4(-1555, -1151, 2.4, 310),
    blip = {
        enabled = true,
        sprite = 478,
        color = 5,
        scale = 0.8,
        label = "金属探知 JOB"
    }
}

-- 金属探知機アイテム名（qb-core の items.lua と一致させる）
Config.MetalDetectorItem = "metal_detector"

-- アイテム必須か（false なら誰でも探知可能）
Config.RequireMetalDetector = true

-- 探知・掘削（スポットは見せず、音で近さを伝える）
Config.DetectDistance = 25.0      -- この距離内でビープが鳴り始める
Config.DigDistance = 1.5          -- この距離で掘れる（ビープが速い＝近い）
Config.DigDuration = 5000         -- 掘削時間（ミリ秒）
-- 掘削後クールダウンはなし（連続で掘れる）

-- 金属探知機のビープ音（距離が近いほど間隔が短く・大きくなる）
Config.BeepIntervalMin = 280     -- 検知圏内で近いときのビープ間隔（ミリ秒）
Config.BeepIntervalMax = 1800    -- 検知圏の端（遠い）ときのビープ間隔（ミリ秒）
Config.BeepIntervalVeryClose = 120  -- 掘れる距離内（超近い）のビープ間隔（より速く鳴る）
-- 「掘る」表示時に気づき用の音を1回鳴らす
Config.DigReadySound = true

-- プレイヤー周囲に表示する3D円（足元のリング）
Config.DetectorCircleRadius = 2.2  -- 円の半径（メートル）

-- 金属探知機使用時＝両手でタブレットを持っているモーション（探知ON時）
Config.DetectorProp = {
    model = "prop_cs_tablet",  -- タブレット
    bone = 18905,              -- 右手 SKEL_R_Hand（アニメが両手なので右手に付ける）
    offset = vector3(0.12, 0.0, -0.05),   -- 胸の前で両手で持つ位置
    rotation = vector3(-100.0, 0.0, 0.0),
    animDict = "missheistdockssetup1clipboard@base",  -- 両手でクリップボード持つポーズ（タブレットに流用）
    animName = "base",
    flag = 49,  -- ループ＋手を下げない
}

-- 報酬（サーバー側で参照）※ お金は付与しない。アイテム＋XP のみ
Config.Rewards = {
    rareChance = 0.15,
    rareItems = { "md_gold_bar", "md_treasure_gem", "md_broken_watch" },
    commonItems = { "md_metal_scrap", "md_plastic_scrap", "md_copper_scrap" }
}

-- 宝のランダム湧き（ゾーン内にランダムで出現。1回取ったら消えて別の場所に1つ湧く）
-- 中心はNPCの位置。zMin/zMax は「地面の高さ」に合わせること（低すぎると宝が地中になり埋もれて感じる）
Config.TreasureZone = {
    center = vector3(-1555, -1151, 2.4),   -- NPCの位置（NPC.coords の x,y,z に合わせる）
    radius = 50.0,   -- 半径（メートル）。NPCの周辺に宝が湧く
    zMin = 2.4,      -- 高さの下限（地面より少し下。center.z より 0.2 下程度）
    zMax = 2.4,      -- 高さの上限（地面と同じか少し上）。プレイヤーが立つ高さに合わせる
    -- マップに掘れる範囲を色付きで表示
    showOnMap = true,       -- true でマップに円を表示
    mapBlipColor = 2,       -- ブリップ色（0～85。5=イエロー、2=緑、1=赤 など）
    mapBlipAlpha = 80,      -- 円の透明度（0=透明 ～ 255=不透明）
}
Config.TreasureCount = 20   -- 同時に存在する宝の数（1つ取ると別の場所に1つ湧く）

-- ランキング表示数
Config.RankingLimit = 10

-- ランキングに表示する名前（街での名前）
-- charinfo のどのキーを優先するか。存在する順に使う。どれも無い場合は firstname + lastname
Config.RankingNameFields = { "streetname", "nickname", "displayname" }

-- 掘削で獲得するXP（取ったものに応じて変動）
Config.XPBase = 10              -- 掘るたびに必ずもらうXP
Config.XPRareBonus = 50         -- レアアイテムを出したときの追加XP
Config.XPMoneyBonus = 2         -- 獲得現金100ごとの追加XP（例: 200$ → +4 XP）

-- 宝商人ショップ：金属探知機の購入価格
Config.Shop = {
    metalDetectorPrice = 0,
}

-- 売却可能アイテムと買取価格（1個あたり min～max の間でランダム。複数売却時も1個ごとにランダム）
Config.SellItems = {
    md_gold_bar = { min = 300000, max = 400000 },
    md_treasure_gem = { min = 150000, max = 250000 },
    md_broken_watch = { min = 250000, max = 350000 },
    md_metal_scrap = { min = 100000, max = 200000 },
    md_plastic_scrap = { min = 5000, max = 15000 },
    md_copper_scrap = { min = 15000, max = 25000 },
}

-- デバッグ（スポットをマーカー表示）
Config.Debug = false
