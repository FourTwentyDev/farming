-- client/imports.lua
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

-- Getter/Setter Funktionen
local function getCurrentProcessor()
    return State.currentProcessor
end

local function setCurrentProcessor(value)
    State.currentProcessor = value
end

-- Weitere Getter/Setter für andere State-Eigenschaften...

-- Exportiere die Funktionen
exports('getCurrentProcessor', getCurrentProcessor)
exports('setCurrentProcessor', setCurrentProcessor)
exports('getState', function() return State end)

-- Optional: Lokaler Zugriff für andere Skripte
_G.GetFarmingState = function()
    return State
end