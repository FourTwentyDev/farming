-- shared/configs/farming_config.lua

FarmingConfig = {}

-- Farming Typen
FarmingConfig.Types = {
    STATIC_AREA = "static_area",      -- Statisches Farming in einem Radius
    STATIC_SPOTS = "static_spots",    -- Statisches Farming an mehreren definierten Punkten
    DYNAMIC = "dynamic"               -- Dynamisches Farming (Spawning von Objekten)
}

-- Statische Farming-Spots
FarmingConfig.StaticSpots = {
    -- Großes Weedfeld
    ["weed_field"] = {
        enabled = true,
        label = "Weed Feld",
        type = FarmingConfig.Types.STATIC_AREA,
        coords = vector3(2220.91, 5577.03, 53.84),
        farmingRadius = 25.0,
        reward = {
            item = "plant_weed_silverhaze",
            amount = {min = 1, max = 2},
            chance = 100
        },
        marker = {
            type = 1,
            size = vector3(1.0, 1.0, 1.0),
            color = {r = 0, g = 255, b = 0, a = 100},
            showArea = true
        },
        blip = {
            sprite = 469,
            color = 2,
            scale = 0.8,
            label = "Weed Feld"
        },
        animation = {
            dict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flag = 1,
            duration = 3000
        },
        cooldown = 3000,
        requirements = {
            job = false,
            item = "farm_gardenscissor"
        }
    },

    -- Weinberg mit mehreren Spots
    ["vineyard"] = {
        enabled = true,
        label = "Weinberg",
        type = FarmingConfig.Types.STATIC_SPOTS,
        coords = vector3(-1891.45, 2036.71, 140.83),
        spots = {
            {coords = vector3(-1892.45, 2036.71, 140.83)},
            {coords = vector3(-1889.45, 2036.71, 140.83)},
            {coords = vector3(-1891.45, 2033.71, 140.83)},
            {coords = vector3(-1891.45, 2039.71, 140.83)},
            {coords = vector3(-1894.45, 2036.71, 140.83)}
        },
        reward = {
            item = "farm_grapes",
            amount = {min = 1, max = 3},
            chance = 100
        },
        marker = {
            type = 1,
            size = vector3(1.0, 1.0, 1.0),
            color = {r = 155, g = 0, b = 255, a = 100}
        },
        blip = {
            sprite = 93,
            color = 7,
            scale = 0.8,
            label = "Weinberg"
        },
        animation = {
            dict = "amb@world_human_gardener_plant@male@idle_a",
            anim = "idle_a",
            flag = 1,
            duration = 4000
        },
        cooldown = 2000,
        requirements = {
            job = false,
            item = false
        }
    }
}

-- Dynamische Farming-Spots mit Objekt-Spawning
FarmingConfig.DynamicSpots = {
    -- Mining Area
    ["mining_spot"] = {
        enabled = true,
        label = "Bergbau",
        type = FarmingConfig.Types.DYNAMIC,
        coords = vector3(2992.77, 2750.64, 42.78),
        reward = {
            item = "farm_iron",
            amount = {min = 1, max = 2},
            chance = 100
        },
        marker = {
            type = 1,
            size = vector3(2.0, 2.0, 2.0),
            color = {r = 139, g = 69, b = 19, a = 100}
        },
        blip = {
            sprite = 618,
            color = 21,
            scale = 0.8,
            label = "Bergbau"
        },
        objects = {
            model = "prop_rock_4_c",
            amount = 6,
            radius = 20.0,
            minDistance = 3.0,
            respawnTime = 120,
            groundOffset = -0.3
        },
        collection = {
            animation = {
                dict = "melee@large_wpn@streamed_core",
                anim = "ground_attack_on_spot",
                flag = 1,
                duration = 5000
            },
            radius = 2.0
        },
        requirements = {
            job = false,
            item = "farm_pickaxe"
        }
    },

    -- Fishing Area
    ["fishing_spot"] = {
        enabled = true,
        label = "Fischen",
        type = FarmingConfig.Types.DYNAMIC,
        coords = vector3(1604.2, 3789.5, 34.2),
        reward = {
            item = "farm_salmon",
            amount = {min = 1, max = 1},
            chance = 100
        },
        marker = {
            type = 1,
            size = vector3(2.0, 2.0, 2.0),
            color = {r = 0, g = 0, b = 255, a = 100}
        },
        blip = {
            sprite = 68,
            color = 3,
            scale = 0.8,
            label = "Angelstelle"
        },
        objects = {
            model = "prop_dock_float_1",
            amount = 8,
            radius = 15.0,
            minDistance = 2.0,
            respawnTime = 60,
            groundOffset = 0.0
        },
        collection = {
            animation = {
                dict = "mini@tennis",
                anim = "forehand_ts_md_far",
                flag = 1,
                duration = 4000
            },
            radius = 2.0
        },
        requirements = {
            job = false,
            item = "farm_fishingrod"
        }
    }
}

return FarmingConfig