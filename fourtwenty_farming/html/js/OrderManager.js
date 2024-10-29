// js/modules/OrderManager.js
import AppState from './AppState.js';
import LocaleManager from './LocaleManager.js';

/**
 * Manages order-related functionality
 */
class OrderManager {
    /**
     * Initialize order updates
     */
    startOrderUpdates() {
        if (AppState.orderUpdateInterval) {
            clearInterval(AppState.orderUpdateInterval);
        }
        AppState.orderUpdateInterval = setInterval(() => this.updateAllOrders(), 1000);
    }

    /**
     * Stop order updates
     */
    stopOrderUpdates() {
        if (AppState.orderUpdateInterval) {
            clearInterval(AppState.orderUpdateInterval);
            AppState.orderUpdateInterval = null;
        }
    }


    /**
     * Show empty state when no orders exist
     * @param {HTMLElement} container - Container element
     */
    showEmptyState(container) {
        container.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-box-open"></i>
                <p>${LocaleManager.translate('no_active_orders')}</p>
            </div>
        `;
    }


    /**
     * Update orders with new data and start update interval
     * @param {Array} orders - Order data
     * @param {number|null} pendingId - Pending order ID
     */
    updateOrders(orders, pendingId = null) {
        AppState.activeOrders = orders;
        AppState.pendingOrderId = pendingId;
        
        const container = document.getElementById('active-orders');
        if (!container) return;
        
        container.innerHTML = '';

        if ((!orders || orders.length === 0) && !pendingId) {
            this.showEmptyState(container);
            return;
        }

        const allOrders = this.getAllOrders(orders, pendingId);
        this.displayOrders(container, allOrders);
        this.startOrderUpdates();
    }

    /**
     * Get all orders including pending
     * @param {Array} orders - Existing orders
     * @param {number|null} pendingId - Pending order ID
     * @returns {Array}
     */
    getAllOrders(orders, pendingId) {
        const allOrders = [...orders];
        if (pendingId && !orders.find(o => o.id === pendingId)) {
            const recipe = AppState.recipes[AppState.selectedRecipe];
            if (recipe) {
                const craftingTime = recipe.time * 1000;
                allOrders.push({
                    id: pendingId,
                    recipe_name: AppState.selectedRecipe,
                    amount: parseInt(document.getElementById('amount-input')?.value || 1),
                    start_time: new Date().toISOString(),
                    completion_time: new Date(Date.now() + craftingTime).toISOString(),
                    pending: true
                });
            }
        }
        return this.sortOrders(allOrders);
    }

    /**
     * Sort orders by start time
     * @param {Array} orders - Orders to sort
     * @returns {Array}
     */
    sortOrders(orders) {
        return orders.sort((a, b) => 
            new Date(b.start_time) - new Date(a.start_time)
        );
    }

    /**
     * Display orders in container
     * @param {HTMLElement} container - Container element
     * @param {Array} orders - Orders to display
     */
    displayOrders(container, orders) {
        orders.forEach(order => {
            const recipe = AppState.recipes[order.recipe_name];
            if (!recipe) return;

            const progress = order.pending ? 0 : this.calculateProgress(order);
            const orderCard = this.createOrderCard(order, recipe, progress);
            container.appendChild(orderCard);
        });
    }

    /**
     * Create order card element
     * @param {Object} order - Order data
     * @param {Object} recipe - Recipe data
     * @param {number} progress - Order progress
     * @returns {HTMLElement}
     */
    createOrderCard(order, recipe, progress) {
        const card = document.createElement('div');
        card.className = `order-card fade-in ${order.pending ? 'pending' : ''}`;
        card.dataset.orderId = order.id;
        
        card.innerHTML = `
            <div class="recipe-header">
                <div class="recipe-icon">
                    <i class="fas ${this.getRecipeIcon(recipe.label)}"></i>
                </div>
                <div class="recipe-info">
                    <h3 class="recipe-title">${recipe.label}</h3>
                    <div class="order-details">
                        <span class="order-amount">${order.amount}x</span>
                        <span class="order-id">${LocaleManager.translate('order_number', order.id)}</span>
                    </div>
                </div>
            </div>

            <div class="order-progress">
                <div class="progress-status">
                    <span>${this.getOrderStatus(order, progress)}</span>
                    <span class="time-countdown">
                        ${this.getTimeDisplay(order, progress)}
                    </span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill ${progress < 100 ? 'active' : ''}" 
                         style="width: ${progress}%"></div>
                </div>
            </div>

            ${this.getOrderActions(order, progress)}
        `;

        return card;
    }

    /**
     * Get order status text
     * @param {Object} order - Order data
     * @param {number} progress - Order progress
     * @returns {string}
     */
    getOrderStatus(order, progress) {
        if (order.pending) return LocaleManager.translate('starting');
        if (progress >= 100) return LocaleManager.translate('ready_for_collection');
        return LocaleManager.translate('processing_status');
    }

    /**
     * Get time display text
     * @param {Object} order - Order data
     * @param {number} progress - Order progress
     * @returns {string}
     */
    getTimeDisplay(order, progress) {
        if (order.pending) return LocaleManager.translate('one_moment');
        if (progress >= 100) return LocaleManager.translate('completed');
        return this.calculateTimeLeft(order);
    }

    /**
     * Get order action buttons
     * @param {Object} order - Order data
     * @param {number} progress - Order progress
     * @returns {string}
     */
    getOrderActions(order, progress) {
        if (progress >= 100 && !order.pending) {
            return `
                <button class="craft-button" onclick="window.collectOrder(${order.id})">
                    <i class="fas fa-box"></i>
                    <span>${LocaleManager.translate('collect')}</span>
                </button>
            `;
        }
        return '';
    }

    /**
     * Calculate order progress
     * @param {Object} order - Order data
     * @returns {number}
     */
    calculateProgress(order) {
        if (order.pending) return 0;
        
        const now = new Date().getTime();
        const start = new Date(order.start_time).getTime();
        const end = new Date(order.completion_time).getTime();
        
        const elapsedTime = now - start;
        const totalTime = end - start;
        const progress = (elapsedTime / totalTime) * 100;
        
        return Math.min(Math.max(Math.round(progress * 100) / 100, 0), 100);
    }

    /**
     * Calculate time left for order
     * @param {Object} order - Order data
     * @returns {string}
     */
    calculateTimeLeft(order) {
        const now = new Date().getTime();
        const end = new Date(order.completion_time).getTime();
        const timeLeft = end - now;

        if (timeLeft <= 0) return '';

        const seconds = Math.floor(timeLeft / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);

        if (hours > 0) {
            return LocaleManager.translate('time_format_hours', hours, minutes % 60);
        } else if (minutes > 0) {
            return LocaleManager.translate('time_format_minutes', minutes, seconds % 60);
        } else {
            return LocaleManager.translate('time_format_seconds', seconds);
        }
    }

    /**
     * Update single order card
     * @param {HTMLElement} orderCard - Order card element
     * @param {Object} order - Order data
     */
    updateOrderCard(orderCard, order) {
        const progressElement = orderCard.querySelector('.progress-fill');
        const statusElement = orderCard.querySelector('.progress-status');
        const progress = this.calculateProgress(order);
    
        if (progressElement.style.width !== `${progress}%`) {
            progressElement.style.width = `${progress}%`;
            progressElement.classList.toggle('active', progress < 100);
    
            if (progress < 100) {
                // Hier das orderCard mit übergeben
                this.updateInProgressCard(orderCard, statusElement, order);
            } else if (!order.pending) {
                this.updateCompletedCard(orderCard, statusElement);
            }
        }
    }


        /**
     * Update in-progress card
     * @param {HTMLElement} orderCard - Order card element
     * @param {HTMLElement} statusElement - Status element
     * @param {Object} order - Order data
     */
    updateInProgressCard(orderCard, statusElement, order) {
        const timeLeft = this.calculateTimeLeft(order);
        statusElement.innerHTML = `
            <span>${LocaleManager.translate('processing_status')}</span>
            <span class="time-countdown">${timeLeft}</span>
        `;
        
        const existingButton = orderCard.querySelector('.craft-button');
        if (existingButton) {
            existingButton.remove();
        }
    }

        /**
     * Update completed card
     * @param {HTMLElement} orderCard - Order card element
     * @param {HTMLElement} statusElement - Status element
     */
    updateCompletedCard(orderCard, statusElement) {
        // Get the order ID from the card's data attribute
        const orderId = orderCard.dataset.orderId;
        
        if (!orderId) {
            console.error('No order ID found on card');
            return;
        }

        if (!orderCard.classList.contains('completed')) {
            orderCard.classList.add('completion-flash', 'completed');
        }

        statusElement.innerHTML = `
            <span>${LocaleManager.translate('ready_for_collection')}</span>
            <span class="time-countdown">${LocaleManager.translate('completed')}</span>
        `;
        
        if (!orderCard.querySelector('.craft-button')) {
            const buttonContainer = document.createElement('div');
            buttonContainer.innerHTML = `
                <button class="craft-button" onclick="window.collectOrder(${orderId})">
                    <i class="fas fa-box"></i>
                    <span>${LocaleManager.translate('collect')}</span>
                </button>
            `;
            orderCard.appendChild(buttonContainer.firstElementChild);
        }
    }

    /**
     * Get recipe icon based on recipe label
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
     * Load active orders
     * @param {Array} orders - Order data
     * @param {number|null} pendingId - Pending order ID
     */
    updateAllOrders() {
        document.querySelectorAll('.order-card').forEach(orderCard => {
            const orderId = parseInt(orderCard.dataset.orderId);
            const order = AppState.activeOrders.find(o => o.id === orderId);
            
            if (!order && orderId !== AppState.pendingOrderId) {
                orderCard.remove();
                return;
            }

            if (order) {
                this.updateOrderCard(orderCard, order);
            }
        });
    }

    /**
     * Collect an order
     * @param {number} orderId - Order identifier
     */
    async collectOrder(orderId) {
        try {
            await fetch(`https://${GetParentResourceName()}/collectOrder`, {
                method: 'POST',
                body: JSON.stringify({ orderId })
            });
        } catch (error) {
            console.error('Failed to collect order:', error);
        }
    }
}

export default new OrderManager();