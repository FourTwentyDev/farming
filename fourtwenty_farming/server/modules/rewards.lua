-- server/modules/rewards.lua

-- Belohnungssystem für verschiedene Farmingaktivitäten
local RewardSystem = {
    -- XP Multiplikatoren für verschiedene Aktivitäten
    multipliers = {
        static = 1.0,
        dynamic = 1.2,  -- 20% mehr XP für dynamisches Farming
        processing = 1.5 -- 50% mehr XP für Verarbeitung
    },
    
    -- Basis-XP Werte
    baseXP = {
        farming = 10,
        processing = 20
    }
}

-- Belohnung für Farming-Aktivität vergeben
function GiveReward(source, spotId, farmingType, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local spot = farmingType == 'static' 
        and FarmingConfig.StaticSpots[spotId] 
        or FarmingConfig.DynamicSpots[spotId]
    
    if not spot then return false end
    
    -- Inventar-Check
    local canCarry = true
    if Config.Settings.Inventory.CheckWeight then
        canCarry = xPlayer.canCarryItem(spot.reward.item, amount)
    end
    
    if not canCarry then
        TriggerClientEvent('esx:showNotification', source, _U('inventory_full'))
        return false
    end
    
    -- Belohnung berechnen
    local finalAmount = CalculateReward(spot, amount, xPlayer)
    
    -- Items geben
    xPlayer.addInventoryItem(spot.reward.item, finalAmount)
    
    -- XP vergeben wenn aktiviert
    if FarmingConfig.Skills and FarmingConfig.Skills.enabled then
        local xpGain = CalculateXP(farmingType, amount)
        AddPlayerXP(xPlayer.identifier, 'farming', xpGain)
    end
    
    -- Statistik aktualisieren
    UpdateFarmingStats(xPlayer.identifier, spotId, finalAmount)
    
    -- Erfolg melden
    return true
end

-- Belohnungsmenge berechnen (mit Berücksichtigung von Skills und Effekten)
function CalculateReward(spot, baseAmount, xPlayer)
    local amount = baseAmount
    
    -- Skill-Bonus
    if FarmingConfig.Skills and FarmingConfig.Skills.enabled then
        local skillLevel = GetPlayerSkillLevel(xPlayer.identifier, 'farming')
        amount = amount * (1 + (skillLevel * FarmingConfig.Skills.categories.farming.levelMultiplier))
    end
    
    -- Wetter-Effekte
    if FarmingConfig.WeatherEffects and FarmingConfig.WeatherEffects.enabled then
        local currentWeather = GetCurrentWeather()
        if FarmingConfig.WeatherEffects.effects[currentWeather] then
            amount = amount * FarmingConfig.WeatherEffects.effects[currentWeather].itemMultiplier
        end
    end
    
    return math.floor(amount + 0.5) -- Aufrunden auf ganze Zahlen
end

-- XP für Aktivität berechnen
function CalculateXP(activityType, amount)
    local baseXP = RewardSystem.baseXP.farming
    local multiplier = RewardSystem.multipliers[activityType] or 1.0
    
    return math.floor(baseXP * multiplier * amount)
end

-- Spieler-XP hinzufügen
function AddPlayerXP(identifier, skill, amount)
    if not FarmingConfig.Skills.enabled then return end
    
    MySQL.query('INSERT INTO player_skills (identifier, skill, xp) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE xp = xp + ?',
    {identifier, skill, amount, amount})
end

-- Spieler-Skill-Level abrufen
function GetPlayerSkillLevel(identifier, skill)
    local result = MySQL.Sync.fetchScalar('SELECT xp FROM player_skills WHERE identifier = ? AND skill = ?',
    {identifier, skill})
    
    if result then
        -- XP in Level umrechnen (Beispiel: 100 XP pro Level)
        return math.floor(result / 100)
    end
    
    return 0
end

-- Export Funktionen
exports('GiveReward', GiveReward)
exports('GetSkillLevel', GetPlayerSkillLevel)