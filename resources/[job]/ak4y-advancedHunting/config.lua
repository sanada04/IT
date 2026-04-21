-- ak4y dev.

-- IF YOU HAVE ANY PROBLEM OR DO YOU NEED HELP PLS COME TO MY DISCORD SERVER AND CREATE A TICKET
-- IF YOU DONT HAVE ANY PROBLEM YET AGAIN COME TO MY DISCORD :)
-- https://discord.gg/kWwM3Bx

AK4Y = {}

AK4Y.Framework = "qb" -- qb / oldqb | qb = export system | oldqb = triggerevent system
AK4Y.Mysql = "oxmysql" -- Check fxmanifest.lua when you change it! | ghmattimysql / oxmysql / mysql-async

AK4Y.UpdateXP = {min = 5, max = 10} --How many xp do you want to increase for collection
AK4Y.MaxLevel = 15
AK4Y.TaskResetPeriod = 1 -- DAY
AK4Y.PaymentMethod = "cash" -- "cash" or "bank"
AK4Y.NeededEXP = 1000 -- for level up
AK4Y.OnlyShootInZone = true

AK4Y.NPCAreas = {
    {
        pedName = "AKAY", 
        pedHash = 0x1EEC7BDC, 
        pedCoord = vector3(-679.14, 5834.51, 16.33), 
        drawText = "[E] - Hunting NPC",
        h = 132.41,
        blipSettings = { -- https://docs.fivem.net/docs/game-references/blips/
            blip = true,
            blipName = "Hunting NPC",
            blipIcon = 154,
            blipColour = 1,
        },
    }, 
}

AK4Y.WikiPage = {
    {
        starCount = 1, -- max 5
        areaTitle = "POULTRY",
        areaMiniTitle = "CHICKEN FARMING",
        areaDescription = "In this area; you can catch chickens. A good introduction to hunting!",
        allowedWeapons = {
            "-",
        },
        animals = {
            "CHICKEN"
        },
        areaCoords = vector3(1447.7864, 1066.3145, 114.33869),
        areaImage = "./images/chickenArea.png",
    },
    {
        starCount = 3, -- max 5
        areaTitle = "PIG HUNTER",
        areaMiniTitle = "Killer of pigs",
        areaDescription = "The next hunting point after poultry :D, Their meat is of high quality. It's a good profit!",
        allowedWeapons = {
            "KNIFE",
            "HUNTING RIFLE",
        },
        animals = {
            "PIG"
        },
        areaCoords = vector3(3681.69, 4520.4, 23.64),
        areaImage = "./images/area_1.png",
    },
    {
        starCount = 5, -- max 5
        areaTitle = "DEER HUNTING",
        areaMiniTitle = "The Last Point",
        areaDescription = "The ultimate in hunting! If you can catch something here, you're a real hunter! ",
        allowedWeapons = {
            "KNIFE",
            "HUNTING RIFLE",
        },
        animals = {
            "DEER"
        },
        areaCoords = vector3(-543.85, 5524.41, 61.03),
        areaImage = "./images/deerArea.png",
    },
}

AK4Y.MarketPage = {
    {
        uniqueId = 1,
        itemLabel = "HUNTING RIFLE",
        itemName = "weapon_sniperrifle",
        itemType = "item", -- item or weapon
        itemCount = 1,
        itemPrice = 500,
        itemImage = "./images/shotgunItem.png",
    },
    {
        uniqueId = 2,
        itemLabel = "HUNTING KNIFE",
        itemName = "hunting_knife",
        itemType = "item", -- item or weapon
        itemCount = 1,
        itemPrice = 100,
        itemImage = "./images/HuntingKnife.png",
    },
    {
        uniqueId = 3,
        itemLabel = "Poor Quality Deer Bait",
        itemName = "deer_bait",
        itemType = "item", -- item or weapon
        itemCount = 1,
        itemPrice = 10,
        itemImage = "./images/lowDeerBait.png",
    },
    {
        uniqueId = 4,
        itemLabel = "High Quality Deer Bait",
        itemName = "deer_bait2",
        itemType = "item", -- item or weapon
        itemCount = 1,
        itemPrice = 15,
        itemImage = "./images/highDeerBait.png",
    },
    {
        uniqueId = 5,
        itemLabel = "Poor Quality Pig Bait",
        itemName = "pig_bait",
        itemType = "item", -- item or weapon
        itemCount = 1,
        itemPrice = 7,
        itemImage = "./images/lowPigBait.png",
    },
    {
        uniqueId = 6,
        itemLabel = "High Quality Pig Bait",
        itemName = "pig_bait2",
        itemType = "item", -- item or weapon
        itemCount = 1,
        itemPrice = 9,
        itemImage = "./images/highPigBait.png",
    },
}

AK4Y.SellItems = {
    {
        uniqueId = 1,
        itemLabel = "Poor Quality Deer Meat",
        itemName = "deer_meat",
        itemStar = 4, -- MAX 5
        itemPrice = 200,
        itemImage = "./images/lowDeerMeat.png",
    },
    {
        uniqueId = 2,
        itemLabel = "High Quality Deer Meat",
        itemName = "deer_meat2",
        itemStar = 5, -- MAX 5
        itemPrice = 290,
        itemImage = "./images/highDeerMeat.png",
    },
    {
        uniqueId = 3,
        itemLabel = "Poor Quality Pig Meat",
        itemName = "pig_meat",
        itemStar = 2, -- MAX 5
        itemPrice = 120,
        itemImage = "./images/lowPigMeat.png",
    },
    {
        uniqueId = 4,
        itemLabel = "High Quality Pig Meat",
        itemName = "pig_meat2",
        itemStar = 3, -- MAX 5
        itemPrice = 170,
        itemImage = "./images/highPigMeat.png",
    },
    {
        uniqueId = 5,
        itemLabel = "Poor Quality Chicken Meat",
        itemName = "chicken_meat",
        itemStar = 0, -- MAX 5
        itemPrice = 40,
        itemImage = "./images/lowChickenMeat.png",
    },
    {
        uniqueId = 6,
        itemLabel = "High Quality Chicken Meat",
        itemName = "chicken_meat2",
        itemStar = 1, -- MAX 5
        itemPrice = 55,
        itemImage = "./images/highChickenMeat.png",
    },
}

AK4Y.Tasks = {
    {
        taskId = 1,
        taskTitle = "Cath 10 Chicken",
        taskDescription = "Cath 10 chicken and earn xp",
        rewardPrice = 10000,
        requiredCount = 10,
    },
    {
        taskId = 2,
        taskTitle = "Cut 10 Pig",
        taskDescription = "Cut 10 pig and earn xp",
        rewardPrice = 10000,
        requiredCount = 10,
    },
    {
        taskId = 3,
        taskTitle = "Cut 10 Deer",
        taskDescription = "Cut 10 deer and earn xp",
        rewardPrice = 10000,
        requiredCount = 10,
    },
    {
        taskId = 4,
        taskTitle = "Place 10 Pig Bait",
        taskDescription = "Place 10 pig bait and earn xp",
        rewardPrice = 10000,
        requiredCount = 10,
    },
    {
        taskId = 5,
        taskTitle = "Place 10 Deer Bait",
        taskDescription = "Place 10 deer bait and earn xp",
        rewardPrice = 10000,
        requiredCount = 10,
    },
    {
        taskId = 6,
        taskTitle = "Find 10 Rare Chicken Meat",
        taskDescription = "Find 10 rare chicken meat and earn xp",
        rewardPrice = 10000,
        requiredCount = 10,
    },
    {
        taskId = 7,
        taskTitle = "Find 10 Rare Pig Meat",
        taskDescription = "Find 10 rare chicken meat and earn xp",
        rewardPrice = 10000,
        requiredCount = 10,
    },
    {
        taskId = 8,
        taskTitle = "Find 10 Rare Deer Meat",
        taskDescription = "Find 10 rare chicken meat and earn xp",
        rewardPrice = 10000,
        requiredCount = 10,
    },
}

AK4Y.LevelPackages = {}


function NOTIFY(message)
    QBCore.Functions.Notify(message)
end

function PlaceBait(baittype)
    -- baittype return placed bait type
    if baittype == "a_c_pig" then
        TriggerServerEvent('ak4y-advancedHunting:taskCountAdd', 4, 1)
    elseif baittype == "a_c_deer" then
        TriggerServerEvent('ak4y-advancedHunting:taskCountAdd', 5, 1)
    end
end

function CutAnimal(animal)
    -- animal return cutted animal hash
    if animal == 1794449327 then
        TriggerServerEvent('ak4y-advancedHunting:taskCountAdd', 1, 1)
    elseif animal == -1323586730 then
        TriggerServerEvent('ak4y-advancedHunting:taskCountAdd', 2, 1)
    elseif animal == -664053099 then
        TriggerServerEvent('ak4y-advancedHunting:taskCountAdd', 3, 1)
    end
end

function EarnRareItem(animal)
    -- animal return earned rare item animal hash
    if animal == 1794449327 then
        TriggerServerEvent('ak4y-advancedHunting:taskCountAdd', 6, 1)
    elseif animal == -1323586730 then
        TriggerServerEvent('ak4y-advancedHunting:taskCountAdd', 7, 1)
    elseif animal == -664053099 then
        TriggerServerEvent('ak4y-advancedHunting:taskCountAdd', 8, 1)
    end
end

AK4Y.UnlimitedAmmoWeapons = {
    ["weapon_sniperrifle"] = true,
}

AK4Y.HuntLocations = {
    ["a_c_deer"] = {
        location = vector3(-543.85, 5524.41, 61.03),
        radius = 100.0,
        blipactive = true,
        blipColour = 1,
        blipAlpha = 50,
        BlipName = "Hunt Zone",
        BlipSprite = 141,
        BlipScale = 1.0,
        NeededLevel = 7,
        ["Allowed Weapons"] = {
            "weapon_sniperrifle",
        },
    },
    ["a_c_pig"] = {
        location = vector3(3681.69, 4520.4, 23.64),
        radius = 100.0,
        blipactive = true,
        blipColour = 1,
        BlipName = "Hunt Zone",
        BlipSprite = 141,
        BlipScale = 1.0,
        NeededLevel = 4,
        ["Allowed Weapons"] = {
            "weapon_sniperrifle",
        },
    },
}

-- 餌が使えない環境向けフォールバック（鹿/豚をゾーン内で自然スポーン）
AK4Y.AutoSpawnNoBait = {
    enabled = true,
    cooldownMs = 60000, -- 同一動物タイプの次スポーンまでの待機
}

AK4Y.CatchChicken = {
    location = vector3(1447.7864, 1066.3145, 114.33869),
    radius = 100.0,
    NeededLevel = 1, -- 鶏エサ / ニワトリエリア用（HuntLocations に a_c_hen が無いため）
    blipactive = true,
    blipColour = 1,
    blipAlpha = 50,
    BlipName = "Cath Chicken",
    BlipSprite = 141,
    BlipScale = 1.0,
}

AK4Y.AimBlockWeapons = {
    ["weapon_sniperrifle"] = true,
    ["weapon_pistol"] = true
}

AK4Y.AnimalItems = {
    ["a_c_deer"] = {
        hash = -664053099,
        BasicItem = "deer_meat",
        RareItem = "deer_meat2",
    },
    ["a_c_pig"] = {
        hash = -1323586730,
        BasicItem = "pig_meat",
        RareItem = "pig_meat2",
    },
    ["a_c_hen"] = {
        hash = 1794449327,
        BasicItem = "chicken_meat",
        RareItem = "chicken_meat2",
    },
}

AK4Y.ProgressTime = {
    ["a_c_deer"] = 10000,
    ["a_c_pig"] = 10000,
    ["a_c_hen"] = 10000,
    ["place_bait"] = 10000,
}

AK4Y.Languages = { --All notifications etc.
    ["bait_placed"] = "エサを設置しました",
    ["not_in_zone_bait"] = "このエサの設置可能エリアではありません",
    ["not_in_zone"] = "このエリアではありません",
    ["wait"] = "次のエサを置くまで少し待ってください",
    ["far_from_animal"] = "動物から離れすぎています",
    ["player_in_close"] = "近くにプレイヤーがいるため実行できません",
    ["cut_animal"] = "動物を解体しています",
    ["cancel"] = "キャンセルしました",
    ["shredded_meat"] = "肉がボロボロになってしまった",
    ["cant_cut_this_animal"] = "この動物は解体できません",
    ["not_look_animal"] = "動物を見ていません",
    ["you_couldnt_catch"] = "捕まえられませんでした",
    ["need_level"] = "この動物を狩るにはレベルが足りません",
    ["cath_chicken"] = "[E] ニワトリを捕まえる",
    ["spam"] = "連打しないでください",
    ["cant_shoot_out_of_zone"] = "エリア外では射撃できません",
    ["refill_ammo_in_zone"] = "エリアに入ると弾薬が補充されます",
}

AK4Y.HTMLTranslate = {
    ["generalTitleDescription"] = "狩りで経験値を稼ぎ、装備を整えて、より高レベルの獲物に挑戦しましょう。",
    ["wiki"] = "ガイド",
    ["market"] = "ショップ",
    ["sales"] = "売却",
    ["tasks"] = "タスク",
    ["lvlBuy"] = "レベル購入",
    ["weapon"] = "武器",
    ["animals"] = "動物",
    ["exp"] = "EXP",
    ["chicken"] = "ニワトリ",
    ["chickenDescriptionProgressBar"] = "ニワトリを捕まえて解体中...",
    ["deer"] = "シカ",
    ["deerDescriptionProgressBar"] = "シカを解体中...",
    ["pig"] = "ブタ",
    ["pigDescriptionProgressBar"] = "ブタを解体中...",
    ["hello"] = "こんにちは",
    ["level"] = "レベル",
    ["up"] = "アップ",
    ["howAbout"] = "レベルを",
    ["buyingALevel"] = "購入しませんか？",
    ["levelBuy"] = "レベル購入",
    ["setGps"] = "GPS設定",
    ["buy"] = "購入",
    ["sell"] = "売却",
    ["collected"] = "進捗",
    ["reward"] = "報酬",
    ["accept"] = "受け取る",
    ["cutting"] = "解体中...",
 }