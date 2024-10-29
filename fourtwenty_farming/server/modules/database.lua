-- server/modules/database.lua

function InitializeDatabase()
    CreateThread(function()
        -- Crafting Orders Tabelle
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS crafting_orders (
                id INT AUTO_INCREMENT PRIMARY KEY,
                player_identifier VARCHAR(50),
                recipe_name VARCHAR(50),
                amount INT,
                start_time TIMESTAMP,
                completion_time TIMESTAMP,
                collected BOOLEAN DEFAULT FALSE
            )
        ]])
        
        -- Optional: Farming Stats Tabelle
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS farming_stats (
                player_identifier VARCHAR(50),
                spot_id VARCHAR(50),
                total_collected INT DEFAULT 0,
                last_collection TIMESTAMP,
                PRIMARY KEY (player_identifier, spot_id)
            )
        ]])
        
        if Config.Settings.Debug then
            print("^2[DEBUG] Database tables initialized^7")
        end
    end)
end

-- Aktive Aufträge aus der Datenbank laden
function LoadActiveOrders()
    MySQL.query('SELECT * FROM crafting_orders WHERE collected = FALSE',
    {},
    function(result)
        if result then
            for _, order in ipairs(result) do
                activeOrders[order.id] = {
                    id = order.id,
                    playerIdentifier = order.player_identifier,
                    recipe = order.recipe_name,
                    amount = order.amount,
                    startTime = order.start_time,
                    completionTime = order.completion_time,
                    collected = false
                }
            end
        end
    end)
end

-- Farming Stats aktualisieren
function UpdateFarmingStats(playerIdentifier, spotId, amount)
    MySQL.query('INSERT INTO farming_stats (player_identifier, spot_id, total_collected, last_collection) VALUES (?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE total_collected = total_collected + ?, last_collection = NOW()',
    {playerIdentifier, spotId, amount, amount})
end

-- Farming Stats abrufen
function GetPlayerFarmingStats(playerIdentifier, callback)
    MySQL.query('SELECT * FROM farming_stats WHERE player_identifier = ?',
    {playerIdentifier},
    function(result)
        callback(result)
    end)
end

-- Export Funktionen
exports('GetFarmingStats', GetPlayerFarmingStats)
exports('UpdateStats', UpdateFarmingStats)