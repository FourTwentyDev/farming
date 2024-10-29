// Globale Funktionen sofort definieren, bevor Module geladen werden
window.startCrafting = function() {
    console.log('startCrafting called');
    const amountInput = document.getElementById('amount-input');
    const amount = parseInt(amountInput?.value || 0);
    console.log('Amount:', amount);
    
    if (!window.AppState) {
        console.error('AppState not initialized');
        return;
    }
    if (amount > 0 && window.AppState.selectedRecipe) {
        fetch(`https://${GetParentResourceName()}/startCrafting`, {
            method: 'POST',
            body: JSON.stringify({
                recipe: window.AppState.selectedRecipe,
                amount: amount
            })
        });
        
        if (window.ModalManager) {
            window.ModalManager.closeModal();
        }
    }
};

window.collectOrder = function(orderId) {
    console.log('collectOrder called with id:', orderId);
    if (window.OrderManager) {
        window.OrderManager.collectOrder(orderId);
    } else {
        console.error('OrderManager not initialized');
    }
};

window.closeUI = function() {
    console.log('closeUI called');
    if (window.UIManager) {
        window.UIManager.closeUI();
    } else {
        console.error('UIManager not initialized');
    }
};

window.openCraftingModal = function(recipeKey) {
    console.log('Opening crafting modal for recipe:', recipeKey);
    if (window.ModalManager) {
        window.ModalManager.openAmountModal(recipeKey);
    } else {
        console.error('ModalManager not initialized');
    }
};


// Debug-Logging für globale Funktionen
console.log('Global functions initialized:', {
    startCrafting: typeof window.startCrafting,
    collectOrder: typeof window.collectOrder,
    closeUI: typeof window.closeUI
});

// Dann Module importieren
import AppState from './AppState.js';
import LocaleManager from './LocaleManager.js';
import UIManager from './UIManager.js';
import OrderManager from './OrderManager.js';
import ModalManager from './ModalManager.js';
import RecipeManager from './RecipeManager.js';
import InventoryManager from './InventoryManager.js';

// Module global verfügbar machen
window.AppState = AppState;
window.LocaleManager = LocaleManager;
window.UIManager = UIManager;
window.OrderManager = OrderManager;
window.ModalManager = ModalManager;
window.RecipeManager = RecipeManager;
window.InventoryManager = InventoryManager;

LocaleManager.initialize();

// NUI Message Handler
// NUI Message Handler
window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('Received NUI message:', data);

    switch (data.type) {
        case 'showUI':
            console.log('Showing UI');
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
            break;

        case 'hideUI':
            console.log('Hiding UI');
            document.querySelector('.container').style.display = 'none';
            OrderManager.stopOrderUpdates();
            break;

        case 'updateOrders':
            console.log('Updating orders:', data.orders);
            OrderManager.updateOrders(data.orders, data.pendingOrderId);
            break;

        case 'updateInventory':
            console.log('Updating inventory:', data.inventory);
            AppState.playerInventory = data.inventory;
            RecipeManager.updateRecipeDisplay();
            InventoryManager.updateInventoryList();
            break;

        case 'removePendingOrder':
            console.log('Removing pending order');
            AppState.pendingOrderId = null;
            OrderManager.updateOrders(AppState.activeOrders);
            break;

        case 'craftingStarted':
            console.log('Crafting started');
            if (data.success) {
                ModalManager.closeModal();
                if (data.orderId) {
                    AppState.pendingOrderId = data.orderId;
                }
            } else if (data.error) {
                console.error('Crafting failed:', data.error);
                // Optional: Zeige Fehlermeldung an
            }
            break;

        case 'craftingCompleted':
            console.log('Crafting completed');
            if (data.orderId === AppState.pendingOrderId) {
                AppState.pendingOrderId = null;
            }
            if (data.inventory) {
                AppState.playerInventory = data.inventory;
                RecipeManager.updateRecipeDisplay();
                InventoryManager.updateInventoryList();
            }
            break;

        case 'orderCollected':
            console.log('Order collected:', data.orderId);
            if (data.success) {
                // Entferne die Order aus der aktiven Liste
                AppState.activeOrders = AppState.activeOrders.filter(
                    order => order.id !== data.orderId
                );
                OrderManager.updateOrders(AppState.activeOrders);
                
                // Update Inventar falls mitgesendet
                if (data.inventory) {
                    AppState.playerInventory = data.inventory;
                    RecipeManager.updateRecipeDisplay();
                    InventoryManager.updateInventoryList();
                }
            }
            break;

        case 'setTranslations':
            console.log('Setting translations');
            LocaleManager.setTranslations(data.translations);
            break;

        case 'error':
            console.error('Received error:', data.message);
            // Optional: Zeige Fehlermeldung im UI an
            break;

        default:
            console.log('Unknown message type:', data.type);
            break;
    }
});

// Initialisierung bestätigen
console.log('NUI Script fully loaded and initialized');

// Debug-Test der Funktionen
setTimeout(() => {
    console.log('Testing global functions availability:', {
        startCrafting: typeof window.startCrafting,
        collectOrder: typeof window.collectOrder,
        closeUI: typeof window.closeUI,
        AppState: !!window.AppState,
        UIManager: !!window.UIManager,
        OrderManager: !!window.OrderManager,
        ModalManager: !!window.ModalManager
    });
}, 1000);