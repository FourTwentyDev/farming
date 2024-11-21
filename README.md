# FourTwenty Farming - Configuration Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Accessible Files](#accessible-files)
3. [Configuration Guide](#configuration-guide)
   - [Main Configuration](#main-configuration)
   - [Farming Configuration](#farming-configuration)
   - [Processing Configuration](#processing-configuration)
   - [Recipes Configuration](#recipes-configuration)
4. [Localization](#localization)
5. [Installation](#installation)
6. [Support](#support)

## Introduction
This guide will help you configure the FourTwenty Farming script. The script uses FiveM's Asset Escrow system to protect core functionality while allowing customization through configuration files.

## Accessible Files
The following files are accessible and can be edited:
```
📁 shared/
├── 📁 configs/
│   ├── 📄 main_config.lua
│   ├── 📄 farming_config.lua
│   └── 📄 processing_config.lua
├── 📄 locale.lua
└── 📄 recipes.lua
```

All other files are protected by Asset Escrow and cannot be modified.

## Configuration Guide

### Main Configuration
Location: `shared/configs/main_config.lua`

```lua
Config = {
    Settings = {
        Debug = false,        -- Enable/disable debug mode for detailed console output
        Locale = "en",       -- Default language (en, de available)
        
        -- Notification Settings
        Notifications = {
            Position = "top-left",    -- Notification position on screen
            DefaultDuration = 3000,   -- Duration in milliseconds
            UseCustom = false,        -- Use custom notification system
            DefaultDuration = 3000    -- How long notifications show
        },
        
        -- Marker Settings
        DefaultMarker = {
            Type = 1,                 -- Marker type (see GTA V marker types)
            Size = vector3(1.0, 1.0, 1.0),
            Color = {r = 0, g = 255, b = 0, a = 100},
            BobUpAndDown = false,
            FaceCamera = false,
            Rotate = false,
            DrawDistance = 20.0,
            InteractionDistance = 2.0
        },
        
        -- Blip Settings
        DefaultBlip = {
            Scale = 0.8,
            Display = 4,
            ShortRange = true
        },
        
        -- Gameplay Settings -> for future release
        Gameplay = {
            UseSkillCheck = false,    -- Enable skill check minigame
            UseProgressBars = true,   -- Show progress bars during actions
            AllowCancellation = true, -- Allow canceling collection
            PreventMovement = true,   -- Lock player movement during collection
            RequireEmptyHands = true  -- Must have empty hands to collect
        },
        
        -- Inventory Settings
        Inventory = {
            CheckWeight = true,       -- Enable inventory weight system
            UseCustomInventory = false, -- Use custom inventory system
            MaxItemStack = 100        -- Maximum items per stack
        }
    },

    -- Update Intervals (in milliseconds)
    UpdateIntervals = {
        MainLoop = 1000,      -- Main script loop
        NearbyCheck = 500,    -- Check for nearby farming spots
        ObjectSync = 2000,    -- Dynamic object synchronization
        InventoryUpdate = 5000 -- Inventory refresh rate
    }
}
```

### Farming Configuration
Location: `shared/configs/farming_config.lua`

```lua
FarmingConfig = {
    Types = {
        STATIC_AREA = "static_area",      -- Farm within radius
        STATIC_SPOTS = "static_spots",    -- Farm at specific points
        DYNAMIC = "dynamic"               -- Farm spawned objects
    },

    -- Static Farming Spots
    StaticSpots = {
        ["spot_name"] = {
            enabled = true,              -- Enable/disable this spot
            label = "Spot Name",         -- Display name
            type = "static_area",        -- Farming type
            coords = vector3(x, y, z),   -- Location coordinates
            farmingRadius = 25.0,        -- Collection radius (static_area only)
            spots = {                    -- For static_spots type
                {coords = vector3(x, y, z)},
                {coords = vector3(x, y, z)}
            },
            rewards = {
                {
                    item = "item_name",
                    amount = {min = 1, max = 2},  -- Random amount range
                    chance = 60                   -- Drop chance percentage
                }
            },
            marker = {
                type = 1,
                size = vector3(1.0, 1.0, 1.0),
                color = {r = 0, g = 128, b = 255, a = 100},
                showArea = true
            },
            blip = {                    -- Optional map blip
                sprite = 68,
                color = 3,
                scale = 0.8,
                label = "Farming Spot"
            },
            animation = {               -- Collection animation
                dict = "mini@tennis",
                anim = "forehand_ts_md_far",
                flag = 1,
                duration = 3000
            },
            cooldown = 5000,           -- Time between collections
            requirements = {
                job = false,           -- Required job or false
                item = false           -- Required item or false
            }
        }
    },

    -- Dynamic Farming Spots
    DynamicSpots = {
        ["spot_name"] = {
            enabled = true,
            label = "Dynamic Spot",
            coords = vector3(x, y, z),
            objects = {
                model = "prop_name",    -- Object model name
                amount = 6,             -- Number of objects
                radius = 20.0,          -- Spawn radius
                minDistance = 4.0,      -- Min distance between objects
                respawnTime = 240,      -- Seconds until respawn
                groundOffset = -0.5     -- Height adjustment
            },
            collection = {
                animation = {
                    dict = "melee@large_wpn@streamed_core",
                    anim = "ground_attack_on_spot",
                    flag = 1,
                    duration = 5000
                },
                radius = 2.5           -- Collection range
            }
        }
    }
}
```

### Processing Configuration
Location: `shared/configs/processing_config.lua`

```lua
ProcessingConfig = {
    Locations = {
        ["location_name"] = {
            enabled = true,
            label = "Processing Location",
            coords = vector3(x, y, z),
            blip = {
                sprite = 106,
                color = 1,
                scale = 0.8,
                label = "Processing"
            },
            marker = {
                type = 1,
                size = vector3(1.0, 1.0, 1.0),
                color = {r = 255, g = 165, b = 0, a = 100}
            },
            allowedRecipes = {          -- Recipes available at this location
                "recipe_name1",
                "recipe_name2"
            },
            requirements = {
                job = false,            -- Required job
                item = false            -- Required item
            },
            workstation = {
                type = "kitchen",       -- Workstation type
                animation = {
                    dict = "anim@heists@prison_heiststation@cop_reactions",
                    anim = "cop_b_idle",
                    flag = 1
                }
            }
        }
    }
}
```

### Recipes Configuration
Location: `shared/recipes.lua`

```lua
Recipes = {
    List = {
        ["recipe_name"] = {
            label = "Recipe Display Name",
            time = 30,                -- Processing time in seconds
            price = 2000,             -- Processing cost
            requires = {              -- Required items
                {item = "item_name", amount = 2},
                {item = "item_name2", amount = 1}
            },
            rewards = {               -- Output items
                {item = "result_item", amount = 1}
            }
        }
    }
}
```

## Localization
Location: `shared/locale.lua`

Add or modify translations:
```lua
Locales["en"] = {
    ["press_to_collect"] = "Press ~INPUT_CONTEXT~ to collect",
    ["inventory_full"] = "Your inventory is full!",
    ["cooldown_active"] = "You must wait before collecting again!",
    ["missing_required_item"] = "You need %s to collect this!",
    ["wrong_job"] = "You don't have the right job for this!",
    ["hands_not_empty"] = "Your hands must be empty!",
    ["no_luck"] = "You didn't find anything this time!",
    ["item_received"] = "Received %dx %s",
    ["skill_increased"] = "%s skill increased by %d XP"
}
```

## Installation

1. Import the provided SQL files to your database:
```sql
CREATE TABLE IF NOT EXISTS `player_skills` (
    `identifier` varchar(60) NOT NULL,
    `skill` varchar(50) NOT NULL,
    `xp` int(11) NOT NULL DEFAULT '0',
    PRIMARY KEY (`identifier`,`skill`)
);

CREATE TABLE IF NOT EXISTS `crafting_orders` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `player_identifier` varchar(60) NOT NULL,
    `recipe_name` varchar(50) NOT NULL,
    `amount` int(11) NOT NULL,
    `start_time` datetime NOT NULL,
    `completion_time` datetime NOT NULL,
    `collected` tinyint(1) NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`)
);
```

2. Add to your resources folder
3. Add to server.cfg:
```cfg
ensure fourtwenty_farming
```
4. Configure the accessible files according to your needs
5. Restart your server

## Support

For additional support and detailed setup instructions:
- Join our Discord: [Discord Server](https://discord.gg/fourtwenty)
- All configuration questions and script support are handled through our Discord
- Please read through this entire guide before asking questions
- Make sure to check the #announcements channel for updates and changes

---

**Note**: Always backup your configuration files before making changes. If you encounter any issues or need clarification on any settings, our support team is available on Discord to help!
