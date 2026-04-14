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
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'アーマー',
		weight = 3000,
		stack = false,
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
}
