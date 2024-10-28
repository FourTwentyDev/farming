Config = {}

Config.Locale = 'en' -- or 'en', or custom created

Config.FarmingSpots = {
    ["wheat"] = {
        label = "Weizen",
        coords = vector3(2832.9, 4569.8, 46.5),
        item = "wheat",
        animation = "WORLD_HUMAN_GARDENER_PLANT"
    },
    ["water"] = {
        label = "Wasser",
        coords = vector3(1500.2, 3800.5, 30.2),
        item = "water",
        animation = "WORLD_HUMAN_BUCKET_FILL"
    }
}

Config.ProcessingSpots = {
    ["baker"] = {
        label = "Bäckerei",
        coords = vector3(374.5, -827.3, 29.3),
        blip = {
            sprite = 473,
            color = 5
        },
        allowedRecipes = {"dough", "bread"}
    },
    ["mill"] = {
        label = "Mühle",
        coords = vector3(2800.5, 4569.8, 46.5),
        blip = {
            sprite = 475,
            color = 21
        },
        allowedRecipes = {"burger"} 
    }
}