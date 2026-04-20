Config = {}

Config.Debug = false

Config.PoliceJobs = {
    police = true,
    sheriff = true
}

Config.Actions = {
    process_lab_1 = {
        label = '薬物を製造する',
        icon = 'fa-solid fa-flask-vial',
        duration = 8000,
        cooldown = 3,
        minCops = 0,
        mode = 'process_ui',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(1957.7397460938, 5172.4497070313, 47.910243988037),
            radius = 1.8
        }
    },
    process_lab_2 = {
        label = '薬物を製造する',
        icon = 'fa-solid fa-flask-vial',
        duration = 8000,
        cooldown = 3,
        minCops = 0,
        mode = 'process_ui',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(892.2587, -960.8538, 38.18458),
            radius = 1.8
        }
    },
    process_lab_3 = {
        label = '薬物を製造する',
        icon = 'fa-solid fa-flask-vial',
        duration = 8000,
        cooldown = 3,
        minCops = 0,
        mode = 'process_ui',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(-341.86242675781, -2444.3217773438, 6.000337600708),
            radius = 1.8
        }
    },
    process_lab_4 = {
        label = '薬物を製造する',
        icon = 'fa-solid fa-flask-vial',
        duration = 8000,
        cooldown = 3,
        minCops = 0,
        mode = 'process_ui',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(-1366.676, -316.9358, 38.28989),
            radius = 1.8
        }
    },

    -- ケシの実を採取する
    poppy_gather = {
        label = 'ケシの実を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 5 },
        giveItem = 'poppy_seed',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(-691.3975, 2541.3242, 54.9050),
            radius = 1.5
        }
    },
    poppy_gather_2 = {
        label = 'ケシの実を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 5 },
        giveItem = 'poppy_seed',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(-686.2345, 2549.5527, 54.0858),
            radius = 1.5
        }
    },
    poppy_gather_3 = {
        label = 'ケシの実を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 5 },
        giveItem = 'poppy_seed',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(-697.8224, 2557.4246, 52.4048),
            radius = 1.5
        }
    },
    -- ケシの実を採取する

    -- 幻覚キノコを採取する
    mushroom_gather = {
        label = '幻覚キノコを採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5800,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 4 },
        giveItem = 'hallucinogenic_mushroom',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(-594.5364, 4920.6997, 175.5482),
            radius = 2
        }
    },
    -- 幻覚キノコを採取する

    -- サボテンを採取する
    cactus_gather = {
        label = 'サボテンを採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 5 },
        giveItem = 'cactus',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(1404.0499, 3278.6719, 38.5487),
            radius = 1.5
        }
    },
    -- サボテンを採取する

    -- 発酵フルーツを採取する
    fruit_gather = {
        label = '発酵フルーツを採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 5 },
        giveItem = 'fermented_fruit',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(2360.8088, 4750.1064, 34.6500),
            radius = 1.5
        }
    },
    -- 発酵フルーツを採取する

    -- 樹脂を採取する
    resin_gather = {
        label = '樹脂を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 4 },
        giveItem = 'resin',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(1559.9771, 6528.8789, 21.1294),
            radius = 1.5
        }
    },
    -- 樹脂を採取する

    -- 海藻を採取する
    seaweed_gather = {
        label = '海藻を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5200,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'seaweed',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(2354.7549, 6667.2227, 1.6896),
            radius = 2
        }
    },
    seaweed_gather_2 = {
        label = '海藻を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5200,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'seaweed',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(2358.5747, 6663.1401, 1.7389),
            radius = 2
        }
    },
    seaweed_gather_3 = {
        label = '海藻を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5200,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'seaweed',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(2357.4526, 6656.8535, 1.9079),
            radius = 2
        }
    },
    -- 海藻を採取する

    -- 汚染植物を採取する
    contaminated_plant_gather = {
        label = '汚染植物を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5000,
        cooldown = 1,
        minCops = 0,
        amount = { min = 1, max = 5 },
        giveItem = 'contaminated_plant',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(1084.7754, -2052.6252, 31.0051),
            radius = 1.6
        }
    },
    -- 汚染植物を採取する

    -- 薬用花を採取する
    medicinal_flower_gather = {
        label = '薬用花を採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5000,
        cooldown = 1,
        minCops = 0,
        amount = { min = 1, max = 5 },
        giveItem = 'medicinal_flower',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(924.4713, 510.8672, 120.6488),
            radius = 1.6
        }
    },
    -- 薬用花を採取する

    -- 溶媒（アルコール）を採取する
    solvent_alcohol_gather = {
        label = '溶媒（アルコール）を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6200,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'solvent_alcohol',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(-1171.2900, -1155.2567, 5.6529),
            radius = 1.6
        }
    },
    -- 溶媒（アルコール）を採取する

    -- 強力溶媒（アセトン系）を採取する
    strong_solvent_gather = {
        label = '強力溶媒（アセトン系）を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'strong_solvent',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(-16.7621, -1389.4968, 29.3649),
            radius = 1.6
        }
    },
    -- 強力溶媒（アセトン系）を採取する

    -- 酸性液体を採取する
    acidic_liquid_gather = {
        label = '酸性液体を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6200,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'acidic_liquid',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(45.5420, -2744.6570, 6.0016),
            radius = 1.6
        }
    },
    -- 酸性液体を採取する

    -- アルカリ液体を採取する
    alkaline_liquid_gather = {
        label = 'アルカリ液体を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6200,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'alkaline_liquid',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(19.1508, -2731.9165, 6.0061),
            radius = 1.6
        }
    },
    -- アルカリ液体を採取する

    -- 化学試薬Aを採取する
    reagent_a_gather = {
        label = '化学試薬Aを採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6000,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'chemical_reagent_a',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(1389.0476, 3605.4734, 38.9419),
            radius = 1.6
        }
    },
    -- 化学試薬Aを採取する

    -- 化学試薬Bを採取する
    reagent_b_gather = {
        label = '化学試薬Bを採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6000,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'chemical_reagent_b',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(1389.7556, 3608.7405, 38.9419),
            radius = 1.6
        }
    },
    -- 化学試薬Bを採取する

    -- 触媒を採取する
    catalyst_gather = {
        label = '触媒を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6200,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'catalyst',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(626.2344, -416.0964, 24.6928),
            radius = 1.6
        }
    },
    catalyst_gather_2 = {
        label = '触媒を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6200,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'catalyst',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(626.3802, -413.0001, 24.6774),
            radius = 1.6
        }
    },
    -- 触媒を採取する

    -- 精製水を採取する
    purified_water_gather = {
        label = '精製水を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 5800,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'purified_water',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(3548.5840, 3635.1829, 41.4746),
            radius = 1.6
        }
    },
    purified_water_gather_2 = {
        label = '精製水を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 5800,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'purified_water',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(3511.7385, 3638.5876, 41.4746),
            radius = 1.6
        }
    },
    -- 精製水を採取する

    -- フィルターを採取する
    filter_material_gather = {
        label = 'フィルターを採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 5600,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 5 },
        giveItem = 'filter_material',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(-380.2910, -4103.8232, 12.0324),
            radius = 2.4
        }
    },
    -- フィルターを採取する

    -- 結晶化粉末を採取する
    crystallization_powder_gather = {
        label = '結晶化粉末を採取する',
        icon = 'fa-solid fa-flask-vial',
        duration = 6500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 1, max = 3 },
        giveItem = 'crystallization_powder',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        zone = {
            coords = vec3(-246.1607, -2599.8845, 6.0003),
            radius = 1.6
        }
    },
    -- 結晶化粉末を採取する
}

Config.ProcessRecipes = {
    weed = {
        label = '大麻',
        inputs = {
            wild_herb = 3,
            chemical_reagent_a = 1,
            filter_material = 1
        },
        outputItem = 'weed_baggy',
        outputCount = 1
    },
    coke = {
        label = 'コカイン',
        inputs = {
            coca_leaf = 3,
            acidic_liquid = 1,
            crystallization_powder = 1
        },
        outputItem = 'coke_baggy',
        outputCount = 1
    },
    meth = {
        label = 'メス',
        inputs = {
            medicinal_flower = 3,
            strong_solvent = 1,
            chemical_reagent_b = 1
        },
        outputItem = 'meth_baggy',
        outputCount = 1
    }
}
