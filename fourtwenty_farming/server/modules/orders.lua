-- server/modules/orders.lua

-- Auftrag starten
RegisterNetEvent('farming:startCrafting')
AddEventHandler('farming:startCrafting', function(recipeName, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local recipe = Recipes.List[recipeName]
    
    if not recipe then
        TriggerClientEvent('farming:craftingResult', source, false, _U('invalid_recipe'))
        return
    end
    
    -- Preis berechnen
    local totalPrice = recipe.price * amount
    if totalPrice > 0 and xPlayer.getMoney() < totalPrice then
        TriggerClientEvent('farming:craftingResult', source, false, _U('not_enough_money', totalPrice))
        return
    end
    
    -- Prüfen ob bereits ein aktiver Auftrag existiert
    MySQL.query('SELECT * FROM crafting_orders WHERE player_identifier = ? AND collected = FALSE', 
    {xPlayer.identifier}, 
    function(result)
        if #result > 0 then
            TriggerClientEvent('farming:craftingResult', source, false, _U('active_order_exists'))
            return
        end
        
        -- Materialien prüfen
        local hasItems = true
        for _, item in ipairs(recipe.requires) do
            if xPlayer.getInventoryItem(item.item).count < (item.amount * amount) then
                hasItems = false
                break
            end
        end
        
        if not hasItems then
            TriggerClientEvent('farming:craftingResult', source, false, _U('not_enough_materials'))
            return
        end
        
        -- Geld abziehen
        if totalPrice > 0 then
            xPlayer.removeMoney(totalPrice)
        end
        
        -- Materialien entfernen
        for _, item in ipairs(recipe.requires) do
            xPlayer.removeInventoryItem(item.item, item.amount * amount)
        end
        
        -- Fertigstellungszeit berechnen
        local completionTime = os.time() + (recipe.time * amount)
        
        -- Auftrag in Datenbank eintragen
        MySQL.insert('INSERT INTO crafting_orders (player_identifier, recipe_name, amount, start_time, completion_time) VALUES (?, ?, ?, NOW(), FROM_UNIXTIME(?))',
        {xPlayer.identifier, recipeName, amount, completionTime},
        function(orderId)
            TriggerClientEvent('farming:craftingResult', source, true, _U('crafting_started'), orderId)
            UpdatePlayerOrders(source)
        end)
    end)
end)

-- Auftrag abholen
RegisterNetEvent('farming:collectOrder')
AddEventHandler('farming:collectOrder', function(orderId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.query('SELECT *, UNIX_TIMESTAMP(completion_time) AS completion_unix FROM crafting_orders WHERE id = ? AND player_identifier = ? AND collected = FALSE',
    {orderId, xPlayer.identifier},
    function(result)
        if #result == 0 then
            TriggerClientEvent('esx:showNotification', source, _U('order_not_found'))
            return
        end
        
        local order = result[1]
        if os.time() < order.completion_unix then
            TriggerClientEvent('esx:showNotification', source, _U('order_not_complete'))
            return
        end
        
        local recipe = Recipes.List[order.recipe_name]
        if not recipe then
            TriggerClientEvent('esx:showNotification', source, _U('recipe_not_found'))
            return
        end
        
        -- Prüfen ob Spieler alle Items tragen kann
        local canCarryAll = true
        for _, reward in ipairs(recipe.rewards) do
            if not xPlayer.canCarryItem(reward.item, reward.amount * order.amount) then
                canCarryAll = false
                break
            end
        end
        
        if not canCarryAll then
            TriggerClientEvent('esx:showNotification', source, _U('inventory_full'))
            return
        end
        
        -- Belohnungen geben
        for _, reward in ipairs(recipe.rewards) do
            xPlayer.addInventoryItem(reward.item, reward.amount * order.amount)
        end
        
        -- Auftrag als abgeholt markieren
        MySQL.update('UPDATE crafting_orders SET collected = TRUE WHERE id = ?', {orderId},
            function(affected)
                if affected > 0 then
                    UpdatePlayerOrders(source)
                    TriggerClientEvent('esx:showNotification', source, _U('order_collected'))
                    
                    -- XP für Verarbeitung geben wenn Skills aktiviert
                    if FarmingConfig.Skills and FarmingConfig.Skills.enabled then
                        local xpGain = CalculateProcessingXP(order.recipe_name, order.amount)
                        AddPlayerXP(xPlayer.identifier, 'processing', xpGain)
                    end
                end
            end)
    end)
end)



function UpdatePlayerOrders(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    MySQL.query('SELECT *, UNIX_TIMESTAMP(start_time) as start_unix, UNIX_TIMESTAMP(completion_time) as completion_unix FROM crafting_orders WHERE player_identifier = ? AND collected = FALSE',
        {xPlayer.identifier},
        function(result)
            -- Aufträge formatieren
            local formattedOrders = {}
            for _, order in ipairs(result) do
                local recipe = Recipes.List[order.recipe_name]
                if recipe then
                    -- Formatiere die Zeiten in Millisekunden für JavaScript
                    local startTime = order.start_unix * 1000
                    local completionTime = order.completion_unix * 1000
                    local timeRemaining = math.max(0, order.completion_unix - os.time())
                    
                    table.insert(formattedOrders, {
                        id = order.id,
                        recipe_name = order.recipe_name, -- Frontend erwartet recipe_name statt recipe
                        amount = order.amount,
                        start_time = os.date("!%Y-%m-%dT%H:%M:%SZ", order.start_unix), -- ISO 8601 Format
                        completion_time = os.date("!%Y-%m-%dT%H:%M:%SZ", order.completion_unix), -- ISO 8601 Format
                        recipeLabel = recipe.label,
                        rewards = recipe.rewards,
                        completed = timeRemaining <= 0,
                        pending = false
                    })
                end
            end
            
            if Config.Settings.Debug then
                print("^3[DEBUG] Sending formatted orders to client:", json.encode(formattedOrders))
            end
            
            TriggerClientEvent('farming:updateActiveOrders', source, formattedOrders)
        end)
end

-- Periodische Auftragsaktualisierung
CreateThread(function()
    while true do
        Wait(10000) -- Alle 10 Sekunden
        
        -- Alle Spieler durchgehen
        local xPlayers = ESX.GetPlayers()
        for _, playerId in ipairs(xPlayers) do
            UpdatePlayerOrders(playerId)
        end
    end
end)

-- Auftrag abbrechen (optional, wenn in Config aktiviert)
RegisterNetEvent('farming:cancelOrder')
AddEventHandler('farming:cancelOrder', function(orderId)
    if not ProcessingConfig.Settings.AllowOrderCancellation then return end
    
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.query('SELECT * FROM crafting_orders WHERE id = ? AND player_identifier = ? AND collected = FALSE',
    {orderId, xPlayer.identifier},
    function(result)
        if #result == 0 then
            TriggerClientEvent('esx:showNotification', source, _U('order_not_found'))
            return
        end
        
        local order = result[1]
        local recipe = Recipes.List[order.recipe_name]
        if not recipe then return end
        
        -- Materialien teilweise zurückerstatten
        if ProcessingConfig.Settings.RefundOnCancel > 0 then
            local refundPercentage = ProcessingConfig.Settings.RefundOnCancel / 100
            for _, item in ipairs(recipe.requires) do
                local refundAmount = math.floor(item.amount * order.amount * refundPercentage)
                if refundAmount > 0 then
                    xPlayer.addInventoryItem(item.item, refundAmount)
                end
            end
            
            -- Geld teilweise zurückerstatten
            if recipe.price then
                local refundMoney = math.floor(recipe.price * order.amount * refundPercentage)
                if refundMoney > 0 then
                    xPlayer.addMoney(refundMoney)
                end
            end
        end
        
        -- Auftrag löschen
        MySQL.update('DELETE FROM crafting_orders WHERE id = ?', {orderId},
            function(affected)
                if affected > 0 then
                    UpdatePlayerOrders(source)
                    TriggerClientEvent('esx:showNotification', source, _U('order_cancelled'))
                end
            end)
    end)
end)

-- XP für Verarbeitung berechnen
function CalculateProcessingXP(recipeName, amount)
    local recipe = Recipes.List[recipeName]
    if not recipe then return 0 end
    
    local baseXP = 20 -- Basis XP pro Verarbeitung
    local complexity = #recipe.requires -- Komplexität basierend auf Anzahl der Materialien
    
    return math.floor(baseXP * complexity * amount)
end

-- Alte Aufträge aufräumen
CreateThread(function()
    while true do
        Wait(3600000) -- Stündliche Überprüfung
        
        -- Aufträge älter als 24 Stunden löschen
        MySQL.update([[
            DELETE FROM crafting_orders 
            WHERE collected = TRUE 
            AND completion_time < DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ]])
        
        if Config.Settings.Debug then
            print("^2[DEBUG] Cleaned up old crafting orders^7")
        end
    end
end)

-- Rezept-Labels abrufen
RegisterNetEvent('farming:getRecipeLabels')
AddEventHandler('farming:getRecipeLabels', function(recipes)
    local source = source
    local labeledRecipes = {}
    
    for recipeId, recipe in pairs(recipes) do
        -- Deep copy des Rezepts erstellen
        local recipeCopy = json.decode(json.encode(recipe))
        
        -- Labels für required items hinzufügen
        for _, requirement in ipairs(recipeCopy.requires) do
            requirement.label = ESX.GetItemLabel(requirement.item)
        end
        
        -- Labels für reward items hinzufügen
        for _, reward in ipairs(recipeCopy.rewards) do
            reward.label = ESX.GetItemLabel(reward.item)
        end
        
        labeledRecipes[recipeId] = recipeCopy
    end
    
    TriggerClientEvent('farming:receiveRecipeLabels', source, labeledRecipes)
end)

-- Export Funktionen
exports('GetPlayerOrders', function(identifier)
    return MySQL.Sync.fetchAll('SELECT * FROM crafting_orders WHERE player_identifier = ? AND collected = FALSE', {identifier})
end)

exports('HasActiveOrder', function(identifier)
    local result = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM crafting_orders WHERE player_identifier = ? AND collected = FALSE', {identifier})
    return result > 0
end)

exports('CancelOrder', function(orderId, identifier)
    return MySQL.Sync.execute('DELETE FROM crafting_orders WHERE id = ? AND player_identifier = ?', {orderId, identifier})
end)

exports('GetOrderDetails', function(orderId)
    return MySQL.Sync.fetchAll('SELECT * FROM crafting_orders WHERE id = ?', {orderId})[1]
end)