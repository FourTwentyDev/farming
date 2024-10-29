/**
 * Manages translations and localization
 */
class LocaleManager {
    constructor() {
        // Observer für dynamisch hinzugefügte Elemente
        this.observer = new MutationObserver(() => this.translateAllElements());
    }

    /**
     * Initialize the LocaleManager
     */
    initialize() {
        // Observer starten
        this.observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }

    /**
     * Translate a key with optional parameters
     * @param {string} key - Translation key
     * @param {...any} args - Replacement arguments
     * @returns {string}
     */
    translate(key, ...args) {
        let translation = AppState.translations[key] || key;
        
        if (args && args.length > 0) {
            translation = translation.replace(/%[ds]/g, (match) => {
                const arg = args.shift();
                return arg !== undefined ? arg : match;
            });
        }

        return translation;
    }

    /**
     * Set new translations and update all elements
     * @param {Object} translations - Translation key-value pairs
     */
    setTranslations(translations) {
        AppState.translations = translations;
        this.translateAllElements();
    }

    /**
     * Translate all elements with data-locale attributes
     */
    translateAllElements() {
        document.querySelectorAll('[data-locale]').forEach(element => {
            const key = element.getAttribute('data-locale');
            if (key) {
                // Prüfen auf zusätzliche Argumente in data-locale-args
                const args = element.getAttribute('data-locale-args');
                const translatedArgs = args ? JSON.parse(args) : [];
                element.textContent = this.translate(key, ...translatedArgs);
            }
        });
    }

    /**
     * Translate a specific element
     * @param {HTMLElement} element - Element to translate
     */
    translateElement(element) {
        const key = element.getAttribute('data-locale');
        if (key) {
            const args = element.getAttribute('data-locale-args');
            const translatedArgs = args ? JSON.parse(args) : [];
            element.textContent = this.translate(key, ...translatedArgs);
        }
    }
}

const localeManager = new LocaleManager();
localeManager.initialize();

export default localeManager;