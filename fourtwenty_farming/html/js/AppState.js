/**
 * Central state management for the application
 */
class AppState {
    constructor() {
        this.selectedRecipe = null;
        this.recipes = {};
        this.activeOrders = [];
        this.currentLocation = '';
        this.playerInventory = {};
        this.pendingOrderId = null;
        this.activeFilters = {
            category: 'all'
        };
        this.translations = {};
        this.orderUpdateInterval = null;
    }

    /**
     * Reset the application state
     */
    reset() {
        this.selectedRecipe = null;
        this.activeOrders = [];
        this.pendingOrderId = null;
        if (this.orderUpdateInterval) {
            clearInterval(this.orderUpdateInterval);
            this.orderUpdateInterval = null;
        }
    }

    /**
     * Update the state with new data
     * @param {Object} newState - Partial state to update
     */
    update(newState) {
        Object.assign(this, newState);
    }
}

export default new AppState();