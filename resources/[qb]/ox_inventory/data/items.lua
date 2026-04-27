return {
	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['black_money'] = {
		label = '汚いお金',
	},

	['burger'] = {
		label = 'バーガー',
		weight = 250,
		client = {
			status = { hunger = 100000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'バーガーを食べました'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'ロックピック',
		weight = 100,
	},

	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'お金',
	},

	['water'] = {
		label = '水',
		weight = 250,
		client = {
			status = { thirst = 100000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = '水を飲みました'
		}
	},

	['radio'] = {
        label = '無線ラジオ',
        weight = 1000,
        stack = false,
        allowArmed = true,
        consume = 0,
        client = {
            event = 'izzy-radio:use'
        }
    },

	['humane_usb'] = {
		label = '機密データUSB',
		weight = 50,
		stack = false,
		description = 'ヒューメイン研究所から盗み出した機密データ。発注者に渡すと報酬がもらえる。',
	},

	['armour'] = {
		label = 'アーマー',
		weight = 3000,
		stack = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

    -- 素材関係（基本素材）
	['wild_herb'] = {
		label = '野生ハーブ',
        description = '野原で採れる草本系の素材。',
		weight = 50,
        image = 'wild_herb.png',
	},
	['poppy_seed'] = {
		label = 'ケシの実',
        description = '特徴的な球形のさやから取れる種子。取り扱いには注意が必要。',
		weight = 50,
        image = 'poppy_seed.png',
	},
	['coca_leaf'] = {
		label = 'コカの葉',
        description = '乾燥地帯の多肉植物。棘や汁液に注意。',
		weight = 60,
        image = 'coca_leaf.png',
	},
	['hallucinogenic_mushroom'] = {
		label = '幻覚キノコ',
        description = '食べたら危なそうなキノコ',
		weight = 70,
        image = 'hallucinogenic_mushroom.png',
	},
	['cactus'] = {
		label = 'サボテン',
        description = '刺があるので注意。',
		weight = 80,
        image = 'cactus.png',
	},
	['medicinal_flower'] = {
		label = '薬用花',
        description = '薬用価値がある花。',
		weight = 60,
        image = 'medicinal_flower.png',
	},
	['fermented_fruit'] = {
		label = '発酵フルーツ',
        description = '発酵したフルーツ。',
		weight = 70,
        image = 'fermented_fruit.png',
	},
	['resin'] = {
		label = '樹脂',
        description = '樹皮から採れる粘液。',
		weight = 90,
        image = 'resin.png',
	},
	['seaweed'] = {
		label = '海藻',
        description = '味噌汁に入れたらおいしそうな海藻。',
		weight = 40,
        image = 'seaweed.png',
	},
	['contaminated_plant'] = {
		label = '汚染植物',
        description = '汚染された植物。',
		weight = 65,
        image = 'contaminated_plant.png',
	},

    -- 素材関係（化学素材）
	['solvent_alcohol'] = {
		label = '溶媒（アルコール）',
        description = '有機物を溶かしやすいアルコール系溶媒。',
		weight = 100,
        image = 'solvent_alcohol.png',
	},
	['strong_solvent'] = {
		label = '強力溶媒（アセトン系）',
        description = '脱脂・洗浄に使われる揮発性の強い溶媒。換気必須。',
		weight = 110,
        image = 'strong_solvent.png',
	},
	['acidic_liquid'] = {
		label = '酸性液体',
        description = '低pHの腐食性液体。金属や皮膚に注意。',
		weight = 100,
        image = 'acidic_liquid.png',
	},
	['alkaline_liquid'] = {
		label = 'アルカリ液体',
        description = '高pHの腐食性液体。酸と混ぜないこと。',
		weight = 100,
        image = 'alkaline_liquid.png',
	},
	['chemical_reagent_a'] = {
		label = '化学試薬A',
        description = '反応を助ける固体粉末。微量で効く。',
		weight = 90,
        image = 'chemical_reagent_a.png',
	},
	['chemical_reagent_b'] = {
		label = '化学試薬B',
        description = '反応を助ける固体粉末。微量で効く。',
		weight = 90,
        image = 'chemical_reagent_b.png',
	},
	['catalyst'] = {
		label = '触媒',
        description = '反応を助ける固体粉末。微量で効く。',
		weight = 80,
        image = 'catalyst.png',
	},
	['purified_water'] = {
		label = '精製水',
        description = '不純物を除去した水。希釈や洗浄に使う。',
		weight = 120,
        image = 'purified_water.png',
	},
	['filter_material'] = {
		label = 'フィルター',
        description = '微粒子を捕集するフィルター材。使い捨て。',
		weight = 35,
        image = 'filter_material.png',
	},
	['crystallization_powder'] = {
		label = '結晶化粉末',
        description = '結晶核として働く細粉末。湿度に敏感。',
		weight = 95,
        image = 'crystallization_powder.png',
	},

    -- 薬関係（完成品）
	['weed_baggy'] = {
		label = '大麻の袋',
		weight = 120,
        image = 'weed_baggy.png',
	},
	['coke_baggy'] = {
		label = 'コカインの袋',
		weight = 110,
        image = 'coke_baggy.png',
	},
	['meth_baggy'] = {
		label = 'メスの袋',
		weight = 120,
        image = 'meth_baggy.png',
	},
	['drug_waste'] = {
		label = '薬のごみ',
		weight = 100,
        image = 'drug_waste.png',
	},

    -- 犯罪関係
    ['cryptostick'] = {
        label = 'クリプトスティック',
        description = '何かに使えそう…',
        weight = 0,
        type = 'item',
        image = 'cryptostick.png',
        unique = true,
    },
    -- 犯罪関係

    -- バーガーショット
    ['rawburgerpatty'] = {
        label = '冷凍バーガーパティ',
        weight = 100,
        degrade = 120,
    },

    ['cookedburgerpatty'] = {
        label = 'バーガーパティ',
        weight = 100,
        degrade = 30,
    },

    ['veganburgerpatty'] = {
        label = '冷凍ヴィーガンバーガーパティ',
        weight = 100,
        degrade = 250,
    },

    ['cookedveganburgerpatty'] = {
        label = 'ヴィーガンパティ',
        weight = 100,
        degrade = 30,
    },

    ['potato'] = {
        label = 'ポテト',
        weight = 100,
    },

    ['cutpotato'] = {
        label = 'ポテトスライス',
        weight = 100,
    },

    ['onion'] = {
        label = '玉ねぎ',
        weight = 60,
    },

    ['cutonion'] = {
        label = '玉ねぎスライス',
        weight = 60,
    },

    ['tomato'] = {
        label = 'トマト',
        weight = 40,
    },

    ['cuttomato'] = {
        label = 'トマトスライス',
        weight = 40,
    },

    ['burgerbun'] = {
        label = 'バンズ',
        weight = 50,
    },

    ['cheddar'] = {
        label = 'チダーチーズ',
        weight = 20,
    },

    ['lettuce'] = {
        label = 'レタス',
        weight = 40,
    },

    ['cutlettuce'] = {
        label = 'レタススライス',
        weight = 40,
    },

    ['nuggets'] = {
        label = 'ナゲット',
        weight = 40,
        degrade = 120,
    },

    ['receipt'] = {
        label = 'レシート',
        weight = 1,
    },

    ['bleeder'] = {
        label = 'ブリーダーバーガー',
        weight = 250,
        client = {
            status = { hunger = 40000 },
            anim = 'eating',
            prop = { model = `prop_cs_burger_01`, pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0) },
            usetime = 2500,
            notification = 'バーガーを食べた'
        },
        degrade = 60,
    },

    ['meatfree'] = {
        label = 'ヴィーガンバーガー',
        weight = 250,
        client = {
            status = { hunger = 40000 },
            anim = 'eating',
            prop = { model = `prop_cs_burger_01`, pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0) },
            usetime = 2500,
            notification = 'バーガーを食べた'
        },
        degrade = 60,
    },

    ['torpedo'] = {
        label = 'トルピードサンド',
        weight = 250,
        client = {
            status = { hunger = 40000 },
            anim = 'eating',
            prop = { model = `prop_cs_burger_01`, pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0) },
            usetime = 2500,
            notification = 'サンドを食べた'
        },
        degrade = 60,
    },

    ['cookednuggets'] = {
        label = 'チキンナゲット',
        weight = 250,
        client = {
            status = { hunger = 40000 },
            anim = 'eating',
            prop = { model = `prop_cs_burger_01`, pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0) },
            usetime = 2500,
            notification = 'チキンナゲットを食べた'
        },
        degrade = 60,
    },

    ['heartstopper'] = {
        label = 'ハートストッパーバーガー',
        weight = 250,
        client = {
            status = { hunger = 40000 },
            anim = 'eating',
            prop = { model = `prop_cs_burger_01`, pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0) },
            usetime = 2500,
            notification = 'バーガーを食べた'
        },
        degrade = 60,
    },

    ['moneyshot'] = {
        label = 'マネーショットバーガー',
        weight = 250,
        client = {
            status = { hunger = 40000 },
            anim = 'eating',
            prop = { model = `prop_cs_burger_01`, pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0) },
            usetime = 2500,
            notification = 'バーガーを食べた'
        },
        degrade = 60,
    },

    ['fries'] = {
        label = 'フライドポテト',
        weight = 100,
        client = {
            status = { hunger = 30000 },
            anim = 'eating',
            prop = { model = `prop_food_bs_chips`, pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0) },
            usetime = 2500,
            notification = 'ポテトを食べた'
        },
        degrade = 60,
    },

    ['bscoke'] = {
        label = 'バーガーショットコーラ',
        weight = 100,
        client = {
            status = { thirst = 120000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_bs_juice01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'コーラを飲んだ'
        },
    },

    ['bscoffee'] = {
        label = 'バーガーショットコーヒー',
        weight = 100,
        client = {
            status = { thirst = 120000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_bs_coffee`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'コーヒーを飲んだ'
        }
    },

    ['milkshake'] = {
        label = 'ミルクシェイク',
        weight = 100,
        client = {
            status = { thirst = 120000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_bs_cup`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'ミルクシェイクを飲んだ'
        },
        degrade = 60,
    },
    -- バーガーショット

    --Jim-Mechanic Vehicles
	["mechanic_tools"] = {
		label = "Mechanic tools",
		weight = 0,
		stack = false,
		close = true,
		description = "Needed for vehicle repairs",
		client = {
			event = "jim-mechanic:client:Repair:Check"
		}
	},
	["toolbox"] = {
		label = "Toolbox",
		weight = 0,
		stack = false,
		close = true,
		description = "Needed for Performance part removal",
		client = {
			event = "jim-mechanic:client:Menu"
		}
	},
	["ducttape"] =          {["name"] = "ducttape",         ["label"] = "Duct Tape",			["weight"] = 0, ["type"] = "item",  ["image"] = "bodyrepair.png",       ["unique"] = true,  ["useable"] = true, ["shouldClose"] = true, ["description"] = "Good for quick fixes"},
	["mechboard"] =         {["name"] = "mechboard",        ["label"] = "Mechanic Sheet",		["weight"] = 0, ["type"] = "item",  ["image"] = "mechboard.png",        ["unique"] = true,  ["useable"] = true, ["shouldClose"] = true, ["description"] = ""},

	--Performance
	["turbo"] = { label = "Supercharger Turbo", weight = 0, stack = false, close = true, description = "Who doesn't need a 65mm Turbo??", client = { event = "jim-mechanic:client:applyTurbo" } },
	["car_armor"] = { label = "Vehicle Armor", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyArmour" } },
	["nos"] = { label = "NOS Bottle", weight = 0, stack = false, close = true, description = "A full bottle of NOS", client = { event = "jim-mechanic:client:applyNOS" } },
	["noscan"] = { label = "Empty NOS Bottle", weight = 0, stack = true, close = true, description = "An Empty bottle of NOS" },
	["noscolour"] = { label = "NOS Colour Injector", weight = 0, stack = true, close = true, description = "Make that purge spray", client = { event = "jim-mechanic:client:NOS:rgbORhex" } },
	["engine1"] = { label = "Tier 1 Engine", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyEngine1" } },
	["engine2"] = { label = "Tier 2 Engine", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyEngine2" } },
	["engine3"] = { label = "Tier 3 Engine", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyEngine3" } },
	["engine4"] = { label = "Tier 4 Engine", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyEngine4" } },
	["engine5"] = { label = "Tier 5 Engine", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyEngine5" } },
	["transmission1"] = { label = "Tier 1 Transmission", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyTransmission1" } },
	["transmission2"] = { label = "Tier 2 Transmission", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyTransmission2" } },
	["transmission3"] = { label = "Tier 3 Transmission", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyTransmission3" } },
	["transmission4"] = { label = "Tier 4 Transmission", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyTransmission4" } },
	["brakes1"] = { label = "Tier 1 Brakes", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyBrakes1" } },
	["brakes2"] = { label = "Tier 2 Brakes", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyBrakes2" } },
	["brakes3"] = { label = "Tier 3 Brakes", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyBrakes3" } },
	["suspension1"] = { label = "Tier 1 Suspension", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applySuspension1" } },
	["suspension2"] = { label = "Tier 2 Suspension", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applySuspension2" } },
	["suspension3"] = { label = "Tier 3 Suspension", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applySuspension3" } },
	["suspension4"] = { label = "Tier 4 Suspension", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applySuspension4" } },
	["suspension5"] = { label = "Tier 5 Suspension", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applySuspension5" } },
	["bprooftires"] = { label = "Bulletproof Tires", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyBulletProof" } },
	["drifttires"] = { label = "Drift Tires", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:applyDrift" } },

	--Cosmetics
	["underglow_controller"] = { label = "Neon Controller", weight = 0, stack = true, close = true, description = "RGB LED Vehicle Remote", client = { event = "jim-mechanic:client:neonMenu" } },
	["headlights"] = { label = "Xenon Headlights", weight = 0, stack = false, close = true, description = "8k HID headlights", client = { event = "jim-mechanic:client:applyXenons" } },
	["tint_supplies"] = { label = "Tint Supplies", weight = 0, stack = true, close = true, description = "Supplies for window tinting", client = { event = "jim-mechanic:client:Windows:Check" } },
	["customplate"] = { label = "Customized Plates", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Plates:Check" } },
	["hood"] = { label = "Vehicle Hood", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Hood:Check" } },
	["roof"] = { label = "Vehicle Roof", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Roof:Check" } },
	["spoiler"] = { label = "Vehicle Spoiler", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Spoilers:Check" } },
	["bumper"] = { label = "Vehicle Bumper", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Bumpers:Check" } },
	["skirts"] = { label = "Vehicle Skirts", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Skirts:Check" } },
	["exhaust"] = { label = "Vehicle Exhaust", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Exhaust:Check" } },
	["seat"] = { label = "Seat Cosmetics", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Seat:Check" } },
	["rollcage"] = { label = "Roll Cage", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:RollCage:Check" } },
	["rims"] = { label = "Custom Wheel Rims", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Rims:Check" } },
	["livery"] = { label = "Livery Roll", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Livery:Check" } },
	["paintcan"] = { label = "Vehicle Spray Can", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Paints:Check" } },
	["tires"] = { label = "Drift Smoke Tires", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Tires:Check" } },
	["horn"] = { label = "Custom Vehicle Horn", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Horn:Check" } },
	["internals"] = { label = "Internal Cosmetics", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Interior:Check" } },
	["externals"] = { label = "Exterior Cosmetics", weight = 0, stack = false, close = true, client = { event = "jim-mechanic:client:Exterior:Check" } },

	--Repair Parts
	["newoil"] = { label = "Car Oil", weight = 0, stack = true, close = false },
	["sparkplugs"] = { label = "Spark Plugs", weight = 0, stack = true, close = false },
	["carbattery"] = { label = "Car Battery", weight = 0, stack = true, close = false },
	["axleparts"] = { label = "Axle Parts", weight = 0, stack = true, close = false },
	["sparetire"] = { label = "Spare Tire", weight = 0, stack = false, close = false },
    --Jim-Mechanic Vehicles

    ['heist_bag'] = {
        label = '犯罪バッグ',
        weight = 500,
    },

    -- コンビニ強盗
    ['shoprobbery_gold'] = {
    label = '金の延べ棒',
        weight = 160,
    },
    ['shoprobbery_diamond'] = {
        label = 'ダイアモンド',
        weight = 160,
    },
    -- コンビニ強盗

    -- フリーカ銀行
    ['fleeca_drill'] = {
        label = '銀行強盗用ドリル',
        weight = 1000,
    },
    ['fleeca_gold'] = {
        label = '金の延べ棒',
        weight = 160,
    },
    ['fleeca_diamond'] = {
        label = 'ダイアモンド',
        weight = 160,
    },
    -- フリーカ銀行

    ['carheist_laptop_h'] = {
        label = 'Hack Laptop',
        weight = 160,
    },
    ['carheist_coke_pooch'] = {
        label = 'Coke Pooch',
        weight = 160,
    },
    ['carheist_weed_pooch'] = {
        label = 'Weed Pooch',
        weight = 160,
    },
    ['carheist_gold'] = {
        label = 'Gold Bar',
        weight = 160,
    },

    -- ak4y-advancedHunting（tebexInfo 準拠・鶏エサは admin_commands 用）
    ['hunting_knife'] = {
        label = '狩猟ナイフ',
        description = '狩りで獲物をさばくのに使う。',
        weight = 50,
        stack = false,
        close = true,
        degrade = 40320,
        client = {
            event = 'ak4y-advancedHunting:useHuntingKnife'
        }
    },
    ['deer_bait'] = {
        label = '鹿用エサ（低品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
        client = {
            event = 'ak4y-advancedHunting:useDeerBait'
        }
    },
    ['deer_bait2'] = {
        label = '鹿用エサ（高品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
        client = {
            event = 'ak4y-advancedHunting:useDeerBaitHigh'
        }
    },
    ['pig_bait'] = {
        label = '豚用エサ（低品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
        client = {
            event = 'ak4y-advancedHunting:usePigBait'
        }
    },
    ['pig_bait2'] = {
        label = '豚用エサ（高品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
        client = {
            event = 'ak4y-advancedHunting:usePigBaitHigh'
        }
    },
    ['chicken_bait'] = {
        label = '鶏用エサ（低品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
        client = {
            event = 'ak4y-advancedHunting:useChickenBait'
        }
    },
    ['chicken_bait2'] = {
        label = '鶏用エサ（高品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
        client = {
            event = 'ak4y-advancedHunting:useChickenBaitHigh'
        }
    },
    ['deer_meat'] = {
        label = '鹿肉（低品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
    },
    ['deer_meat2'] = {
        label = '鹿肉（高品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
    },
    ['pig_meat'] = {
        label = '豚肉（低品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
    },
    ['pig_meat2'] = {
        label = '豚肉（高品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
    },
    ['chicken_meat'] = {
        label = '鶏肉（低品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
    },
    ['chicken_meat2'] = {
        label = '鶏肉（高品質）',
        weight = 50,
        stack = true,
        close = true,
        degrade = 40320,
    },

	-- wasabi_ambulance（使用時の削除はスクリプト側。consume=0 で二重消費を防ぐ）
	['burncream'] = {
		label = '火傷軟膏',
		weight = 100,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'burncream.png', event = 'wasabi_ambulance:useBurncream' },
	},
	['defib'] = {
		label = '除細動器',
		weight = 800,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'defib.png', event = 'wasabi_ambulance:reviveTarget' },
	},
	['icepack'] = {
		label = 'アイスパック',
		weight = 150,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'icepack.png', event = 'wasabi_ambulance:useIcepack' },
	},
	['medbag'] = {
		label = '救急バッグ',
		weight = 500,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'medbag.png', event = 'wasabi_ambulance:useMedbag' },
	},
	['medikit'] = {
		label = '救急キット',
		weight = 400,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'medikit.png', event = 'wasabi_ambulance:healTarget' },
	},
	['sedative'] = {
		label = '鎮静剤',
		weight = 50,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'sedative.png', event = 'wasabi_ambulance:useSedative' },
	},
	['suturekit'] = {
		label = '縫合キット',
		weight = 120,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'suturekit.png', event = 'wasabi_ambulance:useSuturekit' },
	},
	['tweezers'] = {
		label = 'ピンセット',
		weight = 30,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'tweezers.png', event = 'wasabi_ambulance:useTweezers' },
	},
	['stretcher'] = {
		label = '折りたたみストレッチャー',
		weight = 2000,
		stack = true,
		close = true,
		consume = 0,
		client = { image = 'stretcher.png', event = 'wasabi_ambulance:useStretcher' },
	},

    -- pickle_prisons
    ['wood'] = {
        label = '木',
        weight = 1,
        stack = true,
        close = true,
        description = nil
    },

    ['metal'] = {
        label = '金属',
        weight = 1,
        stack = true,
        close = true,
        description = nil
    },

    ['rope'] = {
        label = 'ロープ',
        weight = 1,
        stack = true,
        close = true,
        description = nil
    },

    ['shovel'] = {
        label = 'シャベル',
        weight = 1,
        stack = true,
        close = true,
        description = nil
    },
    -- pickle_prisons
}
