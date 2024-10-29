-- locale.lua
Locales = {}

function GetLocale()
    return Config.Settings.Locale or 'en'
end

function _U(str, ...)
    local locale = GetLocale()
    if Locales[locale] and Locales[locale][str] then
        return string.format(Locales[locale][str], ...)
    end
    return 'Translation_Missing: ' .. locale .. '.' .. str
end

-- English locale (Base language)
Locales['en'] = {
    -- System Messages
    ['config_error'] = 'Configuration error - please contact an administrator',
    ['invalid_spot'] = 'Invalid farming spot',
    ['one_moment'] = 'One moment...',

    -- General Actions
    ['press_to_collect'] = 'Press ~INPUT_CONTEXT~ to collect %s',
    ['press_to_process'] = 'Press ~INPUT_CONTEXT~ to open processing',
    ['press_esc'] = 'Press ESC to close',
    ['collect'] = 'Collect',
    ['cancel'] = 'Cancel',
    ['craft'] = 'Craft',
    
    -- Processing & Crafting
    ['processing'] = 'Processing',
    ['processing_status'] = 'Processing',
    ['processing_progress'] = 'Processing...',
    ['crafting_started'] = 'Crafting started!',
    ['select_recipe'] = 'Select a recipe to process',
    ['recipe_not_allowed'] = 'This recipe cannot be crafted here!',
    ['recipe_not_found'] = 'Recipe not found!',
    ['invalid_recipe'] = 'Invalid recipe!',
    ['no_processor_selected'] = 'No processor selected',
    
    -- Inventory & Resources
    ['inventory_full'] = 'You cannot carry that much! Make space in your inventory first.',
    ['your_inventory'] = 'Your Inventory',
    ['not_enough_materials'] = 'You don\'t have enough materials!',
    ['not_enough_money'] = 'You don\'t have enough money! Required: $%s',
    ['not_enough_materials_button'] = 'Not enough materials',
    ['hands_not_empty'] = 'Your hands must be empty to collect',
    
    -- Collection & Farming
    ['collecting'] = 'Collecting %s...',
    ['collecting_progress'] = 'Collecting...',
    ['collecting_success'] = 'Successfully collected %s!',
    ['cooldown_active'] = 'You need to wait before collecting again',
    ['no_luck'] = 'You didn\'t find anything this time...',
    ['weather_too_bad'] = 'The weather is too bad for farming',
    
    -- Requirements & Restrictions
    ['wrong_job'] = 'You don\'t have the right job for this!',
    ['missing_required_item'] = 'You\'re missing a required item!',
    
    -- Orders System
    ['order_number'] = '#%d',
    ['order_summary'] = 'Order Summary',
    ['order_not_found'] = 'Order not found!',
    ['order_not_complete'] = 'The order is not complete yet!',
    ['order_collected'] = 'Order successfully collected!',
    ['order_cancelled'] = 'Order cancelled - partial refund received',
    ['active_order_exists'] = 'You already have an active order!',
    ['no_active_orders'] = 'No active orders',
    
    -- Production & Recipes
    ['production_details'] = 'Production Details',
    ['total_production'] = 'Total Production:',
    ['total_price'] = 'Total Price',
    ['recipes'] = 'Recipes',
    ['all_recipes'] = 'All Recipes',
    ['no_recipes_found'] = 'No recipes found',
    ['craftable'] = 'Craftable',
    ['select_amount'] = 'Select Amount',
    
    -- Resources & Materials
    ['required_materials'] = 'Required Materials',
    ['resource_calculation'] = 'Resource Calculation',
    ['available'] = 'available',
    ['needed'] = 'needed',
    ['free'] = 'Free',
    ['reward'] = 'Outcome',
    ['per_unit'] = 'Per Unit',
    
    -- Status & Progress
    ['ready_for_collection'] = 'Ready for collection',
    ['starting'] = 'Starting...',
    ['completed'] = 'Completed',
    ['active_orders'] = 'Active Orders',
    ['filter'] = 'Filter',
    ['try_different_filter'] = 'Try a different filter',
    
    -- Time Formatting
    ['time_remaining'] = '%s remaining',
    ['time_format_hours'] = '%dh %dm remaining',
    ['time_format_minutes'] = '%dm %ds remaining',
    ['time_format_seconds'] = '%ds remaining',
    
    -- Skills & Progress
    ['skill_increased'] = 'Farming skill increased to level %s!',
    ['xp_gained'] = '+%s XP'
}

-- German locale
Locales['de'] = {
    -- Systemmeldungen
    ['config_error'] = 'Konfigurationsfehler - bitte kontaktiere einen Administrator',
    ['invalid_spot'] = 'Ungültiger Farming-Spot',
    ['one_moment'] = 'Einen Moment...',

    -- Allgemeine Aktionen
    ['press_to_collect'] = 'Drücke ~INPUT_CONTEXT~ um %s zu sammeln',
    ['press_to_process'] = 'Drücke ~INPUT_CONTEXT~ um die Verarbeitung zu öffnen',
    ['press_esc'] = 'ESC zum Schließen',
    ['collect'] = 'Abholen',
    ['cancel'] = 'Abbrechen',
    ['craft'] = 'Herstellen',
    
    -- Verarbeitung & Herstellung
    ['processing'] = 'Verarbeitung',
    ['processing_status'] = 'In Bearbeitung',
    ['processing_progress'] = 'Verarbeite...',
    ['crafting_started'] = 'Herstellung gestartet!',
    ['select_recipe'] = 'Wähle ein Rezept zum Verarbeiten',
    ['recipe_not_allowed'] = 'Dieses Rezept kann hier nicht hergestellt werden!',
    ['recipe_not_found'] = 'Rezept nicht gefunden!',
    ['invalid_recipe'] = 'Ungültiges Rezept!',
    ['no_processor_selected'] = 'Kein Verarbeiter ausgewählt',
    
    -- Inventar & Ressourcen
    ['inventory_full'] = 'Du kannst nicht so viel tragen! Mach zuerst Platz im Inventar.',
    ['your_inventory'] = 'Dein Inventar',
    ['not_enough_materials'] = 'Du hast nicht genug Materialien!',
    ['not_enough_money'] = 'Du hast nicht genug Geld! Benötigt: $%s',
    ['not_enough_materials_button'] = 'Nicht genug Materialien',
    ['hands_not_empty'] = 'Deine Hände müssen leer sein zum Sammeln',
    
    -- Sammeln & Farming
    ['collecting'] = 'Sammle %s...',
    ['collecting_progress'] = 'Sammeln...',
    ['collecting_success'] = 'Erfolgreich %s gesammelt!',
    ['cooldown_active'] = 'Du musst noch warten, bevor du wieder sammeln kannst',
    ['no_luck'] = 'Diesmal hast du nichts gefunden...',
    ['weather_too_bad'] = 'Das Wetter ist zu schlecht zum Farmen',
    
    -- Anforderungen & Einschränkungen
    ['wrong_job'] = 'Du hast nicht den richtigen Job dafür!',
    ['missing_required_item'] = 'Dir fehlt ein benötigtes Item!',
    
    -- Auftragssystem
    ['order_number'] = '#%d',
    ['order_summary'] = 'Auftragsübersicht',
    ['order_not_found'] = 'Auftrag nicht gefunden!',
    ['order_not_complete'] = 'Der Auftrag ist noch nicht fertig!',
    ['order_collected'] = 'Auftrag erfolgreich abgeholt!',
    ['order_cancelled'] = 'Auftrag abgebrochen - teilweise Rückerstattung erhalten',
    ['active_order_exists'] = 'Du hast bereits einen aktiven Auftrag!',
    ['no_active_orders'] = 'Keine aktiven Aufträge',
    
    -- Produktion & Rezepte
    ['production_details'] = 'Produktionsdetails',
    ['total_production'] = 'Gesamte Produktion:',
    ['total_price'] = 'Gesamtpreis',
    ['recipes'] = 'Rezepte',
    ['all_recipes'] = 'Alle Rezepte',
    ['no_recipes_found'] = 'Keine Rezepte gefunden',
    ['craftable'] = 'Herstellbar',
    ['select_amount'] = 'Menge auswählen',
    
    -- Ressourcen & Materialien
    ['required_materials'] = 'Benötigte Materialien',
    ['resource_calculation'] = 'Ressourcenberechnung',
    ['available'] = 'verfügbar',
    ['needed'] = 'benötigt',
    ['free'] = 'Kostenlos',
    ['reward'] = 'Ergebnis',
    ['per_unit'] = 'Pro Einheit',
    
    -- Status & Fortschritt
    ['ready_for_collection'] = 'Fertig zum Abholen',
    ['starting'] = 'Wird gestartet...',
    ['completed'] = 'Abgeschlossen',
    ['active_orders'] = 'Aktive Aufträge',
    ['filter'] = 'Filter',
    ['try_different_filter'] = 'Versuche einen anderen Filter',
    
    -- Zeitformatierung
    ['time_remaining'] = '%s übrig',
    ['time_format_hours'] = '%dh %dm übrig',
    ['time_format_minutes'] = '%dm %ds übrig',
    ['time_format_seconds'] = '%ds übrig',
    
    -- Fähigkeiten & Fortschritt
    ['skill_increased'] = 'Farming-Fähigkeit auf Level %s erhöht!',
    ['xp_gained'] = '+%s EP'
}

Locales['ru'] = {
    -- Системные сообщения
    ['config_error'] = 'Ошибка конфигурации - обратитесь к администратору',
    ['invalid_spot'] = 'Неверная точка фарминга',
    ['one_moment'] = 'Подождите...',

    -- Общие действия
    ['press_to_collect'] = 'Нажмите ~INPUT_CONTEXT~ чтобы собрать %s',
    ['press_to_process'] = 'Нажмите ~INPUT_CONTEXT~ чтобы открыть обработку',
    ['press_esc'] = 'ESC для закрытия',
    ['collect'] = 'Забрать',
    ['cancel'] = 'Отмена',
    ['craft'] = 'Создать',
    
    -- Обработка и создание
    ['processing'] = 'Обработка',
    ['processing_status'] = 'В процессе',
    ['processing_progress'] = 'Обработка...',
    ['crafting_started'] = 'Создание начато!',
    ['select_recipe'] = 'Выберите рецепт для обработки',
    ['recipe_not_allowed'] = 'Этот рецепт нельзя создать здесь!',
    ['recipe_not_found'] = 'Рецепт не найден!',
    ['invalid_recipe'] = 'Неверный рецепт!',
    ['no_processor_selected'] = 'Не выбран обработчик',
    
    -- Инвентарь и ресурсы
    ['inventory_full'] = 'Вы не можете нести так много! Сначала освободите место в инвентаре.',
    ['your_inventory'] = 'Ваш инвентарь',
    ['not_enough_materials'] = 'У вас недостаточно материалов!',
    ['not_enough_money'] = 'У вас недостаточно денег! Требуется: $%s',
    ['not_enough_materials_button'] = 'Недостаточно материалов',
    ['hands_not_empty'] = 'Ваши руки должны быть пусты для сбора',
    
    -- Сбор и фарминг
    ['collecting'] = 'Сбор %s...',
    ['collecting_progress'] = 'Сбор...',
    ['collecting_success'] = 'Успешно собрано %s!',
    ['cooldown_active'] = 'Нужно подождать перед следующим сбором',
    ['no_luck'] = 'В этот раз ничего не найдено...',
    ['weather_too_bad'] = 'Слишком плохая погода для фарминга',
    
    -- Требования и ограничения
    ['wrong_job'] = 'У вас нет нужной работы для этого!',
    ['missing_required_item'] = 'У вас нет необходимого предмета!',
    
    -- Система заказов
    ['order_number'] = '#%d',
    ['order_summary'] = 'Сводка заказа',
    ['order_not_found'] = 'Заказ не найден!',
    ['order_not_complete'] = 'Заказ еще не готов!',
    ['order_collected'] = 'Заказ успешно получен!',
    ['order_cancelled'] = 'Заказ отменен - получен частичный возврат',
    ['active_order_exists'] = 'У вас уже есть активный заказ!',
    ['no_active_orders'] = 'Нет активных заказов',
    
    -- Производство и рецепты
    ['production_details'] = 'Детали производства',
    ['total_production'] = 'Общее производство:',
    ['total_price'] = 'Общая цена',
    ['recipes'] = 'Рецепты',
    ['all_recipes'] = 'Все рецепты',
    ['no_recipes_found'] = 'Рецепты не найдены',
    ['craftable'] = 'Доступно для создания',
    ['select_amount'] = 'Выберите количество',
    
    -- Ресурсы и материалы
    ['required_materials'] = 'Необходимые материалы',
    ['resource_calculation'] = 'Расчет ресурсов',
    ['available'] = 'доступно',
    ['needed'] = 'требуется',
    ['free'] = 'Бесплатно',
    ['reward'] = 'Результат',
    ['per_unit'] = 'За единицу',
    
    -- Статус и прогресс
    ['ready_for_collection'] = 'Готово к получению',
    ['starting'] = 'Начинается...',
    ['completed'] = 'Завершено',
    ['active_orders'] = 'Активные заказы',
    ['filter'] = 'Фильтр',
    ['try_different_filter'] = 'Попробуйте другой фильтр',
    
    -- Форматирование времени
    ['time_remaining'] = 'осталось %s',
    ['time_format_hours'] = 'осталось %dч %dм',
    ['time_format_minutes'] = 'осталось %dм %dс',
    ['time_format_seconds'] = 'осталось %dс',
    
    -- Навыки и прогресс
    ['skill_increased'] = 'Навык фарминга повышен до уровня %s!',
    ['xp_gained'] = '+%s ОП'
}