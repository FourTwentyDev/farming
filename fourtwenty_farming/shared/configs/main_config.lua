-- shared/configs/main_config.lua

Config = {}

-- Grundeinstellungen
Config.Settings = {
    Debug = true, -- Debug-Modus für zusätzliche Konsolenausgaben
    Locale = 'ru', -- Standardsprache (de oder en)
    
    -- Notification Einstellungen
    Notifications = {
        Position = "top-left",
        DefaultDuration = 3000,
        UseCustom = false, -- Falls true, wird ein Custom Notification System verwendet
    },
    
    -- Marker Standardeinstellungen
    DefaultMarker = {
        Type = 1,
        Size = vector3(1.0, 1.0, 1.0),
        Color = {r = 0, g = 255, b = 0, a = 100},
        BobUpAndDown = false,
        FaceCamera = false,
        Rotate = false,
        DrawDistance = 20.0,
        InteractionDistance = 2.0
    },
    
    -- Blip Standardeinstellungen
    DefaultBlip = {
        Scale = 0.8,
        Display = 4,
        ShortRange = true
    },
    
    -- Allgemeine Gameplay-Einstellungen
    Gameplay = {
        UseSkillCheck = false, -- Skill-Check System beim Sammeln
        UseProgressBars = true, -- Fortschrittsbalken anzeigen
        AllowCancellation = true, -- Sammelaktion abbrechen erlauben
        PreventMovement = true, -- Bewegung während des Sammelns verhindern
        RequireEmptyHands = true -- Leere Hände zum Sammeln erforderlich
    },
    
    -- Inventory Einstellungen
    Inventory = {
        CheckWeight = true, -- Gewichtssystem prüfen
        UseCustomInventory = false, -- Custom Inventory System
        MaxItemStack = 100 -- Maximale Stapelgröße pro Item
    }
}

-- Framework Konfiguration
Config.Framework = {
    Name = "ESX", -- oder "QBCore"
    UseCustomExports = false,
    CustomExports = {
        GetPlayer = "esx:getSharedObject",
        Notify = "esx:showNotification"
    }
}

-- Update Intervalle (in ms)
Config.UpdateIntervals = {
    MainLoop = 1000,
    NearbyCheck = 500,
    ObjectSync = 2000,
    InventoryUpdate = 5000
}

-- Fehlermeldungen
Config.ErrorMessages = {
    InventoryFull = "Dein Inventar ist voll!",
    NoPermission = "Du hast keine Berechtigung dafür!",
    CooldownActive = "Du musst noch warten!",
    InvalidLocation = "Ungültiger Standort!",
    NotEnoughSpace = "Nicht genug Platz im Inventar!",
    HandsNotEmpty = "Deine Hände müssen leer sein!"
}

return Config