-- client/modules/animations.lua

local loadedDicts = {}

function LoadAnimDict(dict)
    if not loadedDicts[dict] then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
        loadedDicts[dict] = true
    end
end

function UnloadAnimDict(dict)
    if loadedDicts[dict] then
        RemoveAnimDict(dict)
        loadedDicts[dict] = nil
    end
end

function PlayFarmingAnimation(animData, callback)
    local playerPed = PlayerPedId()
    
    LoadAnimDict(animData.dict)
    
    if animData.flag then
        TaskPlayAnim(playerPed, 
            animData.dict, 
            animData.anim, 
            8.0, -8.0, 
            animData.duration, 
            animData.flag, 
            0, false, false, false)
    else
        TaskPlayAnim(playerPed, 
            animData.dict, 
            animData.anim, 
            8.0, -8.0, 
            -1, 
            1, 0, false, false, false)
    end
    
    if callback then
        SetTimeout(animData.duration, function()
            callback()
        end)
    end
end

function StopCurrentAnimation()
    ClearPedTasks(PlayerPedId())
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for dict in pairs(loadedDicts) do
        UnloadAnimDict(dict)
    end
end)

exports('PlayAnimation', PlayFarmingAnimation)
exports('StopAnimation', StopCurrentAnimation)