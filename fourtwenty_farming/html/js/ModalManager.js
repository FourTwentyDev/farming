import AppState from './AppState.js';
import LocaleManager from './LocaleManager.js';
import InventoryManager from './InventoryManager.js';

/**
 * Manages all modal-related functionality
 */
class ModalManager {
    constructor() {
        this.initializeEventListeners();
    }

    /**
     * Initialize modal event listeners
     */
    initializeEventListeners() {
        document.addEventListener('keyup', (event) => {
            if (event.key === 'Escape' && this.isModalActive()) {
                this.closeModal();
            }
        });
        
        document.getElementById('amount-input')?.addEventListener('input', (e) => {
            this.handleAmountInput(e.target);
        });

        
    }

    handleCraftClick(e) {
        const amount = parseInt(document.getElementById('amount-input')?.value || 0);
        if (amount > 0 && AppState.selectedRecipe) {
            window.startCrafting(); 
        }
    }
    

    /**
     * Check if modal is currently active
     * @returns {boolean}
     */
    isModalActive() {
        return document.getElementById('amount-modal')?.classList.contains('active') || false;
    }

    /**
     * Open amount selection modal
     * @param {string} recipeKey - Recipe identifier
     */
    openAmountModal(recipeKey) {
        AppState.selectedRecipe = recipeKey;
        const recipe = AppState.recipes[recipeKey];
        if (!recipe) return;

        const modal = document.getElementById('amount-modal');
        this.updateModalContent(recipe);
        this.updateResourceCalculation();
        modal.classList.add('active');
    }
    /**
     * Update modal content with recipe information
     * @param {Object} recipe - Recipe data
     */
    updateModalContent(recipe) {
        const preview = document.getElementById('recipe-preview');
        
        preview.innerHTML = `
            <div class="recipe-header">
                <div class="recipe-icon">
                    <i class="fas ${this.getRecipeIcon(recipe.label)}"></i>
                </div>
                <div class="recipe-info">
                    <h3>${recipe.label}</h3>
                    <div class="recipe-meta">
                        <span class="recipe-meta-item">
                            <i class="fas fa-tag"></i>
                            ${recipe.category}
                        </span>
                        <span class="recipe-meta-item">
                            <i class="fas fa-clock"></i>
                            ${recipe.time}s
                        </span>
                    </div>
                </div>
            </div>

            <div class="production-info">
                <h4>${LocaleManager.translate('per_unit')}:</h4>
                <div class="reward-preview">
                    <img src="nui://inventory/web/dist/assets/items/${recipe.rewards[0].item}.png" 
                         alt="${recipe.rewards[0].label}" 
                         class="item-image">
                    <span>${recipe.rewards[0].amount}x ${recipe.rewards[0].label}</span>
                </div>
            </div>
        `;

        // Initialize amount controls
        const existingControls = document.querySelector('.amount-control');
        if (!existingControls) {
            this.initializeAmountControls();
        }
    }

    /**
     * Initialize amount control buttons
     */
    initializeAmountControls() {
        document.getElementById('amount-decrease')?.addEventListener('click', () => {
            this.adjustAmount('decrease');
        });

        document.getElementById('amount-increase')?.addEventListener('click', () => {
            this.adjustAmount('increase');
        });
    }

    /**
     * Adjust amount value
     * @param {string} direction - 'increase' or 'decrease'
     */
    adjustAmount(direction) {
        const input = document.getElementById('amount-input');
        if (!input) return;

        let value = parseInt(input.value) || 1;
        if (direction === 'increase') {
            value = Math.min(value + 1, 999);
        } else {
            value = Math.max(value - 1, 1);
        }

        input.value = value;
        this.updateResourceCalculation();
    }

    /**
     * Handle amount input changes
     * @param {HTMLInputElement} input - Amount input element
     */
    handleAmountInput(input) {
        let value = parseInt(input.value) || 1;
        value = Math.max(1, Math.min(value, 999));
        input.value = value;
        this.updateResourceCalculation();
    }

    /**
     * Update resource calculation based on current amount
     */
    updateResourceCalculation() {
        if (!AppState.selectedRecipe) return;

        const amount = parseInt(document.getElementById('amount-input')?.value || 1);
        const recipe = AppState.recipes[AppState.selectedRecipe];
        const calculation = document.getElementById('resource-calculation');

        const totalProduction = this.calculateTotalProduction(recipe, amount);
        const totalPrice = this.calculateTotalPrice(recipe, amount);
        const materialsHtml = this.calculateRequiredMaterials(recipe, amount);

        calculation.innerHTML = `
            <div class="calculation-header">
                <i class="fas fa-calculator"></i>
                ${LocaleManager.translate('resource_calculation')}
            </div>
            
            <div class="resource-item price ${totalPrice === 0 ? 'free' : ''}">
                <div class="resource-name">
                    <i class="fas fa-coins"></i>
                    ${LocaleManager.translate('total_price')}
                </div>
                <span>${totalPrice > 0 ? `$${totalPrice.toLocaleString()}` : LocaleManager.translate('free')}</span>
            </div>

            <div class="materials-list">
                ${materialsHtml}
            </div>
        `;
    }

    /**
     * Calculate total production information
     * @param {Object} recipe - Recipe data
     * @param {number} amount - Crafting amount
     * @returns {Object}
     */
    calculateTotalProduction(recipe, amount) {
        const reward = recipe.rewards[0];
        return {
            amount: reward.amount * amount,
            label: reward.label,
            item: reward.item
        };
    }

    /**
     * Calculate total price
     * @param {Object} recipe - Recipe data
     * @param {number} amount - Crafting amount
     * @returns {number}
     */
    calculateTotalPrice(recipe, amount) {
        return recipe.price * amount;
    }

    /**
     * Calculate required materials
     * @param {Object} recipe - Recipe data
     * @param {number} amount - Crafting amount
     * @returns {string}
     */
    calculateRequiredMaterials(recipe, amount) {
        return recipe.requires.map(req => {
            const itemData = AppState.playerInventory[req.item] || { count: 0, label: req.label };
            const needed = req.amount * amount;
            const hasEnough = InventoryManager.hasItemInInventory(req.item, needed);
            const percentage = Math.min(Math.round((itemData.count / needed) * 100), 100);
            
            return this.createMaterialRequirementHtml(req, itemData, needed, hasEnough, percentage);
        }).join('');
    }

    /**
     * Create HTML for material requirement
     * @param {Object} requirement - Requirement data
     * @param {Object} itemData - Current inventory data
     * @param {number} needed - Amount needed
     * @param {boolean} hasEnough - Whether player has enough
     * @param {number} percentage - Completion percentage
     * @returns {string}
     */
    createMaterialRequirementHtml(requirement, itemData, needed, hasEnough, percentage) {
        return `
            <div class="requirement-item ${hasEnough ? 'available' : 'unavailable'}">
                <div class="req-header">
                    <div class="req-info">
                        <img src="nui://inventory/web/dist/assets/items/${requirement.item}.png" 
                             alt="${requirement.label}" 
                             class="item-image">
                        <span class="req-label">${requirement.label}</span>
                    </div>
                    <span class="req-amount ${hasEnough ? '' : 'insufficient'}">
                        ${needed} ${LocaleManager.translate('needed')}
                    </span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${percentage}%"></div>
                </div>
                <div class="req-status">
                    <span>${itemData.count} ${LocaleManager.translate('available')}</span>
                </div>
            </div>
        `;
    }

    /**
     * Create summary section HTML
     * @param {Object} production - Production information
     * @returns {string}
     */
    createSummarySection(production) {
        return `
            <div class="summary-section">
                <h4>${LocaleManager.translate('total_production')}</h4>
                <div class="production-details">
                    <img src="nui://inventory/web/dist/assets/items/${production.item}.png" 
                         alt="${production.label}" 
                         class="item-image">
                    <span>${production.amount}x ${production.label}</span>
                </div>
            </div>
        `;
    }

    /**
     * Create price section HTML
     * @param {number} totalPrice - Total price
     * @returns {string}
     */
    createPriceSection(totalPrice) {
        return `
            <div class="price-section">
                <div class="price-header">
                    <i class="fas fa-coins"></i>
                    <span>${LocaleManager.translate('total_price')}</span>
                </div>
                <span class="price-amount">
                    ${totalPrice > 0 ? `$${totalPrice.toLocaleString()}` : LocaleManager.translate('free')}
                </span>
            </div>
        `;
    }

    /**
     * Create materials section HTML
     * @param {string} materialsHtml - Materials HTML content
     * @returns {string}
     */
    createMaterialsSection(materialsHtml) {
        return `
            <div class="materials-section">
                <h4>${LocaleManager.translate('required_materials')}</h4>
                <div class="materials-list">
                    ${materialsHtml}
                </div>
            </div>
        `;
    }

    /**
     * Create action buttons HTML
     * @returns {string}
     */
    createActionButtons() {
        return `
            <div class="modal-actions">
                <button onclick="window.startCrafting()" class="craft-button modal-craft">
                    <i class="fas fa-hammer"></i>
                    <span>${LocaleManager.translate('craft')}</span>
                </button>
                <button onclick="window.ModalManager.closeModal()" class="cancel-button">
                    ${LocaleManager.translate('cancel')}
                </button>
            </div>
        `;
    }

    /**
     * Get icon class for recipe type
     * @param {string} label - Recipe label
     * @returns {string}
     */
    getRecipeIcon(label) {
        const iconMap = {
            'Bread': 'fa-bread-slice',
            'Dough': 'fa-cookie-dough',
            'Flour': 'fa-wheat',
            // Add more mappings as needed
        };
        return iconMap[label] || 'fa-mortar-pestle';
    }

    /**
     * Close modal
     */
    closeModal() {
        const modal = document.getElementById('amount-modal');
        modal?.classList.remove('active');
        AppState.selectedRecipe = null;
    }
}

export default new ModalManager();