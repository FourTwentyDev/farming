-- server/main.lua
ESX = exports["es_extended"]:getSharedObject()

-- Server-seitige Variablen
local activeOrders = {}

CreateThread(function()
    if Config.Settings.Debug then
        print("^2[DEBUG] Server script starting^7")
    end
    
    -- Datenbank initialisieren
    InitializeDatabase()
end)

-- Event Handler für Spieler-Belohnungen
RegisterNetEvent('farming:giveReward')
AddEventHandler('farming:giveReward', function(spotId, farmingType)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local spot = farmingType == 'static' 
        and FarmingConfig.StaticSpots[spotId] 
        or FarmingConfig.DynamicSpots[spotId]
    
    if not spot then 
        if Config.Settings.Debug then
            print("^1[ERROR] Invalid farming spot: " .. tostring(spotId) .. "^7")
        end
        return
    end
    
    -- Inventar-Check
    if Config.Settings.Inventory.CheckWeight then
        -- Wir prüfen erstmal mit der Minimalmenge
        local minAmount = type(spot.reward.amount) == "table" 
            and spot.reward.amount.min 
            or spot.reward.amount
            
        if not xPlayer.canCarryItem(spot.reward.item, minAmount) then
            TriggerClientEvent('esx:showNotification', source, _U('inventory_full'))
            return
        end
    end
    
    -- Zufällige Belohnungsmenge basierend auf min/max wenn konfiguriert
    local amount = type(spot.reward.amount) == "table"
        and math.random(spot.reward.amount.min, spot.reward.amount.max)
        or spot.reward.amount
    
    -- Chance-basierte Belohnung
    if spot.reward.chance and spot.reward.chance < 100 then
        if math.random(100) > spot.reward.chance then
            TriggerClientEvent('esx:showNotification', source, _U('no_luck'))
            return
        end
    end
    
    -- Belohnung geben
    xPlayer.addInventoryItem(spot.reward.item, amount)
    
    -- Benachrichtigung
    if spot.notification and spot.notification.success then
        TriggerClientEvent('esx:showNotification', source, spot.notification.success)
    else
        TriggerClientEvent('esx:showNotification', source, _U('collecting_success', spot.label))
    end
end)

-- Event Handler für Rezept-Labels
RegisterNetEvent('farming:getRecipeLabels')
AddEventHandler('farming:getRecipeLabels', function(recipes)
    local source = source
    local labeledRecipes = {}
    
    for recipeId, recipe in pairs(recipes) do
        local recipeCopy = json.decode(json.encode(recipe))
        
        for _, requirement in ipairs(recipeCopy.requires) do
            requirement.label = ESX.GetItemLabel(requirement.item)
        end
        
        for _, reward in ipairs(recipeCopy.rewards) do
            reward.label = ESX.GetItemLabel(reward.item)
        end
        
        labeledRecipes[recipeId] = recipeCopy
    end
    
    TriggerClientEvent('farming:receiveRecipeLabels', source, labeledRecipes)
end)

-- Hilfsfunktionen
function GetPlayerActiveOrders(identifier)
    local orders = {}
    for _, order in pairs(activeOrders) do
        if order.playerIdentifier == identifier then
            table.insert(orders, order)
        end
    end
    return orders
end

-- Export Funktionen
exports('GetActiveOrders', function()
    return activeOrders
end)