-- shared/configs/processing_config.lua

ProcessingConfig = {}

-- Verarbeitungsstellen
ProcessingConfig.Locations = {
    ["butcher"] = {
        enabled = true,
        label = "Metzger",
        coords = vector3(-1070.1, -2003.5, 15.8),
        blip = {
            sprite = 473,
            color = 1,
            scale = 0.8,
            label = "Metzger"
        },
        marker = {
            type = 1,
            size = vector3(1.0, 1.0, 1.0),
            color = {r = 255, g = 0, b = 0, a = 100}
        },
        allowedRecipes = {
            "ing_meat",
            "resfood_sandwich",
            "resfood_burrito",
            "resfood_hotdog"
        },
        requirements = {
            job = false,
            item = false
        },
        workstation = {
            type = "table",
            animation = {
                dict = "mini@repair",
                anim = "fixing_a_ped",
                flag = 1
            }
        }
    },

    ["restaurant_kitchen"] = {
        enabled = true,
        label = "Restaurant Küche",
        coords = vector3(-1844.77, -1183.93, 13.31),
        blip = {
            sprite = 106,
            color = 1,
            scale = 0.8,
            label = "Restaurant Küche"
        },
        marker = {
            type = 1,
            size = vector3(1.0, 1.0, 1.0),
            color = {r = 255, g = 165, b = 0, a = 100}
        },
        allowedRecipes = {
            "resfood_baconlover",
            "resfood_cheeseburger",
            "resfood_doublecheeseburger",
            "resfood_sandwich",
            "resfood_kebab"
        },
        requirements = {
            job = false,
            item = false
        },
        workstation = {
            type = "kitchen",
            animation = {
                dict = "anim@heists@prison_heiststation@cop_reactions",
                anim = "cop_b_idle",
                flag = 1
            }
        }
    },

    ["smeltery"] = {
        enabled = true,
        label = "Schmelzerei",
        coords = vector3(1109.03, -2007.61, 30.94),
        blip = {
            sprite = 436,
            color = 44,
            scale = 0.8,
            label = "Schmelzerei"
        },
        marker = {
            type = 1,
            size = vector3(1.0, 1.0, 1.0),
            color = {r = 255, g = 87, b = 51, a = 100}
        },
        allowedRecipes = {
            "farm_copper_ingot",
            "farm_iron_ingot",
            "farm_gold_ingot"
        },
        requirements = {
            job = false,
            item = false
        },
        workstation = {
            type = "furnace",
            animation = {
                dict = "amb@prop_human_bbq@male@idle_a",
                anim = "idle_b",
                flag = 1
            }
        }
    },

    ["fish_processor"] = {
        enabled = true,
        label = "Fischverarbeitung",
        coords = vector3(1557.81, 3797.89, 34.01),
        blip = {
            sprite = 356,
            color = 3,
            scale = 0.8,
            label = "Fischverarbeitung"
        },
        marker = {
            type = 1,
            size = vector3(1.0, 1.0, 1.0),
            color = {r = 0, g = 128, b = 255, a = 100}
        },
        allowedRecipes = {
            "resfood_fishburger",
            "fish_fillet",
            "fish_package"
        },
        requirements = {
            job = false,
            item = false
        },
        workstation = {
            type = "table",
            animation = {
                dict = "anim@heists@prison_heiststation@cop_reactions",
                anim = "cop_b_idle",
                flag = 1
            }
        }
    }
}

return ProcessingConfig