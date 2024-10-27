# FiveM Farming & Crafting System 🌾

A comprehensive farming and crafting system for FiveM servers featuring resource collection, processing spots, and a sophisticated crafting queue system.

## Features 🚜

- **Resource Collection**: 
  - Multiple farming spots across the map
  - Custom animations for gathering
  - Configurable coordinates and resource types
  - Blip system for easy location finding

- **Processing Locations**: 
  - Multiple processing spots for different crafting types
  - Custom blips with different colors and sprites
  - Location-specific recipe lists
  - Visual markers for easy identification
  - Distance-based interaction system

- **Advanced Crafting System**: 
  - Recipe-based crafting with multiple ingredients
  - Category-based recipe filtering
  - Real-time crafting progress
  - Queue system for multiple orders
  - Visual progress tracking
  - Custom crafting durations
  - Resource validation
  - Price system for recipes

- **Modern UI System**: 
  - Dark themed interface
  - Recipe cards with detailed information
  - Real-time inventory tracking
  - Progress bars for material requirements
  - Dynamic order status updates
  - Responsive design

- **Inventory Management**: 
  - Real-time inventory updates
  - Item weight system integration
  - Custom item labels
  - Stack size validation
  - Full ESX integration

## Dependencies 📦

- ESX Framework
- MySQL-Async or OxMySQL
- FiveM Server Build 2802 or higher

## Installation 💿

1. Clone this repository into your server's `resources` directory
```bash
cd resources
git clone https://github.com/FourTwentyDev/farming
```
2. Import the included SQL file to your database
```bash
mysql -u your_username -p your_database < farming.sql
```
3. Add `ensure fourtwenty_farming` to your `server.cfg`
4. Configure the script using the `config.lua` file

## Configuration 🔧

### Farming Spots Configuration
```lua
Config.FarmingSpots = {
    wheat = {
        coords = vector3(x, y, z),
        label = "Wheat Field",
        animation = "WORLD_HUMAN_GARDENER_PLANT",
        blip = {sprite = 514, color = 2}
    }
}
```

### Processing Spots Configuration
```lua
Config.ProcessingSpots = {
    bakery = {
        coords = vector3(x, y, z),
        label = "Bakery",
        blip = {sprite = 536, color = 46},
        allowedRecipes = {"bread", "cake", "pastry"}
    }
}
```

### Recipe Configuration
```lua
Recipes.List = {
    bread = {
        label = "Fresh Bread",
        category = "bakery",
        time = 30,
        price = 50,
        requires = {
            {item = "flour", amount = 2},
            {item = "water", amount = 1}
        },
        rewards = {
            {item = "bread", amount = 1}
        }
    }
}
```

## Database Structure 📚

The script uses the following table structure:

```sql
CREATE TABLE IF NOT EXISTS crafting_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_identifier VARCHAR(50),
    recipe_name VARCHAR(50),
    amount INT,
    start_time TIMESTAMP,
    completion_time TIMESTAMP,
    collected BOOLEAN DEFAULT FALSE
);
```

## Client Events 🎮

- `farming:craftingResult` - Triggered when crafting starts/fails
- `farming:updateActiveOrders` - Updates the order list
- `farming:receiveRecipeLabels` - Receives recipe data with labels

## Server Events 🖥️

- `farming:startCrafting` - Starts the crafting process
- `farming:collectOrder` - Collects completed orders
- `farming:getActiveOrders` - Retrieves active orders
- `farming:giveItem` - Gives collected items to player

## Support 💡

For support, please:
1. Join our [Discord](https://discord.gg/fourtwenty)
2. Visit our website: [www.fourtwenty.dev](https://fourtwenty.dev)
3. Create an issue on GitHub

## License 📄

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---
Made with ❤️ by [FourTwentyDev](https://fourtwenty.dev)
