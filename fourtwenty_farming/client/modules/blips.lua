local farmingBlips = {}

function InitializeBlips()
    if Config.Settings.Debug then
        print("^2[DEBUG] Initializing blips module^7")
    end
    
    CreateFarmingBlips()
end

function CreateFarmingBlips()
    RemoveAllBlips()
    
    -- Static Spots
    for spotId, spot in pairs(FarmingConfig.StaticSpots) do
        if spot.enabled and spot.blip then
            local blip = AddBlipForCoord(spot.coords)
            SetupBlip(blip, spot.blip)
            farmingBlips[spotId] = blip
        end
    end
    
    -- Dynamic Spots
    for spotId, spot in pairs(FarmingConfig.DynamicSpots) do
        if spot.enabled and spot.blip then
            local blip = AddBlipForCoord(spot.coords)
            SetupBlip(blip, spot.blip)
            farmingBlips[spotId] = blip
        end
    end
    
    -- Processing Locations
    for locationId, location in pairs(ProcessingConfig.Locations) do
        if location.enabled and location.blip then
            local blip = AddBlipForCoord(location.coords)
            SetupBlip(blip, location.blip)
            farmingBlips[locationId .. "_proc"] = blip
        end
    end
end

function SetupBlip(blip, blipData)
    SetBlipSprite(blip, blipData.sprite)
    SetBlipDisplay(blip, blipData.display or Config.Settings.DefaultBlip.Display)
    SetBlipScale(blip, blipData.scale or Config.Settings.DefaultBlip.Scale)
    SetBlipColour(blip, blipData.color)
    SetBlipAsShortRange(blip, blipData.shortRange or Config.Settings.DefaultBlip.ShortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.label)
    EndTextCommandSetBlipName(blip)
end

function RemoveAllBlips()
    for _, blip in pairs(farmingBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    farmingBlips = {}
end

-- Export for external access
exports('RefreshBlips', function()
    CreateFarmingBlips()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    RemoveAllBlips()
end)