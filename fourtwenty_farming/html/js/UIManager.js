import AppState from './AppState.js';
import LocaleManager from './LocaleManager.js';
import RecipeManager from './RecipeManager.js';
import OrderManager from './OrderManager.js';
import InventoryManager from './InventoryManager.js';
import ModalManager from './ModalManager.js';

/**
 * Manages UI interactions and updates
 */
class UIManager {
    constructor() {
        this.initializeEventListeners();
    }

    /**
     * Initialize all UI event listeners
     */
    initializeEventListeners() {
        this.initializeFilterListeners();
        this.initializeTabListeners();
        this.initializeGlobalListeners();
        this.initializeAmountControls();
    }

    /**
     * Initialize filter option listeners
     */
    initializeFilterListeners() {
        document.querySelectorAll('.filter-option[data-category]').forEach(option => {
            option.addEventListener('click', () => this.handleFilterClick(option));
        });
    }

    /**
     * Initialize tab switching listeners
     */
    initializeTabListeners() {
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', () => this.handleTabClick(tab));
        });
    }

    /**
     * Initialize global event listeners
     */
    initializeGlobalListeners() {
        // ESC key handling
        document.addEventListener('keyup', (event) => {
            if (event.key === 'Escape') {
                if (ModalManager.isModalActive()) {
                    ModalManager.closeModal();
                } else {
                    this.closeUI();
                }
            }
        });

        const closeButton = document.querySelector('.close-button'); // Sie müssen sicherstellen, dass Ihr Button diese Klasse hat
            if (closeButton) {
                closeButton.addEventListener('click', () => {
                this.closeUI();
            });
        }

        // NUI message handling
        window.addEventListener('message', this.handleNUIMessage.bind(this));
    }

    /**
     * Initialize amount control listeners
     */
    initializeAmountControls() {
        document.getElementById('amount-decrease').addEventListener('click', () => {
            this.updateAmount('decrease');
        });

        document.getElementById('amount-increase').addEventListener('click', () => {
            this.updateAmount('increase');
        });

        document.getElementById('amount-input').addEventListener('change', (event) => {
            this.validateAmount(event.target);
        });
    }

    /**
     * Handle filter option click
     * @param {HTMLElement} option - Clicked filter option
     */
    handleFilterClick(option) {
        document.querySelectorAll('.filter-option[data-category]').forEach(opt => {
            opt.classList.remove('active');
            opt.querySelector('.fa-check').classList.add('hidden');
        });
        
        option.classList.add('active');
        option.querySelector('.fa-check').classList.remove('hidden');
        AppState.activeFilters.category = option.dataset.category;
        
        RecipeManager.updateRecipeDisplay();
    }

    /**
     * Handle tab click
     * @param {HTMLElement} tab - Clicked tab
     */
    handleTabClick(tab) {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        
        const tabName = tab.dataset.tab;
        document.querySelectorAll('.main-content > div').forEach(content => {
            content.classList.add('hidden');
        });
        document.getElementById(`${tabName}-content`).classList.remove('hidden');
    }

    /**
     * Handle NUI messages
     * @param {MessageEvent} event - Message event
     */
    handleNUIMessage(event) {
        const { type, ...data } = event.data;

        switch (type) {
            case 'showUI':
                this.handleShowUI(data);
                break;
            case 'hideUI':
                this.handleHideUI();
                break;
            case 'updateOrders':
                this.handleUpdateOrders(data);
                break;
            case 'updateInventory':
                this.handleUpdateInventory(data);
                break;
            case 'removePendingOrder':
                this.handleRemovePendingOrder();
                break;
        }
    }

    /**
     * Handle show UI message
     * @param {Object} data - UI data
     */
    handleShowUI(data) {
        document.querySelector('.container').style.display = 'block';
        LocaleManager.setTranslations(data.translations);
        AppState.update({
            playerInventory: data.inventory || {},
            recipes: data.recipes,
            currentLocation: data.location
        });
        
        document.getElementById('location-title').textContent = data.location.label;
        RecipeManager.updateRecipeDisplay();
        InventoryManager.updateInventoryList();
    }

    /**
     * Handle hide UI message
     */
    handleHideUI() {
        document.querySelector('.container').style.display = 'none';
        OrderManager.stopOrderUpdates();
    }

    /**
     * Handle order updates
     * @param {Object} data - Order data
     */
    handleUpdateOrders(data) {
        OrderManager.updateOrders(data.orders, data.pendingOrderId);
    }

    /**
     * Handle inventory updates
     * @param {Object} data - Inventory data
     */
    handleUpdateInventory(data) {
        AppState.playerInventory = data.inventory;
        RecipeManager.updateRecipeDisplay();
        InventoryManager.updateInventoryList();
    }

    /**
     * Handle pending order removal
     */
    handleRemovePendingOrder() {
        AppState.pendingOrderId = null;
        OrderManager.updateOrders(AppState.activeOrders);
    }

    /**
     * Update amount input
     * @param {string} action - 'increase' or 'decrease'
     */
    updateAmount(action) {
        const input = document.getElementById('amount-input');
        const currentValue = parseInt(input.value) || 0;
        
        if (action === 'increase') {
            input.value = Math.min(currentValue + 1, 999);
        } else {
            input.value = Math.max(currentValue - 1, 1);
        }
        
        ModalManager.updateResourceCalculation();
    }

    /**
     * Validate amount input
     * @param {HTMLInputElement} input - Amount input element
     */
    validateAmount(input) {
        let value = parseInt(input.value) || 0;
        value = Math.max(1, Math.min(value, 999));
        input.value = value;
        ModalManager.updateResourceCalculation();
    }

    /**
     * Close UI
     */
    closeUI() {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST'
        });
    }
}

export default new UIManager();