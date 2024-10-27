local ESX = exports['es_extended']:getSharedObject()
local currentProcessor = nil

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    currentProcessor = nil
    cb({})
end)

RegisterNUICallback('startCrafting', function(data, cb)
    if not currentProcessor then 
        cb({ success = false, message = "Kein Verarbeiter ausgewählt" })
        return
    end

    -- Prüfen ob das Rezept für diesen Verarbeiter erlaubt ist
    local processingSpot = Config.ProcessingSpots[currentProcessor]
    local isAllowed = false
    for _, recipe in ipairs(processingSpot.allowedRecipes) do
        if recipe == data.recipe then
            isAllowed = true
            break
        end
    end

    if not isAllowed then
        ESX.ShowNotification("Dieses Rezept kann hier nicht hergestellt werden!")
        cb({ success = false })
        return
    end

    TriggerServerEvent('farming:startCrafting', data.recipe, data.amount)
    cb({ success = true })
end)

-- Aktive Aufträge aktualisieren
RegisterNetEvent('farming:updateActiveOrders')
AddEventHandler('farming:updateActiveOrders', function(orders)
    SendNUIMessage({
        type = 'updateOrders',
        orders = orders
    })
end)

RegisterNetEvent('farming:notify')
AddEventHandler('farming:notify', function(message)
    ESX.ShowNotification(message)
end)