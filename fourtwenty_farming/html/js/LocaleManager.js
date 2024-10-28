/**
 * Manages translations and localization
 */
class LocaleManager {
    /**
     * Translate a key with optional parameters
     * @param {string} key - Translation key
     * @param {...any} args - Replacement arguments
     * @returns {string}
     */
    translate(key, ...args) {
        let translation = AppState.translations[key] || key;
        
        // Wenn es Args gibt, formatieren wir den String
        if (args && args.length > 0) {
            // Ersetze %d oder %s mit den Argumenten
            translation = translation.replace(/%[ds]/g, (match) => {
                const arg = args.shift();
                return arg !== undefined ? arg : match;
            });
        }

        return translation;
    }

    /**
     * Set new translations
     * @param {Object} translations - Translation key-value pairs
     */
    setTranslations(translations) {
        AppState.translations = translations;
    }
}

export default new LocaleManager();