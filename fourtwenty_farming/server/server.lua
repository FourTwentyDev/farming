ESX = exports["es_extended"]:getSharedObject()
CreateThread(function()
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
end)

local function UpdatePlayerOrders(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.query('SELECT * FROM crafting_orders WHERE player_identifier = ? AND collected = FALSE',
        {xPlayer.identifier},
        function(result)
            TriggerClientEvent('farming:updateActiveOrders', source, result)
    end)
end

RegisterNetEvent('farming:startCrafting')
AddEventHandler('farming:startCrafting', function(recipeName, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local recipe = Recipes.List[recipeName]
    
    if not recipe then
        TriggerClientEvent('farming:craftingResult', source, false, 'Ungültiges Rezept!')
        return
    end
    
    -- Prüfe ob Spieler genug Geld hat
    local totalPrice = recipe.price * amount
    if totalPrice > 0 and xPlayer.getMoney() < totalPrice then
        TriggerClientEvent('farming:craftingResult', source, false, 'Du hast nicht genug Geld! Benötigt: $' .. totalPrice)
        return
    end
    
    MySQL.query('SELECT * FROM crafting_orders WHERE player_identifier = ? AND collected = FALSE', 
        {xPlayer.identifier}, 
        function(result)
            if #result > 0 then
                TriggerClientEvent('farming:craftingResult', source, false, 'Du hast bereits einen aktiven Auftrag!')
                return
            end
            
            local hasItems = true
            for _, item in ipairs(recipe.requires) do
                if xPlayer.getInventoryItem(item.item).count < (item.amount * amount) then
                    hasItems = false
                    break
                end
            end
            
            if not hasItems then
                TriggerClientEvent('farming:craftingResult', source, false, 'Du hast nicht genug Materialien!')
                return
            end
            
            -- Geld abziehen wenn Preis > 0
            if totalPrice > 0 then
                xPlayer.removeMoney(totalPrice)
            end
            
            -- Materialien entfernen
            for _, item in ipairs(recipe.requires) do
                xPlayer.removeInventoryItem(item.item, item.amount * amount)
            end
            
            local completionTime = os.time() + (recipe.time * amount)
            MySQL.insert('INSERT INTO crafting_orders (player_identifier, recipe_name, amount, start_time, completion_time) VALUES (?, ?, ?, NOW(), FROM_UNIXTIME(?))',
                {xPlayer.identifier, recipeName, amount, completionTime},
                function(orderId)
                    TriggerClientEvent('farming:craftingResult', source, true, 'Crafting gestartet!', orderId)
                    UpdatePlayerOrders(source)
                end)
    end)
end)

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

function GetPlayerInventory(xPlayer)
    local inventory = {}
    for _, item in pairs(xPlayer.getInventory()) do
        if item.count > 0 then
            inventory[item.name] = {
                count = item.count,
                label = item.label
            }
        end
    end
    return inventory
end

-- Modifiziere die Rezepte mit Item-Labels
CreateThread(function()
    for recipeName, recipe in pairs(Recipes.List) do
        -- Füge Labels zu den Requirements hinzu
        for _, req in ipairs(recipe.requires) do
            req.label = GetItemLabel(req.item)
        end
        -- Füge Labels zu den Rewards hinzu
        for _, reward in ipairs(recipe.rewards) do
            reward.label = GetItemLabel(reward.item)
        end
    end
end)

function GetItemLabel(itemName)
    local item = ESX.GetItemLabel(itemName)
    return item or itemName
end

RegisterNetEvent('farming:collectOrder')
AddEventHandler('farming:collectOrder', function(orderId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.query('SELECT *, UNIX_TIMESTAMP(completion_time) AS completion_unix FROM crafting_orders WHERE id = ? AND player_identifier = ? AND collected = FALSE',
    {orderId, xPlayer.identifier},
    function(result)
        if #result == 0 then
            TriggerClientEvent('farming:notify', source, 'Auftrag nicht gefunden!')
            return
        end
        
        local order = result[1]
        if os.time() < order.completion_unix then
            print(os.time())
            print(order.completion_unix)
            TriggerClientEvent('farming:notify', source, 'Der Auftrag ist noch nicht fertig!')
            return
        end
        
        local recipe = Recipes.List[order.recipe_name]
        if not recipe then
            TriggerClientEvent('farming:notify', source, 'Rezept nicht gefunden!')
            return
        end
        
        local canCarryAll = true
        for _, reward in ipairs(recipe.rewards) do
            if not xPlayer.canCarryItem(reward.item, reward.amount * order.amount) then
                canCarryAll = false
                break
            end
        end

        if not canCarryAll then
            TriggerClientEvent('farming:notify', source, 'Du kannst nicht so viel tragen! Mach zuerst Platz im Inventar.')
            return
        end
        
        for _, reward in ipairs(recipe.rewards) do
            xPlayer.addInventoryItem(reward.item, reward.amount * order.amount)
        end
        
        MySQL.update('UPDATE crafting_orders SET collected = TRUE WHERE id = ?', {orderId},
            function(affected)
                if affected > 0 then
                    UpdatePlayerOrders(source)
                    TriggerClientEvent('farming:notify', source, 'Auftrag erfolgreich abgeholt!')
                end
            end)
    end)
end)

RegisterNetEvent('farming:getActiveOrders')
AddEventHandler('farming:getActiveOrders', function()
    UpdatePlayerOrders(source)
end)