# FiveM Farming & Crafting System 🌾
A sophisticated farming and crafting system featuring dynamic object spawning, smart resource collection, and a powerful crafting queue system with real-time NUI interface.

## Unique Features 🚀

### Advanced Resource Collection
- **Dynamic Object System** 🌳
  - Smart object spawning with ground detection
  - Automatic object cleanup when players leave area
  - Collision prevention between objects
  - Individual object states and respawn timers
  - Configurable spawn patterns and densities
  - Visual object highlighting for collectable items

- **Multi-Mode Farming** 🎯
  - Area-based collection zones with visual markers
  - Individual collection points with specific coordinates
  - Hybrid zones supporting both methods simultaneously
  - Custom animation support per farming type
  - Individual cooldown systems for each spot

### Smart Processing System 🏭
- **Location-Based Processing**
  - Different recipes per location type
  - Processor-specific crafting restrictions
  - Custom marker and blip configurations
  - Distance-based interaction system

- **Advanced Queuing System**
  - Multiple orders per player
  - Real-time order progress tracking
  - Order persistence through server restarts
  - Automatic cleanup of old orders
  - Partial refund system for cancellations

### Real-Time NUI Interface 💻
- **Modern React-Based UI**
  - Real-time inventory synchronization
  - Dynamic recipe filtering system
  - Live progress tracking
  - Responsive design for all screen sizes
  - Dark theme optimized for FiveM

- **Smart Resource Management**
  - Live inventory checks
  - Real-time material requirement updates
  - Dynamic crafting button states
  - Visual feedback for all actions

### Additional Advanced Features
- **Multi-Language Support** 🌍
  - Full support for English, German and Russian
  - Easy addition of new languages
  - Dynamic language switching
  - Server-side locale configuration

- **Performance Optimization** ⚡
  - Smart distance checks
  - Efficient object spawning
  - Optimized database queries
  - Minimal resource usage

## Dependencies 📦
- [es_extended](https://github.com/esx-framework/esx-legacy)
- [oxmysql](https://github.com/overextended/oxmysql) or mysql-async
- FiveM Server Build 2802 or higher

## Installation 💿

1. Clone this repository into your server's `resources` directory
```bash
cd resources
git clone https://github.com/FourTwentyDev/farming
```

2. Import the included SQL file
```bash
mysql -u your_username -p your_database < farming.sql
```

3. Add to your `server.cfg`
```lua
ensure farming
```

## Detailed Configuration 🔧

### Dynamic Farming Example
```lua
FarmingConfig.DynamicSpots = {
    apple_orchard = {
        enabled = true,
        label = "Apple Orchard",
        coords = vector3(-1790.75, 2214.36, 89.43),
        objects = {
            model = "prop_apple_01",
            amount = 15,            -- Spawn 15 apple trees
            radius = 25.0,         -- In a 25.0 unit radius
            minDistance = 3.0,     -- Minimum 3.0 units between trees
            groundOffset = 0.2,    -- Slight offset from ground
            respawnTime = 300      -- 5 minutes respawn time
        },
        collection = {
            radius = 2.0,          -- Collection radius around each tree
            animation = {
                dict = "mini@repair",
                anim = "fixing_a_ped",
                flag = 49,
                duration = 5000
            }
        },
        reward = {
            item = "apple",
            amount = {min = 1, max = 3},  -- Random amount between 1-3
            chance = 85                   -- 85% success chance
        }
    }
}
```

### Processing Location Example
```lua
ProcessingConfig.Locations = {
    bakery_central = {
        enabled = true,
        label = "Downtown Bakery",
        coords = vector3(382.89, -993.24, 29.42),
        blip = {
            sprite = 536,
            color = 46,
            scale = 0.8
        },
        marker = {
            type = 1,
            size = {x = 1.5, y = 1.5, z = 1.0},
            color = {r = 50, g = 200, b = 50, a = 100}
        },
        allowedRecipes = {"bread", "cake", "pastry"},
        requirements = {
            job = "baker",           -- Optional job requirement
            item = "recipe_book"     -- Optional item requirement
        }
    }
}
```

### Recipe Configuration Example
```lua
Recipes.List = {
    artisan_bread = {
        label = "Artisan Bread",
        category = "bakery",
        time = 180,                -- 3 minutes crafting time
        price = 150,               -- Crafting cost
        requires = {
            {item = "premium_flour", amount = 3},
            {item = "yeast", amount = 1},
            {item = "salt", amount = 1},
            {item = "water", amount = 2}
        },
        rewards = {
            {item = "artisan_bread", amount = 2}
        }
    }
}
```

## Database Design 📚
The system uses a sophisticated database structure to track all farming and crafting activities:

### Orders Table
```sql
CREATE TABLE IF NOT EXISTS crafting_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_identifier VARCHAR(50),
    recipe_name VARCHAR(50),
    amount INT,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_time TIMESTAMP,
    collected BOOLEAN DEFAULT FALSE,
    cancelled BOOLEAN DEFAULT FALSE,
    refunded BOOLEAN DEFAULT FALSE,
    INDEX idx_player_status (player_identifier, collected),
    INDEX idx_completion (completion_time)
);
```

### Farming Statistics
```sql
CREATE TABLE IF NOT EXISTS farming_stats (
    player_identifier VARCHAR(50),
    spot_id VARCHAR(50),
    total_collected INT DEFAULT 0,
    last_collection TIMESTAMP,
    success_rate FLOAT DEFAULT 0.0,
    PRIMARY KEY (player_identifier, spot_id)
);
```

## Advanced Usage Examples 🎮

### Client Events
```lua
-- Start crafting with custom amount
TriggerEvent('farming:startCrafting', 'artisan_bread', 5)

-- Collect completed order
TriggerEvent('farming:collectOrder', orderId)

-- Update inventory display
TriggerEvent('farming:updateInventory', {inventory = playerInventory})
```

### Server Events
```lua
-- Give farming reward with chance calculation
TriggerEvent('farming:giveReward', playerId, spotId, 'dynamic')

-- Process recipe labels
TriggerEvent('farming:getRecipeLabels', recipes)
```

### Exports Usage
```lua
-- Check if player is currently collecting
local isCollecting = exports['farming']:getIsCollecting()

-- Get all spawned objects in area
local objects = exports['farming']:getSpawnedObjects()

-- Get player's active orders
local orders = exports['farming']:GetPlayerOrders(identifier)
```

## Support & Links 💡
1. Join our [Discord](https://discord.gg/fourtwenty)
2. Visit [FourTwenty Development](https://fourtwenty.dev)
3. Create an issue on [GitHub](https://github.com/FourTwentyDev/farming)

## License 📄
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
Made with 💚 by [FourTwenty Development](https://fourtwenty.dev)

### Latest Updates
- Added Russian language support
- Improved dynamic object spawning system
- Enhanced order management system
- Added detailed farming statistics
- Implemented smart cooldown system
