-- locale.lua

Locales = {}

function GetLocale()
    return Config.Locale or 'en'
end

function _U(str, ...)
    local locale = GetLocale()
    if Locales[locale] and Locales[locale][str] then
        return string.format(Locales[locale][str], ...)
    end
    return 'Translation_Missing: ' .. locale .. '.' .. str
end

-- English locale
Locales['en'] = {
    -- General
    ['press_to_collect'] = 'Press ~INPUT_CONTEXT~ to collect %s',
    ['press_to_process'] = 'Press ~INPUT_CONTEXT~ to open processing',
    ['collecting'] = 'Collecting %s...',
    ['not_enough_materials'] = 'You don\'t have enough materials!',
    ['not_enough_money'] = 'You don\'t have enough money! Required: $%s',
    ['inventory_full'] = 'You cannot carry that much! Make space in your inventory first.',
    ['invalid_recipe'] = 'Invalid recipe!',
    ['crafting_started'] = 'Crafting started!',
    ['order_not_found'] = 'Order not found!',
    ['order_not_complete'] = 'The order is not complete yet!',
    ['recipe_not_found'] = 'Recipe not found!',
    ['order_collected'] = 'Order successfully collected!',
    ['active_order_exists'] = 'You already have an active order!',
    ['no_processor_selected'] = 'No processor selected',
    ['recipe_not_allowed'] = 'This recipe cannot be crafted here!',

    -- UI Elements
    ['processing'] = 'Processing',
    ['select_recipe'] = 'Select a recipe to process',
    ['recipes'] = 'Recipes',
    ['active_orders'] = 'Active Orders',
    ['filter'] = 'Filter',
    ['all_recipes'] = 'All Recipes',
    ['craftable'] = 'Craftable',
    ['your_inventory'] = 'Your Inventory',
    ['select_amount'] = 'Select Amount',
    ['press_esc'] = 'Press ESC to close',
    ['total_production'] = 'Total Production:',
    ['total_price'] = 'Total Price',
    ['required_materials'] = 'Required Materials',
    ['available'] = 'available',
    ['needed'] = 'needed',
    ['free'] = 'Free',
    ['reward'] = 'Outcome',
    ['per_unit'] = 'Per Unit',
    ['resource_calculation'] = 'Resource Calculation',
    ['try_different_filter'] = 'Try a different filter',
    ['no_recipes_found'] = 'No recipes found',
    ['order_summary'] = 'Order Summary',
    ['production_details'] = 'Production Details',
    
    -- Order Status
    ['processing_status'] = 'Processing',
    ['ready_for_collection'] = 'Ready for collection',
    ['starting'] = 'Starting...',
    ['completed'] = 'Completed',
    ['time_remaining'] = '%s remaining',
    ['collect'] = 'Collect',
    ['cancel'] = 'Cancel',
    ['craft'] = 'Craft',
    ['not_enough_materials_button'] = 'Not enough materials',
    
    -- Time Format
    ['time_format_hours'] = '%dh %dm remaining',
    ['time_format_minutes'] = '%dm %ds remaining',
    ['time_format_seconds'] = '%ds remaining',
    
    -- Order Display
    ['order_number'] = '#%d',
    ['no_active_orders'] = 'No active orders',
    ['one_moment'] = 'One moment...',
}

-- German locale
Locales['de'] = {
    -- Allgemein
    ['press_to_collect'] = 'Drücke ~INPUT_CONTEXT~ um %s zu sammeln',
    ['press_to_process'] = 'Drücke ~INPUT_CONTEXT~ um die Verarbeitung zu öffnen',
    ['collecting'] = 'Sammle %s...',
    ['not_enough_materials'] = 'Du hast nicht genug Materialien!',
    ['not_enough_money'] = 'Du hast nicht genug Geld! Benötigt: $%s',
    ['inventory_full'] = 'Du kannst nicht so viel tragen! Mach zuerst Platz im Inventar.',
    ['invalid_recipe'] = 'Ungültiges Rezept!',
    ['crafting_started'] = 'Herstellung gestartet!',
    ['order_not_found'] = 'Auftrag nicht gefunden!',
    ['order_not_complete'] = 'Der Auftrag ist noch nicht fertig!',
    ['recipe_not_found'] = 'Rezept nicht gefunden!',
    ['order_collected'] = 'Auftrag erfolgreich abgeholt!',
    ['active_order_exists'] = 'Du hast bereits einen aktiven Auftrag!',
    ['no_processor_selected'] = 'Kein Verarbeiter ausgewählt',
    ['recipe_not_allowed'] = 'Dieses Rezept kann hier nicht hergestellt werden!',

    -- UI-Elemente
    ['processing'] = 'Verarbeitung',
    ['select_recipe'] = 'Wähle ein Rezept zum Verarbeiten',
    ['recipes'] = 'Rezepte',
    ['active_orders'] = 'Aktive Aufträge',
    ['filter'] = 'Filter',
    ['all_recipes'] = 'Alle Rezepte',
    ['craftable'] = 'Herstellbar',
    ['your_inventory'] = 'Dein Inventar',
    ['select_amount'] = 'Menge auswählen',
    ['press_esc'] = 'ESC zum Schließen',
    ['total_production'] = 'Gesamte Produktion:',
    ['total_price'] = 'Gesamtpreis',
    ['required_materials'] = 'Benötigte Materialien',
    ['available'] = 'verfügbar',
    ['needed'] = 'benötigt',
    ['free'] = 'Kostenlos',
    ['reward'] = 'Ergebnis',
    ['per_unit'] = 'Pro Einheit',
    ['resource_calculation'] = 'Ressourcenberechnung',
    ['try_different_filter'] = 'Versuche einen anderen Filter',
    ['no_recipes_found'] = 'Keine Rezepte gefunden',
    ['order_summary'] = 'Auftragsübersicht',
    ['production_details'] = 'Produktionsdetails',
    -- Auftragsstatus
    ['processing_status'] = 'In Bearbeitung',
    ['ready_for_collection'] = 'Fertig zum Abholen',
    ['starting'] = 'Wird gestartet...',
    ['completed'] = 'Abgeschlossen',
    ['time_remaining'] = '%s übrig',
    ['collect'] = 'Abholen',
    ['cancel'] = 'Abbrechen',
    ['craft'] = 'Herstellen',
    ['not_enough_materials_button'] = 'Nicht genug Materialien',
    
    -- Zeitformat
    ['time_format_hours'] = '%dh %dm übrig',
    ['time_format_minutes'] = '%dm %ds übrig',
    ['time_format_seconds'] = '%ds übrig',
    
    -- Auftragsanzeige
    ['order_number'] = '#%d',
    ['no_active_orders'] = 'Keine aktiven Aufträge',
    ['one_moment'] = 'Einen Moment...',
}