ESX = nil
local isInitialized = false

CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Wait(100)
    end
    
    if Config.Settings.Debug then
        print("^2[DEBUG] Client script starting^7")
    end
    
    InitializeModules()
end)

function InitializeModules()
    if isInitialized then return end
    
    local valid, errors = ConfigValidator.ValidateAllConfigs()
    if not valid then
        if Config.Settings.Debug then
            for _, error in ipairs(errors) do
                print("^1[ERROR] " .. error .. "^7")
            end
        end
        return
    end
    
    exports[GetCurrentResourceName()]:setIsConfigValid(true)
    InitializeBlips()
    StartMainLoop()
    RegisterEventHandlers()
    
    RegisterNUICallbacks() -- Added NUI callbacks registration

    isInitialized = true
    if Config.Settings.Debug then
        print("^2[DEBUG] All modules initialized^7")
    end
end

function RegisterNUICallbacks()
    RegisterNUICallback('closeUI', function(data, cb)
        CloseUI()
        cb({})
    end)

    RegisterNUICallback('startCrafting', function(data, cb)
        local currentProcessor = exports[GetCurrentResourceName()]:getCurrentProcessor()
        if not currentProcessor then 
            cb({ success = false, message = _U('no_processor_selected') })
            return
        end

        -- Check if recipe is allowed for this processor
        local processingSpot = ProcessingConfig.Locations[currentProcessor]
        local isAllowed = false
        for _, recipe in ipairs(processingSpot.allowedRecipes) do
            if recipe == data.recipe then
                isAllowed = true
                break
            end
        end

        if not isAllowed then
            ESX.ShowNotification(_U('recipe_not_allowed'))
            cb({ success = false })
            return
        end

        TriggerServerEvent('farming:startCrafting', data.recipe, data.amount)
        cb({ success = true })
    end)

    RegisterNUICallback('collectOrder', function(data, cb)
        TriggerServerEvent('farming:collectOrder', data.orderId)
        cb({})
    end)
end

function StartMainLoop()
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local isNearAnySpot = false

            -- Processing Spots
            for locationId, location in pairs(ProcessingConfig.Locations) do
                if location.enabled then
                    local distance = #(playerCoords - location.coords)
                    if distance < 30.0 then
                        sleep = 0
                        isNearAnySpot = true
                        
                        DrawMarker(
                            location.marker.type or 1,
                            location.coords.x, location.coords.y, location.coords.z - 1.0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                            location.marker.size.x, location.marker.size.y, location.marker.size.z,
                            location.marker.color.r, location.marker.color.g, location.marker.color.b, location.marker.color.a,
                            false, true, 2, false, nil, nil, false
                        )
                        
                        if distance < 2.0 then
                            BeginTextCommandDisplayHelp('STRING')
                            AddTextComponentSubstringPlayerName(_U('press_to_process'))
                            EndTextCommandDisplayHelp(0, false, true, -1)
                            
                            if IsControlJustReleased(0, 38) then
                                OpenProcessingMenu(locationId)
                            end
                        end
                    end
                end
            end

            -- Static Farming Spots
            for spotId, spot in pairs(FarmingConfig.StaticSpots) do
                if spot.enabled then
                    local distance = #(playerCoords - spot.coords)
                    
                    if distance < 30.0 then
                        sleep = 0
                        isNearAnySpot = true
                        
                        if spot.type == FarmingConfig.Types.STATIC_AREA then
                            -- Bereichs-basiertes Farming
                            if spot.marker.showArea then
                                DrawMarker(
                                    1, -- Cylinder
                                    spot.coords.x, spot.coords.y, spot.coords.z - 1.0,
                                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                    spot.farmingRadius * 2.0, spot.farmingRadius * 2.0, 2.0,
                                    spot.marker.color.r, spot.marker.color.g, spot.marker.color.b, 50,
                                    false, true, 2, false, nil, nil, false
                                )
                            end
                            
                            if distance < spot.farmingRadius then
                                local isCollecting = exports[GetCurrentResourceName()]:getIsCollecting()
                                if not isCollecting and not IsCooldownActive(spotId) then
                                    BeginTextCommandDisplayHelp('STRING')
                                    AddTextComponentSubstringPlayerName('Drücke ~INPUT_CONTEXT~ zum Sammeln von ' .. spot.label)
                                    EndTextCommandDisplayHelp(0, false, true, -1)
                                    
                                    if IsControlJustReleased(0, 38) then
                                        StartStaticCollection(spotId, spot)
                                    end
                                end
                            end
                            
                        elseif spot.type == FarmingConfig.Types.STATIC_SPOTS then
                            -- Multi-Spot basiertes Farming
                            for spotIndex, subSpot in ipairs(spot.spots) do
                                local subDistance = #(playerCoords - subSpot.coords)
                                
                                DrawMarker(
                                    spot.marker.type,
                                    subSpot.coords.x, subSpot.coords.y, subSpot.coords.z - 1.0,
                                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                    spot.marker.size.x, spot.marker.size.y, spot.marker.size.z,
                                    spot.marker.color.r, spot.marker.color.g, spot.marker.color.b, spot.marker.color.a,
                                    false, true, 2, false, nil, nil, false
                                )
                                
                                if subDistance < 2.0 then
                                    local isCollecting = exports[GetCurrentResourceName()]:getIsCollecting()
                                    if not isCollecting and not IsCooldownActive(spotId .. '_' .. spotIndex) then
                                        BeginTextCommandDisplayHelp('STRING')
                                        AddTextComponentSubstringPlayerName('Drücke ~INPUT_CONTEXT~ zum Sammeln von ' .. spot.label)
                                        EndTextCommandDisplayHelp(0, false, true, -1)
                                        
                                        if IsControlJustReleased(0, 38) then
                                            StartStaticCollection(spotId .. '_' .. spotIndex, spot)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Dynamic Farming Spots
            for spotId, spot in pairs(FarmingConfig.DynamicSpots) do
                if spot.enabled then
                    local distance = #(playerCoords - spot.coords)
                    if distance < Config.Settings.DefaultMarker.DrawDistance then
                        sleep = 0
                        isNearAnySpot = true
                        
                        local spawnedObjects = exports[GetCurrentResourceName()]:getSpawnedObjects()
                        if not spawnedObjects[spotId] then
                            SpawnDynamicObjects(spotId, spot)
                        end
                        
                        CheckNearbyObjects(spotId, spot, playerPed, playerCoords)
                    else
                        local spawnedObjects = exports[GetCurrentResourceName()]:getSpawnedObjects()
                        if spawnedObjects[spotId] then
                            DeleteDynamicObjects(spotId)
                        end
                    end
                end
            end

            if not isNearAnySpot then
                sleep = 1000
            end

            Wait(sleep)
        end
    end)

    CreateThread(function()
        while true do
            Wait(Config.UpdateIntervals.ObjectSync)
            
            local spawnedObjects = exports[GetCurrentResourceName()]:getSpawnedObjects()
            local updatedObjects = false
            
            for spotId, objects in pairs(spawnedObjects) do
                local spot = FarmingConfig.DynamicSpots[spotId]
                if spot and spot.enabled then
                    for _, obj in ipairs(objects) do
                        if not obj.canCollect and GetGameTimer() > obj.respawnTime then
                            obj.canCollect = true
                            SetEntityAlpha(obj.handle, 255, false)
                            updatedObjects = true
                        end
                    end
                end
            end
            
            if updatedObjects then
                exports[GetCurrentResourceName()]:setSpawnedObjects(nil, spawnedObjects)
            end
        end
    end)
end

function RegisterEventHandlers()
    -- ESX Events
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        if Config.Settings.Debug then
            print('^2[DEBUG] Player loaded^7')
        end
    end)
    
    -- Inventory Update Event
    RegisterNetEvent('esx:setInventoryItems')
    AddEventHandler('esx:setInventoryItems', function(inventory)
        local currentProcessor = exports[GetCurrentResourceName()]:getCurrentProcessor()
        if currentProcessor then
            SendNUIMessage({
                type = 'updateInventory',
                inventory = GetFormattedInventory()
            })
        end
    end)
    RegisterNetEvent('farming:updateActiveOrders')
    AddEventHandler('farming:updateActiveOrders', function(orders)
        if Config.Settings.Debug then
            print("^3[DEBUG] Received orders update:", json.encode(orders))
        end
    
        -- Setze die Orders im State
        exports[GetCurrentResourceName()]:setActiveOrders(orders)
        local pendingOrderId = exports[GetCurrentResourceName()]:getPendingOrderId()
    
        -- Sende die Orders ans UI im erwarteten Format
        SendNUIMessage({
            type = 'updateOrders',
            orders = orders,  -- Die Orders sind jetzt schon im richtigen Format
            pendingOrderId = pendingOrderId
        })
    end)

    RegisterNetEvent('farming:notify')
    AddEventHandler('farming:notify', function(message)
        ESX.ShowNotification(message)
    end)

    RegisterNetEvent('farming:craftingResult')
    AddEventHandler('farming:craftingResult', function(success, message, orderId)
        if success then
            exports[GetCurrentResourceName()]:setPendingOrderId(orderId)
            ESX.ShowNotification(message)
        else
            ESX.ShowNotification(message)
            SendNUIMessage({
                type = 'removePendingOrder'
            })
        end
    end)
    -- Other event handlers...
end

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

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    local spawnedObjects = exports[GetCurrentResourceName()]:getSpawnedObjects()
    for spotId, _ in pairs(spawnedObjects) do
        DeleteDynamicObjects(spotId)
    end
    RemoveAllBlips()
end)

-- Processing Menu Functions
function OpenProcessingMenu(processType)
    local processingSpot = ProcessingConfig.Locations[processType]
    if not processingSpot then return end
    
    exports[GetCurrentResourceName()]:setCurrentProcessor(processType)
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

RegisterNetEvent('farming:receiveRecipeLabels')
AddEventHandler('farming:receiveRecipeLabels', function(labeledRecipes)
    local currentProcessor = exports[GetCurrentResourceName()]:getCurrentProcessor()
    if not currentProcessor then return end

    local currentLocale = GetLocale()
    local activeOrders = exports[GetCurrentResourceName()]:getActiveOrders()
    local pendingOrderId = exports[GetCurrentResourceName()]:getPendingOrderId()
    
    SendNUIMessage({
        type = 'showUI',
        recipes = labeledRecipes,
        location = {
            type = currentProcessor,
            label = ProcessingConfig.Locations[currentProcessor].label,
            allowedRecipes = ProcessingConfig.Locations[currentProcessor].allowedRecipes
        },
        translations = Locales[currentLocale],
        inventory = GetFormattedInventory(),
        orders = activeOrders,
        pendingOrderId = pendingOrderId
    })
end)
function CloseUI()
    local currentProcessor = exports[GetCurrentResourceName()]:getCurrentProcessor()
    if currentProcessor then
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = 'hideUI'
        })
        exports[GetCurrentResourceName()]:setCurrentProcessor(nil)
        exports[GetCurrentResourceName()]:setPendingOrderId(nil)
    end
end


-- Additional Event Handlers for Processing
RegisterNetEvent('farming:craftingResult')
AddEventHandler('farming:craftingResult', function(success, message, orderId)
    if success then
        exports[GetCurrentResourceName()]:setPendingOrderId(orderId)
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandDisplayHelp(0, false, true, -1)
    else
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandDisplayHelp(0, false, true, -1)
        SendNUIMessage({
            type = 'removePendingOrder'
        })
    end
end)


-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    CloseUI()
    cb({})
end)

-- Export functions
exports('GetCurrentProcessor', function()
    return exports[GetCurrentResourceName()]:getCurrentProcessor()
end)

exports('IsProcessing', function()
    return exports[GetCurrentResourceName()]:getIsProcessing()
end)