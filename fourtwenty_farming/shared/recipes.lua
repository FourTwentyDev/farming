-- shared/configs/recipes.lua

Recipes = {}

Recipes.List = {
    -- Restaurant/Burger Rezepte
    ["resfood_baconlover"] = {
        label = "Baconlover Burger",
        time = 30,
        price = 2000,
        requires = {
            {item = "ing_bread", amount = 2},
            {item = "ing_meat", amount = 2},
            {item = "ing_tomato", amount = 1},
            {item = "ing_salad", amount = 1},
            {item = "ing_pickle", amount = 2}
        },
        rewards = {
            {item = "resfood_baconlover", amount = 1}
        }
    },
    ["resfood_cheeseburger"] = {
        label = "Cheeseburger",
        time = 25,
        price = 1500,
        requires = {
            {item = "ing_bread", amount = 2},
            {item = "ing_meat", amount = 1},
            {item = "ing_tomato", amount = 1},
            {item = "ing_salad", amount = 1},
            {item = "ing_pickle", amount = 1}
        },
        rewards = {
            {item = "resfood_cheeseburger", amount = 1}
        }
    },
    ["resfood_doublecheeseburger"] = {
        label = "Double Cheeseburger",
        time = 35,
        price = 2500,
        requires = {
            {item = "ing_bread", amount = 2},
            {item = "ing_meat", amount = 2},
            {item = "ing_tomato", amount = 1},
            {item = "ing_salad", amount = 1},
            {item = "ing_pickle", amount = 1}
        },
        rewards = {
            {item = "resfood_doublecheeseburger", amount = 1}
        }
    },
    ["resfood_sandwich"] = {
        label = "Sandwich",
        time = 20,
        price = 1000,
        requires = {
            {item = "ing_bread", amount = 2},
            {item = "ing_tomato", amount = 1},
            {item = "ing_salad", amount = 1}
        },
        rewards = {
            {item = "resfood_sandwich", amount = 1}
        }
    },
    ["resfood_kebab"] = {
        label = "Kebab",
        time = 30,
        price = 1800,
        requires = {
            {item = "ing_bread", amount = 1},
            {item = "ing_meat", amount = 2},
            {item = "ing_salad", amount = 1},
            {item = "ing_tomato", amount = 1}
        },
        rewards = {
            {item = "resfood_kebab", amount = 1}
        }
    },

    -- Metzger Rezepte
    ["ing_meat"] = {
        label = "Verarbeitetes Fleisch",
        time = 25,
        price = 1000,
        requires = {
            {item = "farm_meat", amount = 2}
        },
        rewards = {
            {item = "ing_meat", amount = 1}
        }
    },
    ["resfood_burrito"] = {
        label = "Burrito",
        time = 30,
        price = 1500,
        requires = {
            {item = "ing_meat", amount = 1},
            {item = "ing_salad", amount = 1},
            {item = "ing_tomato", amount = 1}
        },
        rewards = {
            {item = "resfood_burrito", amount = 1}
        }
    },
    ["resfood_hotdog"] = {
        label = "Hotdog",
        time = 20,
        price = 1200,
        requires = {
            {item = "ing_bread", amount = 1},
            {item = "ing_meat", amount = 1},
            {item = "ing_mustard", amount = 1}
        },
        rewards = {
            {item = "resfood_hotdog", amount = 1}
        }
    },

    -- Schmelzerei Rezepte
    ["farm_copper_ingot"] = {
        label = "Kupferbarren",
        time = 40,
        price = 2000,
        requires = {
            {item = "farm_copper", amount = 3}
        },
        rewards = {
            {item = "farm_copper_ingot", amount = 1}
        }
    },
    ["farm_iron_ingot"] = {
        label = "Eisenbarren",
        time = 45,
        price = 2500,
        requires = {
            {item = "farm_iron", amount = 3}
        },
        rewards = {
            {item = "farm_iron_ingot", amount = 1}
        }
    },
    ["farm_gold_ingot"] = {
        label = "Goldbarren",
        time = 50,
        price = 3500,
        requires = {
            {item = "farm_gold", amount = 3}
        },
        rewards = {
            {item = "farm_gold_ingot", amount = 1}
        }
    },

    -- Fischverarbeitung Rezepte
    ["resfood_fishburger"] = {
        label = "Fischburger",
        time = 30,
        price = 1800,
        requires = {
            {item = "ing_bread", amount = 2},
            {item = "farm_salmon", amount = 1},
            {item = "ing_salad", amount = 1},
            {item = "ing_tomato", amount = 1}
        },
        rewards = {
            {item = "resfood_fishburger", amount = 1}
        }
    },
    ["fish_fillet"] = {
        label = "Fischfilet",
        time = 25,
        price = 1200,
        requires = {
            {item = "farm_salmon", amount = 1}
        },
        rewards = {
            {item = "fish_fillet", amount = 2}
        }
    },
    ["fish_package"] = {
        label = "Fischpaket",
        time = 35,
        price = 2000,
        requires = {
            {item = "farm_tuna", amount = 1},
            {item = "farm_salmon", amount = 1}
        },
        rewards = {
            {item = "fish_package", amount = 1}
        }
    }
}

return Recipes