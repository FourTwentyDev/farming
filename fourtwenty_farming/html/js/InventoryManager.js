import AppState from './AppState.js';
import LocaleManager from './LocaleManager.js';

/**
 * Manages inventory-related functionality
 */
class InventoryManager {
    /**
     * Check if a recipe can be crafted
     * @param {Object} recipe - Recipe data
     * @returns {boolean}
     */
    canCraftRecipe(recipe) {
        return recipe.requires.every(req => 
            this.hasItemInInventory(req.item, req.amount)
        );
    }

    /**
     * Check if player has enough of an item
     * @param {string} item - Item identifier
     * @param {number} amount - Required amount
     * @returns {boolean}
     */
    hasItemInInventory(item, amount) {
        return (AppState.playerInventory[item]?.count || 0) >= amount;
    }

    /**
     * Update inventory display
     */
    updateInventoryList() {
        const container = document.getElementById('inventory-list');
        container.innerHTML = '';

        this.getSortedInventory()
            .forEach(([itemName, itemData]) => {
                container.appendChild(
                    this.createInventoryItem(itemData)
                );
            });
    }

    /**
     * Get sorted inventory items
     * @returns {Array}
     */
    getSortedInventory() {
        return Object.entries(AppState.playerInventory)
            .sort((a, b) => b[1].count - a[1].count);
    }

    /**
     * Create inventory item element
     * @param {Object} itemData - Item data
     * @returns {HTMLElement}
     */
    createInventoryItem(itemData) {
        const itemElement = document.createElement('div');
        itemElement.className = 'inventory-item';
        itemElement.innerHTML = `
            <div class="item-info">
                <span class="item-name">${itemData.label}</span>
                <span class="item-amount">${itemData.count}x</span>
            </div>
        `;
        return itemElement;
    }
}

export default new InventoryManager();