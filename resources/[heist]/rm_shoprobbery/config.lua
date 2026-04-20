Config = {}

Config['ShopRobbery'] = {
    ['framework'] = {
        name = 'QB', -- Only ESX or QB.
        scriptName = 'qb-core', -- Only for QB users.
        eventName = 'QBCore:GetPlayerData', -- Only for ESX users.
    },
    ["dispatch"] = "ps-dispatch", -- cd_dispatch | qs-dispatch | ps-dispatch | rcore_dispatch | default警察が襲撃を検知したときの通知の設定
    ['requiredPoliceCount'] = 0, -- 襲撃を開始するために必要な警察の数の設定
    ['dispatchJobs'] = {'police', 'sheriff'},
    ['cooldown'] = { -- コンビニ襲撃のクールダウン時間の設定
        globalCooldown = false,
        time = 20,
    },
    ['rewardItems'] = { -- 金庫から取れるアイテムの設定
        {itemName = 'shoprobbery_gold', count = math.random(1, 10)}, -- 金庫から取れる金の延べ棒の設定
        {itemName = 'shoprobbery_diamond', count = math.random(1, 10)}, -- 金庫から取れるダイアモンドの設定
    },
    ['rewardMoneys'] = {
        ['safecrack'] = function()
            return math.random(2500000, 3500000) -- 金庫から取れるお金の設定
        end,
        ['till'] = function() -- レジから取れるお金の設定
            return math.random(200000, 300000)
        end,
    },
    ['tillGrabTime'] = 15000, -- レジを取る時間の設定 (ミリ秒)
    ['clerkWeaponChance'] = 25, -- 店員が恐れて銃を引く確率
    ['clerkWeapon'] = GetHashKey('WEAPON_PISTOL'), -- 店員の武器
    ['black_money'] = true,  -- 黒いお金に変換する場合はtrueに設定
}

Config['ShopRobberySetup'] = {
    [1] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(372.658, 327.282, 102.566), heading = 250.0}, -- 店員の設定: モデル, 座標, 向き
        safecrackSetup = {coords = vector3(379.960, 331.858, 102.566), heading = 255.47}, -- 金庫の設定: 座標, 向き
        lixeiroCharmoso = {marketId = "market_6", tillAmount = 2, remainingTill = 2} -- レジの設定: 市場ID, レジの数, 残りのレジの数
    },
    [2] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(1391.73, 3606.31, 33.9808), heading = 200.0},
        safecrackSetup = {coords = vector3(1394.57, 3608.57, 33.9808), heading = 200.47},
        lixeiroCharmoso = {marketId = "market_14", tillAmount = 1, remainingTill = 1}
    },
    [3] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(-46.675, -1758.3, 28.4210), heading = 50.0},
        safecrackSetup = {coords = vector3(-41.688, -1749.3, 28.4210), heading = 320.47},
        lixeiroCharmoso = {marketId = "market_13", tillAmount = 2, remainingTill = 2}
    },
    [4] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(1165.26, -322.95, 68.2050), heading = 100.0},
        safecrackSetup = {coords = vector3(1161.55, -313.43, 68.2050), heading = 10.47},
        lixeiroCharmoso = {marketId = "market_4", tillAmount = 2, remainingTill = 2}
    },
    [5] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(-705.62, -913.89, 18.2155), heading = 90.0},
        safecrackSetup = {coords = vector3(-707.70, -904.08, 18.2155), heading = 0.47},
        lixeiroCharmoso = {marketId = "market_1", tillAmount = 2, remainingTill = 2}
    },
    [6] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(24.0687, -1346.2, 28.4970), heading = 270.0},
        safecrackSetup = {coords = vector3(30.45, -1339.88, 28.44), heading = 269.47},
        lixeiroCharmoso = {marketId = "market_2", tillAmount = 2, remainingTill = 2}
    },
    [7] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(1728.06, 6416.29, 34.0372), heading = 240.0},
        safecrackSetup = {coords = vector3(1736.66, 6419.02, 34.0372), heading = 243.47},
        lixeiroCharmoso = {marketId = "market_8", tillAmount = 2, remainingTill = 2}
    },
    [8] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(549.554, 2670.23, 41.1564), heading = 100.0},
        safecrackSetup = {coords = vector3(545.07, 2663.47, 41.1564), heading = 96.47},
        lixeiroCharmoso = {marketId = "market_9", tillAmount = 2, remainingTill = 2}
    },
    [9] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(-3243.3, 999.759, 11.8307), heading = 350.0},
        safecrackSetup = {coords = vector3(-3249.02, 1006.04, 11.8307), heading = 0.47},
        lixeiroCharmoso = {marketId = "market_7", tillAmount = 2, remainingTill = 2}
    },
    [10] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(-1819.5, 794.251, 137.079), heading = 140.0},
        safecrackSetup = {coords = vector3(-1828.23, 799.83, 137.1), heading = 44.47},
        lixeiroCharmoso = {marketId = "market_5", tillAmount = 2, remainingTill = 2}
    },
    [11] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(1697.57, 4922.87, 41.0636), heading = 320.0},
        safecrackSetup = {coords = vector3(1706.87, 4919.76, 41.0636), heading = 237.47},
        lixeiroCharmoso = {marketId = "market_12", tillAmount = 2, remainingTill = 2}
    },
    [12] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(1959.32, 3740.79, 31.3437), heading = 300.0},
        safecrackSetup = {coords = vector3(1961.32, 3749.37, 31.3437), heading = 300.47},
        lixeiroCharmoso = {marketId = "market_10", tillAmount = 2, remainingTill = 2}
    },
    [13] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(2676.91, 3279.72, 54.2411), heading = 330.0},
        safecrackSetup = {coords = vector3(2674.24, 3287.99, 54.2411), heading = 330.47},
        lixeiroCharmoso = {marketId = "market_11", tillAmount = 2, remainingTill = 2}
    },
    [14] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(2555.68, 380.539, 107.623), heading = 350.0},
        safecrackSetup = {coords = vector3(2550.09, 386.529, 107.623), heading = 357.47},
        lixeiroCharmoso = {marketId = "market_3", tillAmount = 2, remainingTill = 2}
    },
    [15] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(-3040.2, 583.874, 6.90893), heading = 25.0},
        safecrackSetup = {coords = vector3(-3047.88, 588.16, 6.90893), heading = 17.47},
        lixeiroCharmoso = {marketId = "market_15", tillAmount = 2, remainingTill = 2}
    },
    [16] = {
        pedSetup = {model = 'mp_m_shopkeep_01', coords = vector3(1166.06, 2710.83, 37.16), heading = 178.0},
        safecrackSetup = {coords = vector3(1169.0, 2719.89, 36.16), heading = 350.8},
        lixeiroCharmoso = {marketId = "market_16", tillAmount = 1, remainingTill = 1}
    },
}

policeAlert = function(coords)
    if Config['ShopRobbery']["dispatch"] == "default" then
        TriggerServerEvent('shoprobbery:server:policeAlert', coords)
    elseif Config['ShopRobbery']["dispatch"] == "cd_dispatch" then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = Config["ShopRobbery"]['dispatchJobs'], 
            coords = coords,
            title = 'Shop Robbery',
            message = 'A '..data.sex..' robbing a Shop at '..data.street, 
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 431, 
                scale = 1.2, 
                colour = 3,
                flashes = false, 
                text = '911 - Shop Robbery',
                time = 5,
                radius = 0,
            }
        })
    elseif Config['ShopRobbery']["dispatch"] == "qs-dispatch" then
        exports['qs-dispatch']:StoreRobbery()
    elseif Config['ShopRobbery']["dispatch"] == "ps-dispatch" then
        exports['ps-dispatch']:StoreRobbery(camId)
    elseif Config['ShopRobbery']["dispatch"] == "rcore_dispatch" then
        local data = {
            code = '10-64', -- string -> 警察が襲撃を検知したときの通知のコード, 例: '10-64' や '10-64 - Shop robbery'
            default_priority = 'high', -- 'low' | 'medium' | 'high' -> 警察が襲撃を検知したときの通知の優先度
            coords = coords, -- vector3 -> 警察が襲撃を検知したときの通知の座標
            job = Config["ShopRobbery"]['dispatchJobs'], -- string | table -> 警察が襲撃を検知したときの通知の職業, 例: 'police' や {'police', 'ambulance'}
            text = 'Shop Robbery', -- string -> 警察が襲撃を検知したときの通知のテキスト
            type = 'alerts', -- alerts | shop_robbery | car_robbery | bank_robbery -> 警察が襲撃を検知したときの通知の種類
            blip_time = 5, -- number (optional) -> 警察が襲撃を検知したときの通知のブリップの時間
            blip = { -- Blip table (optional)
                sprite = 431, -- number -> 警察が襲撃を検知したときの通知のブリップのスプライト: ここで見つけることができます (https://docs.fivem.net/docs/game-references/blips/#blips)
                colour = 3, -- number -> 警察が襲撃を検知したときの通知のブリップの色: ここで見つけることができます (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
                scale = 1.2, -- number -> The blip scale
                text = 'Shop Robbery', -- number (optional) -> 警察が襲撃を検知したときの通知のブリップのテキスト
                flashes = false, -- boolean (optional) -> 警察が襲撃を検知したときの通知のブリップをフラッシュさせる
                radius = 0, -- number (optional) -> 警察が襲撃を検知したときの通知のブリップを半径にする
            }
        }
        TriggerServerEvent('rcore_dispatch:server:sendAlert', data)
    end
end

Strings = {
    ['grab_till'] = 'Press ~INPUT_CONTEXT~ to grab till',
    ['safecrack'] = 'Press ~INPUT_CONTEXT~ to start safecrack',
    ['pickup'] = 'Press ~INPUT_CONTEXT~ to pickup bag',
    ['wait_nextrob'] = 'You have to wait this long to undress again',
    ['minute'] = 'minute.',
    ['need_this'] = 'You need this: ',
    ['need_police'] = 'Not enough police in the city.',
    ['total_money'] = 'You got this: ',
    ['police_alert'] = 'Shop robbery alert! Check your gps.',
    ['not_cop'] = 'You are not cop!',
    ['not_near'] = 'There is no shop nearby',
    ['safecrack_help'] = '~INPUT_FRONTEND_LEFT~ ~INPUT_FRONTEND_RIGHT~ Rotate\n~INPUT_FRONTEND_RDOWN~ Check',
    ['charmoso_log_title'] = 'Money stolen',
    ['charmoso_store_being_robbed'] = 'Your store is being robbed!',
    ['charmoso_no_owner_online'] = 'This store is closed!',
}

-- Set this as true if you're using the "Stores" script from LixeiroCharmoso (https://discord.gg/U5YDgbh). 
-- When enabled, the reward items and the money will be got from stores stocks and stores money. If the stores does not have owner, it wil be the values you configured in rewardMoneys and rewardItems
-- ATTENTION: remove the -- from this line "@mysql-async/lib/MySQL.lua" inside the server_scripts on fxmanifest.lua
-- If you need any support related to this, send a DM on discord: Lixeiro Charmoso#1104
Config['enableLixeiroCharmosoMarkets'] = false
Config['LixeiroCharmosoMarketsSettings'] = {
    money_percentage_earned = 0.7, -- レジから取れるお金の割合の設定
    items_percentage_earned = 0.7, -- レジから取れるアイテムの割合の設定
	require_owner_be_online = true -- true: 店舗はオンラインの場合のみ襲撃できる | false: 店舗はオンラインでなくても襲撃できる
}