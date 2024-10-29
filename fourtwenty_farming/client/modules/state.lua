local State = {
    currentProcessor = nil,
    pendingOrderId = nil,
    isProcessing = false,
    activeOrders = {},
    isConfigValid = false,
    isCollecting = false,
    spawnedObjects = {},
    cooldowns = {}
}

-- Getter Functions
local function getCurrentProcessor()
    return State.currentProcessor
end

local function getPendingOrderId()
    return State.pendingOrderId
end

local function getIsProcessing()
    return State.isProcessing
end

local function getActiveOrders()
    return State.activeOrders
end

local function getIsConfigValid()
    return State.isConfigValid
end

local function getIsCollecting()
    return State.isCollecting
end

local function getSpawnedObjects()
    return State.spawnedObjects
end

local function getCooldowns()
    return State.cooldowns
end

-- Setter Functions
local function setCurrentProcessor(value)
    State.currentProcessor = value
end

local function setPendingOrderId(value)
    State.pendingOrderId = value
end

local function setIsProcessing(value)
    State.isProcessing = value
end

local function setActiveOrders(value)
    State.activeOrders = value
end

local function setIsConfigValid(value)
    State.isConfigValid = value
end

local function setIsCollecting(value)
    State.isCollecting = value
end

local function setSpawnedObjects(spotId, value)
    if spotId then
        State.spawnedObjects[spotId] = value
    else
        State.spawnedObjects = value
    end
end

local function setCooldown(spotId, value)
    State.cooldowns[spotId] = value
end

-- Export all functions
exports('getCurrentProcessor', getCurrentProcessor)
exports('getPendingOrderId', getPendingOrderId)
exports('getIsProcessing', getIsProcessing)
exports('getActiveOrders', getActiveOrders)
exports('getIsConfigValid', getIsConfigValid)
exports('getIsCollecting', getIsCollecting)
exports('getSpawnedObjects', getSpawnedObjects)
exports('getCooldowns', getCooldowns)

exports('setCurrentProcessor', setCurrentProcessor)
exports('setPendingOrderId', setPendingOrderId)
exports('setIsProcessing', setIsProcessing)
exports('setActiveOrders', setActiveOrders)
exports('setIsConfigValid', setIsConfigValid)
exports('setIsCollecting', setIsCollecting)
exports('setSpawnedObjects', setSpawnedObjects)
exports('setCooldown', setCooldown)

-- Full state access (use sparingly)
exports('getState', function() return State end)