-- client.lua
print("^2[DEBUG] Client script starting^7")

local ESX = nil
print('^2[FARMING] Client script loading...^7')

local ESX = exports['es_extended']:getSharedObject()

-- Test Command
RegisterCommand('farmtest', function(source, args)
    print('^2[FARMING] Test command executed^7')
    ESX.ShowNotification('Farming test command executed!')
end, false)

-- Basic Event Handler
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    print('^2[FARMING] Player loaded^7')
end)

CreateThread(function()
    while true do
        print('^2[FARMING] Thread running^7')
        Wait(10000) -- Print alle 10 Sekunden
    end
end)
-- ESX laden mit Debug
CreateThread(function()
    print("^2[DEBUG] Waiting for ESX^7")
    ESX = exports['es_extended']:getSharedObject()
    print("^2[DEBUG] ESX loaded^7")
end)

-- Blips erstellen mit Debug
CreateThread(function()
    Wait(2000) -- Warte bis ESX und alles andere geladen ist
    print("^2[DEBUG] Starting Blip creation^7")
    
    if not Config then
        print("^1[ERROR] Config is nil!^7")
        return
    end
    
    if not Config.FarmingSpots then
        print("^1[ERROR] Config.FarmingSpots is nil!^7")
        return
    end
    
    for k, v in pairs(Config.FarmingSpots) do
        print("^3[DEBUG] Creating blip for farming spot: " .. k .. "^7")
        local blip = AddBlipForCoord(v.coords)
        SetBlipSprite(blip, 514)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(v.label)
        EndTextCommandSetBlipName(blip)
    end
    
    if not Config.ProcessingSpots then
        print("^1[ERROR] Config.ProcessingSpots is nil!^7")
        return
    end
    
    for k, v in pairs(Config.ProcessingSpots) do
        print("^3[DEBUG] Creating blip for processing spot: " .. k .. "^7")
        local blip = AddBlipForCoord(v.coords)
        SetBlipSprite(blip, v.blip.sprite)
        SetBlipColour(blip, v.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(v.label)
        EndTextCommandSetBlipName(blip)
    end
    print("^2[DEBUG] Finished creating blips^7")
end)

-- Farming Loop mit Debug
CreateThread(function()
    Wait(2000)
    print("^2[DEBUG] Starting farming loop^7")
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        if not Config or not Config.FarmingSpots then
            print("^1[ERROR] Config or FarmingSpots missing in farming loop^7")
            Wait(sleep)
            return
        end
        
        for k, v in pairs(Config.FarmingSpots) do
            local distance = #(playerCoords - v.coords)
            
            if distance < 10 then
                sleep = 0
                DrawMarker(1, v.coords.x, v.coords.y, v.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                
                if distance < 2 and not isProcessing then
                    ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um ' .. v.label .. ' zu sammeln')
                    
                    if IsControlJustReleased(0, 38) then
                        isProcessing = true
                        TaskStartScenarioInPlace(playerPed, v.animation, 0, true)
                        
                        ESX.ShowNotification('Sammle ' .. v.label .. '...')
                        Wait(5000)
                        
                        ClearPedTasks(playerPed)
                        TriggerServerEvent('farming:giveItem', k)
                        isProcessing = false
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

function GetFormattedInventory()
    local inventory = {}
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.inventory then
        for _, item in ipairs(playerData.inventory) do
            if item.count > 0 then
                inventory[item.name] = {
                    count = item.count,
                    label = item.label
                }
            end
        end
    end
    return inventory
end

-- UI öffnen bei Verarbeitungsstellen
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for k, v in pairs(Config.ProcessingSpots) do
            local distance = #(playerCoords - v.coords)
            
            if distance < 10 then
                sleep = 0
                DrawMarker(1, v.coords.x, v.coords.y, v.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)
                
                if distance < 2 then
                    ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um die Verarbeitung zu öffnen')
                    
                    if IsControlJustReleased(0, 38) then
                        OpenProcessingMenu(k)
                    end
                end
            else
                if currentProcessor == k then
                    CloseUI()
                end
            end
        end
        
        Wait(sleep)
    end
end)

function OpenProcessingMenu(processType)
    local processingSpot = Config.ProcessingSpots[processType]
    if not processingSpot then return end

    currentProcessor = processType
    SetNuiFocus(true, true)

    local filteredRecipes = {}
    for recipeId, recipe in pairs(Recipes.List) do
        if not recipe.category then
            recipe.category = "basic"
        end
        
        for _, allowedRecipe in ipairs(processingSpot.allowedRecipes) do
            if recipeId == allowedRecipe then
                filteredRecipes[recipeId] = recipe
            end
        end
    end
    
    -- Zuerst Labels vom Server holen
    TriggerServerEvent('farming:getRecipeLabels', filteredRecipes)
end

function CloseUI()
    if currentProcessor then
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = 'hideUI'
        })
        currentProcessor = nil
        pendingOrderId = nil
    end
end

RegisterNetEvent('farming:receiveRecipeLabels')
AddEventHandler('farming:receiveRecipeLabels', function(labeledRecipes)
    local currentLocale = GetLocale()
    
    SendNUIMessage({
        type = 'showUI',
        recipes = labeledRecipes,
        location = {
            type = currentProcessor,
            label = Config.ProcessingSpots[currentProcessor].label,
            allowedRecipes = Config.ProcessingSpots[currentProcessor].allowedRecipes
        },
        translations = Locales[currentLocale], -- Sende alle Übersetzungen der aktuellen Sprache
        inventory = GetFormattedInventory()
    })
    
    TriggerServerEvent('farming:getActiveOrders')
end)
RegisterNetEvent('farming:updateActiveOrders')
AddEventHandler('farming:updateActiveOrders', function(orders)
    activeOrders = orders
    -- If we have a pending order, check if it exists in the returned orders
    if pendingOrderId then
        local orderExists = false
        for _, order in ipairs(orders) do
            if order.id == pendingOrderId then
                orderExists = true
                break
            end
        end
        if not orderExists then
            pendingOrderId = nil
        end
    end
    SendNUIMessage({
        type = 'updateOrders',
        orders = orders,
        pendingOrderId = pendingOrderId
    })
end)

RegisterNetEvent('farming:craftingResult')
AddEventHandler('farming:craftingResult', function(success, message, orderId)
    if success then
        pendingOrderId = orderId
        ESX.ShowNotification(message)
    else
        ESX.ShowNotification(message)
        -- Remove any pending order from UI
        SendNUIMessage({
            type = 'removePendingOrder'
        })
    end
end)

RegisterNetEvent('esx:setInventoryItems')
AddEventHandler('esx:setInventoryItems', function(inventory)
    if currentProcessor then
        SendNUIMessage({
            type = 'updateInventory',
            inventory = GetFormattedInventory()
        })
    end
end)

RegisterNUICallback('closeUI', function(data, cb)
    CloseUI()
    cb({})
end)

RegisterNUICallback('startCrafting', function(data, cb)
    if not currentProcessor then 
        cb({ success = false, message = "Kein Verarbeiter ausgewählt" })
        return
    end

    TriggerServerEvent('farming:startCrafting', data.recipe, data.amount)
    cb({ success = true })
end)

RegisterNUICallback('collectOrder', function(data, cb)
    TriggerServerEvent('farming:collectOrder', data.orderId)
    cb({})
end)