function SpawnDynamicObjects(spotId, spot)
    local spawnedObjects = exports[GetCurrentResourceName()]:getSpawnedObjects()
    if spawnedObjects[spotId] then return end
    
    local newSpawnedObjects = {}
    local settings = spot.objects
    local baseCoords = spot.coords
    
    local hash = GetHashKey(settings.model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(1)
    end
    
    if Config.Settings.Debug then
        print("^3[DEBUG] Attempting to spawn " .. settings.amount .. " objects at spot " .. spotId .. "^7")
    end
    
    local spawnedCount = 0
    local totalAttempts = 0
    local maxTotalAttempts = settings.amount * 30
    
    while spawnedCount < settings.amount and totalAttempts < maxTotalAttempts do
        local segmentAngle = (2 * math.pi) / settings.amount
        local baseAngle = segmentAngle * spawnedCount
        local randomAngle = baseAngle + math.random() * segmentAngle
        local radius = math.sqrt(math.random()) * settings.radius
        
        local x = baseCoords.x + radius * math.cos(randomAngle)
        local y = baseCoords.y + radius * math.sin(randomAngle)
        
        local z = baseCoords.z + 50.0
        local rayHandle = StartShapeTestRay(x, y, z, x, y, z - 100.0, 1, 0, 0)
        local retval, hit, endCoords, surfaceNormal, materialHash = GetShapeTestResult(rayHandle)
        
        if hit == 1 then
            local finalZ = endCoords.z + settings.groundOffset
            
            local tooClose = false
            for _, obj in ipairs(newSpawnedObjects) do
                if #(vector3(x, y, finalZ) - GetEntityCoords(obj.handle)) < settings.minDistance then
                    tooClose = true
                    break
                end
            end
            
            if not tooClose then
                local obj = CreateObject(hash, x, y, finalZ, false, false, true)
                
                if DoesEntityExist(obj) then
                    SetEntityHeading(obj, math.random() * 360.0)
                    PlaceObjectOnGroundProperly(obj)
                    
                    local finalPos = GetEntityCoords(obj)
                    
                    if math.abs(finalPos.z - baseCoords.z) < 5.0 then
                        FreezeEntityPosition(obj, true)
                        
                        table.insert(newSpawnedObjects, {
                            handle = obj,
                            coords = finalPos,
                            canCollect = true,
                            respawnTime = 0,
                            originalPos = finalPos
                        })
                        
                        spawnedCount = spawnedCount + 1
                    else
                        DeleteObject(obj)
                    end
                end
            end
        end
        
        totalAttempts = totalAttempts + 1
    end
    
    exports[GetCurrentResourceName()]:setSpawnedObjects(spotId, newSpawnedObjects)
    SetModelAsNoLongerNeeded(hash)
end


function CheckNearbyObjects(spotId, spot, playerPed, playerCoords)
    if Config.Settings.Debug then
        print("^3[DEBUG] Checking nearby objects for spot: " .. spotId .. "^7")
    end
    
    local spawnedObjects = exports[GetCurrentResourceName()]:getSpawnedObjects()
    if not spawnedObjects[spotId] then 
        if Config.Settings.Debug then
            print("^1[DEBUG] No spawned objects found for spot: " .. spotId .. "^7")
        end
        return 
    end
    
    if Config.Settings.Debug then
        print("^3[DEBUG] Found " .. #spawnedObjects[spotId] .. " objects for spot " .. spotId .. "^7")
    end
    
    local closestDist = math.huge
    local closestObj = nil
    local closestIndex = nil
    
    for i, obj in ipairs(spawnedObjects[spotId]) do
        if obj.canCollect and DoesEntityExist(obj.handle) then
            local objCoords = GetEntityCoords(obj.handle)
            local dist = #(playerCoords - objCoords)
            
            if Config.Settings.Debug then
                print(string.format("^3[DEBUG] Object %d - Distance: %.2f, Collection Radius: %.2f^7", 
                    i, dist, spot.collection.radius))
            end
            
            if dist < spot.collection.radius and dist < closestDist then
                closestDist = dist
                closestObj = obj
                closestIndex = i
                
                if Config.Settings.Debug then
                    print(string.format("^2[DEBUG] New closest object found: Index %d, Distance %.2f^7", 
                        i, dist))
                end
            end
        end
    end
    
    if closestObj then
        local isCollecting = exports[GetCurrentResourceName()]:getIsCollecting()
        if not isCollecting then
            if Config.Settings.Debug then
                print(string.format("^2[DEBUG] Player can interact with object %d at distance %.2f^7", 
                    closestIndex, closestDist))
            end
            
            -- UI-Feedback mit Locale-Unterstützung
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName(_U('press_to_collect', spot.label))
            EndTextCommandDisplayHelp(0, false, true, -1)
            
            -- Visuelle Markierung des nächsten Objekts
            DrawMarker(21,
                closestObj.coords.x,
                closestObj.coords.y,
                closestObj.coords.z + 0.5,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                0.3, 0.3, 0.3,
                255, 255, 255, 100,
                false, false, 2,
                nil, nil, false
            )
            
            if IsControlJustReleased(0, 38) then
                if Config.Settings.Debug then
                    print("^2[DEBUG] Player pressed E to collect object^7")
                end
                
                if Config.Settings.Gameplay.RequireEmptyHands then
                    local weapon = GetSelectedPedWeapon(playerPed)
                    if weapon ~= GetHashKey('WEAPON_UNARMED') then
                        if Config.Settings.Debug then
                            print("^1[DEBUG] Collection canceled - Player has weapon in hands^7")
                        end
                        
                        BeginTextCommandDisplayHelp('STRING')
                        AddTextComponentSubstringPlayerName(_U('hands_not_empty'))
                        EndTextCommandDisplayHelp(0, false, true, -1)
                        return
                    end
                end
                
                StartDynamicCollection(spotId, spot, closestObj, closestIndex)
            end
        elseif Config.Settings.Debug then
            print("^3[DEBUG] Player is already collecting - ignoring interaction^7")
        end
    elseif Config.Settings.Debug then
        print("^3[DEBUG] No collectable objects within range^7")
    end
end

function StartDynamicCollection(spotId, spot, obj, objIndex)
    local isConfigValid = exports[GetCurrentResourceName()]:getIsConfigValid()
    if not isConfigValid then
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(_U('config_error'))
        EndTextCommandDisplayHelp(0, false, true, -1)
        return
    end
    
    local isCollecting = exports[GetCurrentResourceName()]:getIsCollecting()
    if isCollecting then return end
    
    exports[GetCurrentResourceName()]:setIsCollecting(true)
    local playerPed = PlayerPedId()
    
    TaskTurnPedToFaceCoord(playerPed, obj.coords.x, obj.coords.y, obj.coords.z, 500)
    Wait(500)
    
    if spot.collection.animation then
        LoadAnimDict(spot.collection.animation.dict)
        TaskPlayAnim(playerPed, 
            spot.collection.animation.dict, 
            spot.collection.animation.anim, 
            8.0, -8.0, 
            spot.collection.animation.duration, 
            spot.collection.animation.flag, 
            0, false, false, false)
    end
    
    if Config.Settings.Gameplay.UseProgressBars then
        -- needs to be implemented
    end
    
    Wait(spot.collection.animation.duration)
    
    ClearPedTasks(playerPed)
    
    if DoesEntityExist(obj.handle) then
        local spawnedObjects = exports[GetCurrentResourceName()]:getSpawnedObjects()
        if spawnedObjects[spotId] and spawnedObjects[spotId][objIndex] then
            spawnedObjects[spotId][objIndex].canCollect = false
            spawnedObjects[spotId][objIndex].respawnTime = GetGameTimer() + (spot.objects.respawnTime * 1000)
            SetEntityAlpha(obj.handle, 100, false)
            exports[GetCurrentResourceName()]:setSpawnedObjects(spotId, spawnedObjects[spotId])
        end
        
        TriggerServerEvent('farming:giveReward', spotId, 'dynamic')
    end
    
    exports[GetCurrentResourceName()]:setIsCollecting(false)
end

function DeleteDynamicObjects(spotId)
    local spawnedObjects = exports[GetCurrentResourceName()]:getSpawnedObjects()
    if not spawnedObjects[spotId] then return end
    
    for _, obj in ipairs(spawnedObjects[spotId]) do
        if DoesEntityExist(obj.handle) then
            DeleteEntity(obj.handle)
        end
    end
    
    exports[GetCurrentResourceName()]:setSpawnedObjects(spotId, nil)
end