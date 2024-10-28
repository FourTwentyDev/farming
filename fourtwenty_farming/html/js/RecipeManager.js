// js/modules/RecipeManager.js
import AppState from './AppState.js';
import LocaleManager from './LocaleManager.js';
import InventoryManager from './InventoryManager.js';
import ModalManager from './ModalManager.js';

/**
 * Manages recipe-related functionality
 */
class RecipeManager {
    /**
     * Create a recipe card element
     * @param {string} key - Recipe identifier
     * @param {Object} recipe - Recipe data
     * @returns {HTMLElement}
     */
    createRecipeCard(key, recipe) {
        const canCraft = InventoryManager.canCraftRecipe(recipe);
        const card = document.createElement('div');
        card.className = `recipe-card ${canCraft ? '' : 'disabled'} fade-in`;

        const priceString = this.formatPrice(recipe.price);
        const rewardInfo = this.formatRewardInfo(recipe.rewards[0]);

        card.innerHTML = this.getRecipeCardTemplate(key, recipe, canCraft, priceString, rewardInfo);
        this.attachCardEventListeners(card, key, canCraft);
        
        return card;
    }

    /**
     * Attach event listeners to recipe card
     * @param {HTMLElement} card - Recipe card element
     * @param {string} key - Recipe identifier
     * @param {boolean} canCraft - Whether recipe can be crafted
     */
    attachCardEventListeners(card, key, canCraft) {
        if (canCraft) {
            const craftButton = card.querySelector('.craft-button.recipe-craft');
            craftButton?.addEventListener('click', () => {
                console.log('Opening modal for recipe:', key);
                window.openCraftingModal(key);
            });
        }
    
        // Add hover effects and other interactions
        card.addEventListener('mouseenter', () => {
            card.classList.add('hover');
        });
    
        card.addEventListener('mouseleave', () => {
            card.classList.remove('hover');
        });
    }

    /**
     * Format price display
     * @param {number} price - Recipe price
     * @returns {string}
     */
    formatPrice(price) {
        return price > 0 
            ? `<span class="price-amount">$${price.toLocaleString()}</span>`
            : `<span class="price-free">${LocaleManager.translate('free')}</span>`;
    }

    /**
     * Format reward information
     * @param {Object} reward - Reward data
     * @returns {Object}
     */
    formatRewardInfo(reward) {
        return {
            amount: reward.amount,
            label: reward.label || reward.item,
            image: `<img src="nui://inventory/web/dist/assets/items/${reward.item}.png" 
                        alt="${reward.label}" 
                        class="item-image">`
        };
    }

    /**
     * Get recipe card HTML template
     * @param {string} key - Recipe identifier
     * @param {Object} recipe - Recipe data
     * @param {boolean} canCraft - Whether recipe can be crafted
     * @param {string} priceString - Formatted price string
     * @param {Object} rewardInfo - Formatted reward information
     * @returns {string}
     */
    getRecipeCardTemplate(key, recipe, canCraft, priceString, rewardInfo) {
        return `
            <div class="card-content">
                ${this.createCardHeader(recipe, priceString)}
                ${this.createCardBody(recipe, rewardInfo)}
                ${this.createCardFooter(key, canCraft)}
            </div>
        `;
    }

    /**
     * Create card header section
     * @param {Object} recipe - Recipe data
     * @param {string} priceString - Formatted price string
     * @returns {string}
     */
    createCardHeader(recipe, priceString) {
        return `
            <div class="card-header">
                <div class="recipe-icon">
                    <i class="fas ${this.getRecipeIcon(recipe.label)}"></i>
                </div>
                <div class="recipe-info">
                    <h3 class="recipe-title">${recipe.label}</h3>
                    <div class="recipe-meta">
                        <span class="recipe-category">
                            <i class="fas fa-tag"></i>
                            ${recipe.category}
                        </span>
                        <span class="recipe-duration">
                            <i class="fas fa-clock"></i>
                            ${recipe.time}s
                        </span>
                        <div class="price-tag ${recipe.price > 0 ? 'price-cost' : 'price-free'}">
                            ${priceString}
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    /**
     * Create card body section
     * @param {Object} recipe - Recipe data
     * @param {Object} rewardInfo - Formatted reward information
     * @returns {string}
     */
    createCardBody(recipe, rewardInfo) {
        return `
            <div class="card-body">
                ${this.createRequirementsSection(recipe)}
                ${this.createRewardSection(rewardInfo)}
            </div>
        `;
    }

    /**
     * Create requirements section
     * @param {Object} recipe - Recipe data
     * @returns {string}
     */
    createRequirementsSection(recipe) {
        const requirementsList = recipe.requires.map(req => 
            this.createRequirementItem(req)
        ).join('');

        return `
            <div class="requirements-section">
                <h4>${LocaleManager.translate('required_materials')}</h4>
                <div class="requirements-list">
                    ${requirementsList}
                </div>
            </div>
        `;
    }

    /**
     * Create single requirement item
     * @param {Object} requirement - Requirement data
     * @returns {string}
     */
    createRequirementItem(requirement) {
        const itemData = AppState.playerInventory[requirement.item] || { 
            count: 0, 
            label: requirement.label 
        };
        const hasEnough = InventoryManager.hasItemInInventory(
            requirement.item, 
            requirement.amount
        );

        return `
            <div class="requirement-item ${hasEnough ? 'available' : 'unavailable'}">
                <div class="requirement-content">
                    <img src="nui://inventory/web/dist/assets/items/${requirement.item}.png" 
                         alt="${requirement.label}" 
                         class="item-image">
                    <div class="requirement-details">
                        <span class="requirement-label">${requirement.label}</span>
                        <div class="requirement-amount">
                            <span class="current">${itemData.count}</span>
                            <span class="separator">/</span>
                            <span class="required">${requirement.amount}</span>
                        </div>
                    </div>
                </div>
                <div class="requirement-progress">
                    <div class="progress-bar">
                        <div class="progress-fill" 
                             style="width: ${Math.min((itemData.count / requirement.amount) * 100, 100)}%">
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    /**
     * Create reward section
     * @param {Object} rewardInfo - Formatted reward information
     * @returns {string}
     */
    createRewardSection(rewardInfo) {
        return `
            <div class="reward-section">
                <h4>${LocaleManager.translate('reward')}</h4>
                <div class="reward-info">
                    ${rewardInfo.image}
                    <div class="reward-details">
                        <span class="reward-amount">${rewardInfo.amount}x</span>
                        <span class="reward-label">${rewardInfo.label}</span>
                    </div>
                </div>
            </div>
        `;
    }

    /**
     * Create card footer section
     * @param {string} key - Recipe identifier
     * @param {boolean} canCraft - Whether recipe can be crafted
     * @returns {string}
     */
    createCardFooter(key, canCraft) {
        return `
            <div class="card-footer">
                <button class="craft-button recipe-craft ${canCraft ? '' : 'disabled'}" 
                        ${canCraft ? '' : 'disabled'}
                        data-recipe="${key}">
                    <i class="fas fa-hammer"></i>
                    <span>
                        ${canCraft 
                            ? LocaleManager.translate('craft') 
                            : LocaleManager.translate('not_enough_materials_button')}
                    </span>
                </button>
            </div>
        `;
    }

    /**
     * Update recipe display based on current filters
     */
    updateRecipeDisplay() {
        const grid = document.getElementById('recipe-grid');
        if (!grid) return;

        grid.innerHTML = '';
        
        const filteredRecipes = this.getFilteredRecipes();
        
        if (filteredRecipes.length === 0) {
            grid.appendChild(this.createEmptyState());
            return;
        }

        filteredRecipes.forEach(([key, recipe]) => {
            const card = this.createRecipeCard(key, recipe);
            grid.appendChild(card);
        });

        // Add fade-in animation
        requestAnimationFrame(() => {
            grid.querySelectorAll('.recipe-card').forEach((card, index) => {
                setTimeout(() => {
                    card.classList.add('visible');
                }, index * 50);
            });
        });
    }

    /**
     * Get filtered recipes based on current filters
     * @returns {Array}
     */
    getFilteredRecipes() {
        return Object.entries(AppState.recipes)
            .filter(([key, recipe]) => {
                if (AppState.activeFilters.category === 'craftable') {
                    return InventoryManager.canCraftRecipe(recipe);
                }
                return true;
            })
            .sort((a, b) => {
                // Sort by craftability first
                const canCraftA = InventoryManager.canCraftRecipe(a[1]);
                const canCraftB = InventoryManager.canCraftRecipe(b[1]);
                if (canCraftA !== canCraftB) {
                    return canCraftB - canCraftA;
                }
                // Then by name
                return a[1].label.localeCompare(b[1].label);
            });
    }

    /**
     * Create empty state element
     * @returns {HTMLElement}
     */
    createEmptyState() {
        const emptyState = document.createElement('div');
        emptyState.className = 'empty-state';
        emptyState.innerHTML = `
            <i class="fas fa-scroll"></i>
            <p>${LocaleManager.translate('no_recipes_found')}</p>
            ${AppState.activeFilters.category === 'craftable' 
                ? `<p class="empty-state-subtitle">${LocaleManager.translate('try_different_filter')}</p>` 
                : ''}
        `;
        return emptyState;
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
            'Meat': 'fa-drumstick-bite',
            'Fish': 'fa-fish',
            'Potion': 'fa-flask',
            'Weapon': 'fa-sword',
            'Tool': 'fa-tools',
            'Armor': 'fa-shield-alt',
            'Ring': 'fa-ring',
            'Scroll': 'fa-scroll',
            'Book': 'fa-book',
            'Gem': 'fa-gem',
            // Add more mappings as needed
        };
        
        // Try to find a matching icon or use a default
        return iconMap[label] || this.getDefaultIcon(label);
    }

    /**
     * Get default icon based on category or name
     * @param {string} label - Recipe label
     * @returns {string}
     */
    getDefaultIcon(label) {
        // Try to determine icon based on common keywords
        const labelLower = label.toLowerCase();
        
        if (labelLower.includes('potion') || labelLower.includes('elixir')) return 'fa-flask';
        if (labelLower.includes('sword') || labelLower.includes('weapon')) return 'fa-sword';
        if (labelLower.includes('armor') || labelLower.includes('shield')) return 'fa-shield-alt';
        if (labelLower.includes('food') || labelLower.includes('meal')) return 'fa-utensils';
        if (labelLower.includes('tool')) return 'fa-tools';
        
        return 'fa-mortar-pestle'; // Default fallback icon
    }
}

export default new RecipeManager();