return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

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
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
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

	['garbage'] = {
		label = 'Garbage',
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
		label = 'Lockpick',
		weight = 160,
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
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Bulletproof Vest',
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

	['mastercard'] = {
		label = 'Fleeca Card',
		stack = false,
		weight = 10,
		client = {
			image = 'card_bank.png'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

    -- 素材関係（基本素材）
	['wild_herb'] = {
		label = '野生ハーブ',
		weight = 50,
        image = 'wild_herb.png',
	},
	['poppy_seed'] = {
		label = 'ケシの実',
		weight = 50,
        image = 'poppy_seed.png',
	},
	['coca_leaf'] = {
		label = 'コカの葉',
		weight = 60,
        image = 'coca_leaf.png',
	},
	['hallucinogenic_mushroom'] = {
		label = '幻覚キノコ',
		weight = 70,
        image = 'hallucinogenic_mushroom.png',
	},
	['cactus'] = {
		label = 'サボテン',
		weight = 80,
        image = 'cactus.png',
	},
	['medicinal_flower'] = {
		label = '薬用花',
		weight = 60,
        image = 'medicinal_flower.png',
	},
	['fermented_fruit'] = {
		label = '発酵フルーツ',
		weight = 70,
        image = 'fermented_fruit.png',
	},
	['resin'] = {
		label = '樹脂',
		weight = 90,
        image = 'resin.png',
	},
	['seaweed'] = {
		label = '海藻',
		weight = 40,
        image = 'seaweed.png',
	},
	['contaminated_plant'] = {
		label = '汚染植物',
		weight = 65,
        image = 'contaminated_plant.png',
	},

    -- 素材関係（化学素材）
	['solvent_alcohol'] = {
		label = '溶媒（アルコール）',
		weight = 100,
        image = 'solvent_alcohol.png',
	},
	['strong_solvent'] = {
		label = '強力溶媒（アセトン系）',
		weight = 110,
        image = 'strong_solvent.png',
	},
	['acidic_liquid'] = {
		label = '酸性液体',
		weight = 100,
        image = 'acidic_liquid.png',
	},
	['alkaline_liquid'] = {
		label = 'アルカリ液体',
		weight = 100,
        image = 'alkaline_liquid.png',
	},
	['chemical_reagent_a'] = {
		label = '化学試薬A',
		weight = 90,
        image = 'chemical_reagent_a.png',
	},
	['chemical_reagent_b'] = {
		label = '化学試薬B',
		weight = 90,
        image = 'chemical_reagent_b.png',
	},
	['catalyst'] = {
		label = '触媒',
		weight = 80,
        image = 'catalyst.png',
	},
	['purified_water'] = {
		label = '精製水',
		weight = 120,
        image = 'purified_water.png',
	},
	['filter_material'] = {
		label = 'フィルター',
		weight = 35,
        image = 'filter_material.png',
	},
	['crystallization_powder'] = {
		label = '結晶化粉末',
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

	-- 医療関係
	["stretcher"] = {
		label = "Stretcher",
		weight = 15000,
		stack = false,
		consume = 1,
		server = {
			export = "ND_Ambulance.createStretcher"
		}
	},
	["defib"] = {
		label = "Monitor/defibrillator",
		weight = 8000,
		stack = false,
		consume = 1,
		client = {
			export = "ND_Ambulance.useDefib",
			add = function(total)
				if total > 0 then
					pcall(function()
						return exports["ND_Ambulance"]:hasDefib(true)
					end)
				end
			end,
			remove = function(total)
				if total < 1 then
					pcall(function()
						return exports["ND_Ambulance"]:hasDefib(false)
					end)
				end
			end
		}
	},
	["medbag"] = {
		label = "Trauma bag",
		weight = 1000,
		stack = false,
		consume = 1,
		server = {
			export = "ND_Ambulance.useBag"
		},
		client = {
			export = "ND_Ambulance.useBag",
			add = function(total)
				if total > 0 then
					pcall(function()
						return exports["ND_Ambulance"]:bag(true)
					end)
				end
			end,
			remove = function(total)
				if total < 1 then
					pcall(function()
						return exports["ND_Ambulance"]:bag(false)
					end)
				end
			end
		}
	},
	["burndressing"] = {
		label = "Burn Dressing",
		weight = 50,
		server = {
			export = "ND_Ambulance.treatment"
		},
		client = {
			anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
			prop = { model = `prop_toilet_roll_01`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500
		}
	},
	["splint"] = {
		label = "Splint",
		weight = 500,
		server = {
			export = "ND_Ambulance.treatment"
		},
		client = {
			anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
			prop = { model = `prop_toilet_roll_01`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500
		}
	},
	["gauze"] = {
		label = "Gauze",
		weight = 80,
		server = {
			export = "ND_Ambulance.treatment"
		},
		client = {
			anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
			prop = { model = `prop_toilet_roll_01`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500
		}
	},
	["tourniquet"] = {
		label = "Tourniquet",
		weight = 85,
		server = {
			export = "ND_Ambulance.treatment"
		},
		client = {
			anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500
		}
	},
	-- 医療関係end
}
