-- recipes.lua
Recipes = {}

Recipes.List = {
    ["flour"] = {
        label = "Aus DJ wird Kokain Bruda",
        time = 20,
        price = 1500, -- Kostet 1500$
        requires = {
            {item = "ing_salad", amount = 3}
        },
        rewards = {
            {item = "food_burger", amount = 1}
        }
    },
    ["dough"] = {
        label = "Teig",
        time = 30,
        price = 0, -- Kostet nichts
        requires = {
            {item = "flour", amount = 2},
            {item = "water", amount = 1}
        },
        rewards = {
            {item = "dough", amount = 1}
        }
    },
    ["bread"] = {
        label = "Brot",
        time = 45,
        price = 250, -- Kostet 250$
        requires = {
            {item = "dough", amount = 1}
        },
        rewards = {
            {item = "bread", amount = 2}
        }
    }
}