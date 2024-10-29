function StartStaticCollection(spotId, spot)
    if Config.Settings.Debug then
        print("^3[DEBUG] Starting static collection for spot: " .. spotId .. "^7")
    end

    local isConfigValid = exports[GetCurrentResourceName()]:getIsConfigValid()
    if not isConfigValid then
        if Config.Settings.Debug then
            print("^1[DEBUG] Collection cancelled - Invalid configuration^7")
        end
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(_U('config_error'))
        EndTextCommandDisplayHelp(0, false, true, -1)
        return
    end
    
    local isCollecting = exports[GetCurrentResourceName()]:getIsCollecting()
    if isCollecting or not spot.enabled then 
        if Config.Settings.Debug then
            print("^1[DEBUG] Collection cancelled - Already collecting or spot disabled^7")
        end
        return 
    end
    
    if not CheckCollectionRequirements(spot) then
        if Config.Settings.Debug then
            print("^1[DEBUG] Collection cancelled - Requirements not met^7")
        end
        return
    end

    -- Position check based on spot type
    local playerCoords = GetEntityCoords(PlayerPedId())
    local canCollect = false

    if spot.type == FarmingConfig.Types.STATIC_AREA then
        local distance = #(playerCoords - spot.coords)
        canCollect = distance <= spot.farmingRadius
        
        if Config.Settings.Debug then
            print("^3[DEBUG] STATIC_AREA distance check: " .. distance .. " (max " .. spot.farmingRadius .. ")^7")
        end
    elseif spot.type == FarmingConfig.Types.STATIC_SPOTS then
        -- Bei STATIC_SPOTS ist spotId bereits der kombinierte String (spotId_spotIndex)
        local baseSpotId, spotIndex = spotId:match("(.+)_(%d+)")
        if baseSpotId and spotIndex then
            spotIndex = tonumber(spotIndex)
            local subSpot = spot.spots[spotIndex]
            if subSpot then
                local distance = #(playerCoords - subSpot.coords)
                canCollect = distance <= 2.0 -- Standard Sammelradius für Einzelspots
                
                if Config.Settings.Debug then
                    print("^3[DEBUG] STATIC_SPOTS distance check for subspot " .. spotIndex .. ": " .. distance .. "^7")
                end
            end
        end
    end

    if not canCollect then
        if Config.Settings.Debug then
            print("^1[DEBUG] Collection cancelled - Player too far from collection point^7")
        end
        return
    end
    
    if Config.Settings.Debug then
        print("^2[DEBUG] All checks passed, starting collection animation^7")
    end
    
    exports[GetCurrentResourceName()]:setIsCollecting(true)
    local playerPed = PlayerPedId()
    
    if spot.animation then
        LoadAnimDict(spot.animation.dict)
        TaskPlayAnim(playerPed, 
            spot.animation.dict, 
            spot.animation.anim, 
            8.0, -8.0, 
            spot.animation.duration, 
            spot.animation.flag, 
            0, false, false, false)
    end
    
    if Config.Settings.Gameplay.UseProgressBars then
        -- needs to be implemented
    end
    
    Wait(spot.animation.duration)
    
    ClearPedTasks(playerPed)
    
    if Config.Settings.Debug then
        print("^2[DEBUG] Collection animation completed, triggering reward^7")
    end
    
    TriggerServerEvent('farming:giveReward', spot.type == FarmingConfig.Types.STATIC_SPOTS and spotId:match("(.+)_(%d+)") or spotId, 'static')
    
    SetSpotCooldown(spotId)
    
    exports[GetCurrentResourceName()]:setIsCollecting(false)
end

function CheckCollectionRequirements(spot)
    if Config.Settings.Debug then
        print("^3[DEBUG] Checking collection requirements^7")
    end

    if spot.requirements and spot.requirements.job then
        local playerJob = ESX.GetPlayerData().job.name
        if playerJob ~= spot.requirements.job then
            if Config.Settings.Debug then
                print("^1[DEBUG] Job requirement not met: Required " .. spot.requirements.job .. ", Player has " .. playerJob .. "^7")
            end
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName(_U('wrong_job'))
            EndTextCommandDisplayHelp(0, false, true, -1)
            return false
        end
    end
    
    if spot.requirements and spot.requirements.item then
        local inventory = ESX.GetPlayerData().inventory
        local hasItem = false
        for _, item in ipairs(inventory) do
            if item.name == spot.requirements.item and item.count > 0 then
                hasItem = true
                break
            end
        end
        if not hasItem then
            if Config.Settings.Debug then
                print("^1[DEBUG] Missing required item: " .. spot.requirements.item .. "^7")
            end
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName(_U('missing_required_item'))
            EndTextCommandDisplayHelp(0, false, true, -1)
            return false
        end
    end
    
    if Config.Settings.Debug then
        print("^2[DEBUG] All collection requirements met^7")
    end
    return true
end

function IsCooldownActive(spotId)
    local cooldowns = exports[GetCurrentResourceName()]:getCooldowns()
    -- Für STATIC_SPOTS bekommen wir spotId als "baseId_index"
    local baseSpotId = spotId:match("(.+)_(%d+)") or spotId
    local spot = FarmingConfig.StaticSpots[baseSpotId]
    
    if not spot then return false end
    
    local isActive = cooldowns[spotId] and (GetGameTimer() - cooldowns[spotId]) < spot.cooldown
    
    if Config.Settings.Debug and isActive then
        local remainingTime = math.ceil((spot.cooldown - (GetGameTimer() - cooldowns[spotId])) / 1000)
        print("^3[DEBUG] Cooldown active for spot " .. spotId .. ". Remaining time: " .. remainingTime .. " seconds^7")
    end
    
    if isActive then
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(_U('cooldown_active'))
        EndTextCommandDisplayHelp(0, false, true, -1)
    end
    
    return isActive
end

function SetSpotCooldown(spotId)
    if Config.Settings.Debug then
        print("^3[DEBUG] Setting cooldown for spot: " .. spotId .. "^7")
    end
    exports[GetCurrentResourceName()]:setCooldown(spotId, GetGameTimer())
end

-- Optional: Helper function für Animation Loading mit Debug
function LoadAnimDict(dict)
    if Config.Settings.Debug then
        print("^3[DEBUG] Loading animation dictionary: " .. dict .. "^7")
    end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    
    if Config.Settings.Debug then
        print("^2[DEBUG] Animation dictionary loaded successfully^7")
    end
end