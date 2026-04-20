Config = {}

--- 受注NPC（テスト座標）
Config.QuestNpc = {
    model = 's_m_m_scientist_01',
    coords = vec4(2994.6294, 3411.3999, 71.7132, 287.4185),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
}

--- 襲撃開始後に出す敵（1階用の仮配置。MLOに合わせて調整してください）
Config.EnemyPeds = {
    model = 's_m_y_blackops_02',
    weapon = `WEAPON_CARBINERIFLE`,
    spawns = {
        -- 外
        vec4(3442.1350, 3758.1909, 30.5139, 26.9659),
        vec4(3462.0437, 3788.4050, 30.4305, 153.6600),
        vec4(3495.8088, 3797.5249, 30.3487, 327.7495),
        vec4(3499.7529, 3764.9434, 29.9238, 352.1440),
        vec4(3513.2903, 3756.7581, 29.9614, 349.9216),
        vec4(3520.0310, 3809.7651, 30.4784, 92.3960),
        vec4(3531.0659, 3761.9294, 29.9328, 318.6608),
        vec4(3561.8550, 3767.6743, 29.9230, 104.2870),
        vec4(3599.3462, 3758.3396, 29.9228, 55.4017),
        vec4(3602.8591, 3793.2380, 30.0243, 97.9421),
        vec4(3591.0508, 3810.4565, 30.0351, 69.8752),
        vec4(3619.7832, 3795.8152, 29.3619, 48.9542),

        -- 1階
        vec4(3610.9504, 3727.8262, 29.6894, 322.7948),
        vec4(3623.6057, 3728.3069, 28.6902, 326.0906),
        vec4(3608.6646, 3744.2659, 28.6901, 189.8843),
        vec4(3608.4419, 3710.3164, 29.6894, 318.2642),
        vec4(3601.2478, 3707.1208, 29.6894, 319.1138),
        vec4(3600.7710, 3727.0823, 29.6894, 8.1025),
        vec4(3591.6860, 3718.4514, 29.6894, 135.0454),
        vec4(3584.5249, 3702.9736, 28.8319, 325.3415),
        vec4(3593.0835, 3691.9187, 28.8214, 229.2526),
    },
}

Config.Elevator = {
    from = vec3(3540.8457, 3675.9338, 28.1211),
    to = vec3(3540.8708, 3676.0520, 20.9755),
    radius = 3,
}

Config.DataTerminal = {
    coords = vec3(3522.2053, 3705.0037, 20.9918),
    radius = 1.5,
    stealDurationMs = 10000,
    rewardItem = 'humane_usb',
    rewardCount = 1,
}

Config.Exchange = {
    requiredItem = 'humane_usb',
    requiredCount = 1,
    rewardItem = 'black_money',
    rewardMin = 150000000,
    rewardMax = 250000000,
}

Config.Text = {
    targetAccept = 'ヒューメイン研究所襲撃を受注する',
    targetExchange = '盗んだデータを換金する',
    accepted = '襲撃を開始した。研究所内の敵を排除し、中にあるデータを手に入れろ。',
    busy = 'すでに襲撃が進行中だ。',
    elevatorUse = 'エレベータを使う',
    elevatorDone = 'エレベータで移動した。',
    stealData = 'データを盗む',
    stealingData = 'データを盗んでいます...',
    dataStolen = 'データの吸い出しに成功した。USBを入手した。\n発注者に渡すと報酬がもらえる。',
    dataAlreadyStolen = 'この襲撃ではすでにデータを盗んでいる。',
    dataNeedRaid = '先に襲撃を受注しろ。',
    dataFailed = 'データの盗取に失敗した。',
    dataAlreadyHasUsb = 'すでにUSBを所持している。',
    dataInventoryFull = 'インベントリの空きが足りない。',
    dataInvalidItem = 'USBアイテムが未登録です。管理者に連絡してください。',
    dataSystemError = 'システムエラーでデータ取得に失敗した。',
    exchangeNoUsb = 'USBデータがないため換金できない。',
    exchangeSuccess = '機密データを引き渡し、汚いお金 $%s を受け取った。',
    exchangeFailed = '換金に失敗した。',
}
