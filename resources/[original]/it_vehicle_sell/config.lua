Config = {}

-- 売却場所の座標（プレイヤーが近づいてEキーで開く）
Config.SellLocation  = vector3(-33.0005, -1086.4193, 26.4222)
Config.InteractRange = 2.5

-- 売却代金の受け取り方法: 'bank' or 'cash'
Config.PaymentType = 'bank'

-- 売却価格 = 市場価格 × この値（1/3 固定）
Config.SellPriceRate = 1 / 3

-- NPC 設定
Config.Ped = {
    model    = 's_m_m_autoshop_01',
    heading  = 155.0,
    scenario = 'WORLD_HUMAN_CLIPBOARD',
}

-- ブリップ設定
Config.Blip = {
    show   = true,
    sprite = 225,  -- Car dealer icon
    color  = 5,    -- Yellow
    scale  = 0.7,
    label  = '中古車売却',
}
