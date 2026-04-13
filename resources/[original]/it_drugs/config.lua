Config = {}

Config.Debug = false

Config.PoliceJobs = {
    police = true,
    sheriff = true
}

Config.Actions = {
    weed_gather = {
        label = '野生ハーブを採取する',
        icon = 'fa-solid fa-seedling',
        duration = 5500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 3, max = 6 },
        giveItem = 'wild_herb',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(2223.9, 5577.8, 53.8),
            radius = 1.5
        }
    },
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
    weed_sell = {
        label = '大麻を売却する',
        icon = 'fa-solid fa-hand-holding-dollar',
        duration = 4500,
        cooldown = 4,
        minCops = 0,
        requireItem = 'weed_baggy',
        requireCount = 1,
        payout = { min = 350, max = 550 },
        account = 'cash',
        anim = {
            dict = 'mp_common',
            clip = 'givetake1_a',
            flag = 49
        },
        zone = {
            coords = vec3(-1172.1, -1572.4, 4.7),
            radius = 1.7
        }
    },
    coke_gather = {
        label = 'コカの葉を採取する',
        icon = 'fa-solid fa-leaf',
        duration = 6000,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 5 },
        giveItem = 'coca_leaf',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(1109.4, -3194.4, -40.4),
            radius = 1.5
        }
    },
    coke_sell = {
        label = 'コカインを売却する',
        icon = 'fa-solid fa-sack-dollar',
        duration = 5000,
        cooldown = 5,
        minCops = 0,
        requireItem = 'coke_baggy',
        requireCount = 1,
        payout = { min = 700, max = 1000 },
        account = 'cash',
        anim = {
            dict = 'mp_common',
            clip = 'givetake1_a',
            flag = 49
        },
        zone = {
            coords = vec3(-1532.9, -427.4, 35.4),
            radius = 1.7
        }
    },
    meth_gather = {
        label = '薬用花を採取する',
        icon = 'fa-solid fa-jug-detergent',
        duration = 5500,
        cooldown = 3,
        minCops = 0,
        amount = { min = 2, max = 5 },
        giveItem = 'medicinal_flower',
        anim = {
            dict = 'amb@world_human_gardener_plant@male@idle_a',
            clip = 'idle_a',
            flag = 49
        },
        zone = {
            coords = vec3(1391.6, 3605.3, 38.9),
            radius = 1.5
        }
    },
    meth_sell = {
        label = 'メスを売却する',
        icon = 'fa-solid fa-money-bill-transfer',
        duration = 5200,
        cooldown = 5,
        minCops = 0,
        requireItem = 'meth_baggy',
        requireCount = 1,
        payout = { min = 900, max = 1300 },
        account = 'cash',
        anim = {
            dict = 'mp_common',
            clip = 'givetake1_a',
            flag = 49
        },
        zone = {
            coords = vec3(-1304.9, -894.7, 11.1),
            radius = 1.7
        }
    }
}

Config.ProcessRecipes = {
    weed = {
        label = '大麻',
        inputItem = 'wild_herb',
        inputPerBatch = 3,
        outputItem = 'weed_baggy',
        outputCount = 1
    },
    coke = {
        label = 'コカイン',
        inputItem = 'coca_leaf',
        inputPerBatch = 3,
        outputItem = 'coke_baggy',
        outputCount = 1
    },
    meth = {
        label = 'メス',
        inputItem = 'medicinal_flower',
        inputPerBatch = 3,
        outputItem = 'meth_baggy',
        outputCount = 1
    }
}
