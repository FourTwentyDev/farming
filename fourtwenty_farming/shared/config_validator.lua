-- shared/modules/config_validator.lua
ConfigValidator = {}

function ConfigValidator.ValidateSpot(spot, spotId, spotType)
    if not spot then
        return false, 'Spot is nil'
    end
    
    -- Erforderliche Felder prüfen
    local required = {
        'enabled',
        'label',
        'type',
        'coords',
        'reward'
    }
    
    for _, field in ipairs(required) do
        if spot[field] == nil then
            return false, string.format('Missing required field: %s for spot: %s', field, spotId)
        end
    end
    
    -- Reward Struktur prüfen
    if type(spot.reward) ~= 'table' then
        return false, string.format('Invalid reward structure for spot: %s', spotId)
    end
    
    local rewardRequired = {
        'item',
        'amount',
        'chance'
    }
    
    for _, field in ipairs(rewardRequired) do
        if spot.reward[field] == nil then
            return false, string.format('Missing reward field: %s for spot: %s', field, spotId)
        end
    end
    
    return true, nil
end

function ConfigValidator.ValidateAllConfigs()
    local errors = {}
    
    -- Static Spots prüfen
    for spotId, spot in pairs(FarmingConfig.StaticSpots) do
        local valid, error = ConfigValidator.ValidateSpot(spot, spotId, 'static')
        if not valid then
            table.insert(errors, string.format('Static spot %s: %s', spotId, error))
        end
    end
    
    -- Dynamic Spots prüfen
    for spotId, spot in pairs(FarmingConfig.DynamicSpots) do
        local valid, error = ConfigValidator.ValidateSpot(spot, spotId, 'dynamic')
        if not valid then
            table.insert(errors, string.format('Dynamic spot %s: %s', spotId, error))
        end
    end
    
    return #errors == 0, errors
end

return ConfigValidator