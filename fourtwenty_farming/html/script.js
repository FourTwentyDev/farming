let selectedRecipe = null;
let recipes = {};
let activeOrders = [];
let currentLocation = '';
let playerInventory = {};
let pendingOrderId = null;
let activeFilters = {
    category: 'all'
};

document.querySelectorAll('.filter-option[data-category]').forEach(option => {
    option.addEventListener('click', () => {
        document.querySelectorAll('.filter-option[data-category]').forEach(opt => {
            opt.classList.remove('active');
            opt.querySelector('.fa-check').classList.add('hidden');
        });
        option.classList.add('active');
        option.querySelector('.fa-check').classList.remove('hidden');
        activeFilters.category = option.dataset.category;
        updateRecipeDisplay();
    });
});

document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        
        const tabName = tab.dataset.tab;
        document.querySelectorAll('.main-content > div').forEach(content => {
            content.classList.add('hidden');
        });
        document.getElementById(`${tabName}-content`).classList.remove('hidden');
    });
});

function updateRecipeDisplay() {
    const grid = document.getElementById('recipe-grid');
    grid.innerHTML = '';

    Object.entries(recipes)
        .filter(([key, recipe]) => {
            if (activeFilters.category === 'craftable') {
                return canCraftRecipe(recipe);
            }
            return true;
        })
        .forEach(([key, recipe]) => {
            const card = createRecipeCard(key, recipe);
            grid.appendChild(card);
        });
}

function updateInventoryList() {
    const container = document.getElementById('inventory-list');
    container.innerHTML = '';

    Object.entries(playerInventory)
        .sort((a, b) => b[1].count - a[1].count)
        .forEach(([itemName, itemData]) => {
            const itemElement = document.createElement('div');
            itemElement.className = 'inventory-item';
            itemElement.innerHTML = `
                <div class="item-info">
                    <span class="item-name">${itemData.label}</span>
                    <span class="item-amount">${itemData.count}x</span>
                </div>
            `;
            container.appendChild(itemElement);
        });
}

// script.js continued
function createRecipeCard(key, recipe) {
    const canCraft = canCraftRecipe(recipe);
    const card = document.createElement('div');
    card.className = `recipe-card ${canCraft ? '' : 'disabled'} fade-in`;

    // Format price display
    const priceString = recipe.price > 0 
        ? `<span class="price-amount">$${recipe.price.toLocaleString()}</span>`
        : '<span class="price-free">Kostenlos</span>';

    // Reward item info with image placeholder
    const rewardAmount = recipe.rewards[0].amount;
    const rewardLabel = recipe.rewards[0].label || recipe.rewards[0].item;
    const rewardImage = `<img src="nui://inventory/web/dist/assets/items/${recipe.rewards[0].item}.png" alt="${rewardLabel}" class="item-image">`;

    card.innerHTML = `
        <div class="card-content">
            <!-- Main Info Section -->
            <div class="card-header">
                <div class="recipe-icon">
                    <i class="fas ${getRecipeIcon(recipe.label)}"></i>
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

            <!-- Two Column Layout for Requirements and Reward -->
            <div class="card-body">
                <!-- Left Column: Requirements -->
                <div class="requirements-section">
                    <h4>Benötigte Materialien</h4>
                    <div class="requirements-list">
                        ${recipe.requires.map(req => createRequirementHTML(req)).join('')}
                    </div>
                </div>

                <!-- Right Column: Reward -->
                <div class="reward-section">
                    <h4>Belohnung</h4>
                    <div class="reward-info">
                        ${rewardImage}
                        <span>${rewardAmount}x ${rewardLabel}</span>
                    </div>
                </div>
            </div>

            <!-- Action Button -->
            <div class="card-footer">
                <button class="craft-button ${canCraft ? '' : 'disabled'}" 
                        onclick="${canCraft ? `openAmountModal('${key}')` : 'void(0)'}">
                    <i class="fas fa-hammer"></i>
                    <span>${canCraft ? 'Herstellen' : 'Nicht genug Materialien'}</span>
                </button>
            </div>
        </div>
    `;
    return card;
}

function createRequirementHTML(requirement) {
    const itemData = playerInventory[requirement.item] || { count: 0, label: requirement.label };
    const hasEnough = hasItemInInventory(requirement.item, requirement.amount);
    const itemImage = `<img src="nui://inventory/web/dist/assets/items/${requirement.item}.png" alt="${requirement.label}" class="item-image">`;
    
    return `
        <div class="requirement-item ${hasEnough ? 'available' : 'unavailable'}">
            ${itemImage}
            <span>${requirement.label}</span>
            <div class="requirement-amount">
                ${itemData.count}/${requirement.amount}
            </div>
        </div>
    `;
}


function canCraftRecipe(recipe) {
    return recipe.requires.every(req => hasItemInInventory(req.item, req.amount));
}

function hasItemInInventory(item, amount) {
    return (playerInventory[item]?.count || 0) >= amount;
}


function getInventoryCount(item) {
    return playerInventory[item]?.count || 0;
}

function getRecipeIcon(label) {
    const iconMap = {
        'Brot': 'fa-bread-slice',
        'Teig': 'fa-cookie-dough',
        'Mehl': 'fa-wheat',
        // Weitere Icons hier...
    };
    return iconMap[label] || 'fa-mortar-pestle';
}

function openAmountModal(recipeKey) {
    selectedRecipe = recipeKey;
    const recipe = recipes[recipeKey];
    const modal = document.getElementById('amount-modal');
    
    document.getElementById('recipe-preview').innerHTML = `
        <div style="background: #1e1e1e; border-radius: 16px; padding: 16px; margin-bottom: 20px;">
            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
                <div style="background: #2a2a2a; border-radius: 12px; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                    <i class="fas ${getRecipeIcon(recipe.label)}" style="font-size: 20px; color: #ffffff;"></i>
                </div>
                <div style="flex-grow: 1;">
                    <h3 style="margin: 0 0 4px 0; font-size: 18px; color: #ffffff;">
                        ${recipe.label}
                    </h3>
                    <div style="display: flex; gap: 12px; color: #a0a0a0; font-size: 13px;">
                        <span style="display: flex; align-items: center; gap: 4px;">
                            <i class="fas fa-tag" style="font-size: 11px;"></i>
                            ${recipe.category}
                        </span>
                        <span style="display: flex; align-items: center; gap: 4px;">
                            <i class="fas fa-clock" style="font-size: 11px;"></i>
                            ${recipe.time}s
                        </span>
                    </div>
                </div>
            </div>
            
            <div style="color: #a0a0a0; font-size: 14px; margin-bottom: 8px;">Pro Einheit:</div>
            <div style="display: flex; align-items: center; gap: 8px;">
                <img src="nui://inventory/web/dist/assets/items/${recipe.rewards[0].item}.png" 
                     alt="${recipe.rewards[0].label}" 
                     style="width: 24px; height: 24px; border-radius: 4px;">
                <span style="color: #ffffff; font-size: 14px;">
                    ${recipe.rewards[0].amount}x ${recipe.rewards[0].label}
                </span>
            </div>
        </div>
    `;

    // Styling für den Input mit - und + Buttons
    const inputContainer = document.createElement('div');
    inputContainer.style.cssText = 'display: flex; align-items: center; justify-content: center; gap: 8px; margin-bottom: 20px;';
    inputContainer.innerHTML = `
        <button onclick="decrementAmount()" style="width: 40px; height: 40px; background: #2a2a2a; border: none; border-radius: 8px; color: #ffffff; font-size: 18px; cursor: pointer;">-</button>
        <input type="number" id="amount-input" value="1" min="1" max="999" 
               style="width: 80%; background: #2a2a2a; border: none; border-radius: 8px; padding: 8px; color: #ffffff; font-size: 16px; text-align: center; outline: none;">
        <button onclick="incrementAmount()" style="width: 40px; height: 40px; background: #2a2a2a; border: none; border-radius: 8px; color: #ffffff; font-size: 18px; cursor: pointer;">+</button>
    `;
    document.getElementById('amount-input').parentElement.replaceWith(inputContainer);
    
    updateResourceCalculation();
    modal.classList.add('active');
}

function updateResourceCalculation() {
    if (!selectedRecipe) return;
    
    const amount = parseInt(document.getElementById('amount-input').value) || 0;
    const recipe = recipes[selectedRecipe];
    const calculation = document.getElementById('resource-calculation');
    
    // Gesamte Produktion
    const summarySection = `
        <div style="background: #2a2a2a; border-radius: 12px; padding: 12px; margin-bottom: 16px;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <span style="color: #a0a0a0; font-size: 14px;">Gesamte Produktion:</span>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="color: #ffffff; font-size: 14px;">
                        ${recipe.rewards[0].amount * amount}x ${recipe.rewards[0].label}
                    </span>
                </div>
            </div>
        </div>
    `;

    // Gesamtpreis
    const totalPrice = recipe.price * amount;
    const priceSection = `
        <div style="background: #2a2a2a; border-radius: 12px; padding: 12px; margin-bottom: 16px;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <i class="fas fa-coins" style="color: #ffd700; font-size: 16px;"></i>
                    <span style="color: #a0a0a0; font-size: 14px;">Gesamtpreis</span>
                </div>
                <span style="color: #ffffff; font-size: 14px;">
                    ${totalPrice > 0 ? '$' + totalPrice.toLocaleString() : 'Kostenlos'}
                </span>
            </div>
        </div>
    `;
    
    // Benötigte Materialien
    const resourcesList = recipe.requires.map(req => {
        const itemData = playerInventory[req.item] || { count: 0, label: req.label };
        const needed = req.amount * amount;
        const hasEnough = itemData.count >= needed;
        const percentage = Math.min(Math.round((itemData.count / needed) * 100), 100);
        
        return `
            <div style="background: #2a2a2a; border-radius: 12px; padding: 12px; margin-bottom: 12px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <img src="nui://inventory/web/dist/assets/items/${req.item}.png" alt="${req.label}" 
                             style="width: 24px; height: 24px; border-radius: 4px;">
                        <span style="color: #ffffff; font-size: 14px;">${req.label}</span>
                    </div>
                    <span style="color: ${hasEnough ? '#ffffff' : '#ff4444'}; font-size: 14px;">
                        ${needed} benötigt
                    </span>
                </div>
                <div style="background: #1e1e1e; border-radius: 4px; height: 4px; overflow: hidden;">
                    <div style="width: ${percentage}%; height: 100%; 
                         background: ${hasEnough ? '#4CAF50' : '#ff4444'}; 
                         transition: width 0.3s ease;"></div>
                </div>
                <div style="display: flex; justify-content: flex-end; margin-top: 6px;">
                    <span style="color: #a0a0a0; font-size: 12px;">
                        ${itemData.count} verfügbar
                    </span>
                </div>
            </div>
        `;
    }).join('');

    // Action Buttons
    const actionButtons = `
        <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 20px;">
            <button onclick="startCrafting()" 
                    style="background: #5865F2; border: none; border-radius: 8px; padding: 12px; color: #ffffff; font-size: 14px; font-weight: 500; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;">
                <i class="fas fa-hammer"></i>
                Herstellen
            </button>
            <button onclick="closeModal()" 
                    style="background: #2a2a2a; border: none; border-radius: 8px; padding: 12px; color: #a0a0a0; font-size: 14px; cursor: pointer;">
                Abbrechen
            </button>
        </div>
    `;
    
    calculation.innerHTML = `
        <div style="padding: 16px;">
            ${summarySection}
            ${priceSection}
            <div style="margin-bottom: 16px;">
                <h4 style="margin: 0 0 12px 0; color: #a0a0a0; font-size: 14px;">
                    Benötigte Materialien
                </h4>
                ${resourcesList}
            </div>
            ${actionButtons}
        </div>
    `;
}

// Hilfsfunktionen für den Input
function incrementAmount() {
    const input = document.getElementById('amount-input');
    input.value = Math.min(parseInt(input.value) + 1, 999);
    updateResourceCalculation();
}

function decrementAmount() {
    const input = document.getElementById('amount-input');
    input.value = Math.max(parseInt(input.value) - 1, 1);
    updateResourceCalculation();
}
let orderUpdateInterval;

function startOrderUpdates() {
    if (orderUpdateInterval) {
        clearInterval(orderUpdateInterval);
    }
    orderUpdateInterval = setInterval(updateAllOrders, 1000);
}

function stopOrderUpdates() {
    if (orderUpdateInterval) {
        clearInterval(orderUpdateInterval);
    }
}

function updateAllOrders() {
    const orderElements = document.querySelectorAll('.order-card');
    orderElements.forEach(orderCard => {
        const orderId = parseInt(orderCard.dataset.orderId);
        const order = activeOrders.find(o => o.id === orderId);
        
        if (!order) {
            if (orderId !== pendingOrderId) {
                orderCard.remove();
            }
            return;
        }

        const progressElement = orderCard.querySelector('.progress-fill');
        const statusElement = orderCard.querySelector('.progress-status');
        const progress = calculateProgress(order);

        // Aktualisiere nur wenn es eine Änderung gibt
        if (progressElement.style.width !== `${progress}%`) {
            progressElement.style.width = `${progress}%`;
            progressElement.classList.toggle('active', progress < 100);

            if (progress < 100) {
                const timeLeft = calculateTimeLeft(order);
                statusElement.innerHTML = `
                    <span>In Bearbeitung</span>
                    <span class="time-countdown">${timeLeft}</span>
                `;
                
                const existingButton = orderCard.querySelector('.craft-button');
                if (existingButton) {
                    existingButton.remove();
                }
            } else if (!order.pending) {
                if (!orderCard.classList.contains('completed')) {
                    orderCard.classList.add('completion-flash', 'completed');
                }
                statusElement.innerHTML = `
                    <span>Fertig zum Abholen</span>
                    <span class="time-countdown">Abgeschlossen</span>
                `;
                
                if (!orderCard.querySelector('.craft-button')) {
                    const buttonContainer = document.createElement('div');
                    buttonContainer.innerHTML = `
                        <button class="craft-button" onclick="collectOrder(${order.id})">
                            <i class="fas fa-box"></i>
                            <span>Abholen</span>
                        </button>
                    `;
                    orderCard.appendChild(buttonContainer.firstElementChild);
                }
            }
        }
    });
}

function loadActiveOrders(orders, pendingId = null) {
    activeOrders = orders;
    pendingOrderId = pendingId;
    
    const container = document.getElementById('active-orders');
    container.innerHTML = '';

    if ((!orders || orders.length === 0) && !pendingOrderId) {
        container.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-box-open"></i>
                <p>Keine aktiven Aufträge</p>
            </div>
        `;
        return;
    }

    const allOrders = [...orders];
    if (pendingOrderId && !orders.find(o => o.id === pendingOrderId)) {
        const recipe = recipes[selectedRecipe];
        const craftingTime = recipe ? recipe.time * 1000 : 30000; // Verwende die Craftingzeit aus dem Rezept oder Default
        
        allOrders.push({
            id: pendingOrderId,
            recipe_name: selectedRecipe,
            amount: parseInt(document.getElementById('amount-input')?.value || 1),
            start_time: new Date().toISOString(),
            completion_time: new Date(Date.now() + craftingTime).toISOString(),
            pending: true
        });
    }


    const sortedOrders = allOrders.sort((a, b) => 
        new Date(b.start_time) - new Date(a.start_time)
    );

    sortedOrders.forEach(order => {
        const recipe = recipes[order.recipe_name];
        if (!recipe) return;

        const progress = order.pending ? 0 : calculateProgress(order);
        const card = document.createElement('div');
        card.className = `order-card fade-in ${order.pending ? 'pending' : ''}`;
        card.dataset.orderId = order.id;
        
        // Nutze recipe.label für die Anzeige
        card.innerHTML = `
            <div class="recipe-header">
                <div class="recipe-icon">
                    <i class="fas ${getRecipeIcon(recipe.label)}"></i>
                </div>
                <div class="recipe-info">
                    <h3 class="recipe-title">${recipe.label}</h3>
                    <div class="order-details">
                        <span class="order-amount">${order.amount}x</span>
                        <span class="order-id">#${order.id}</span>
                    </div>
                </div>
            </div>

            <div class="order-progress">
                <div class="progress-status">
                    <span>${order.pending ? 'Wird gestartet...' : progress >= 100 ? 'Fertig zum Abholen' : 'In Bearbeitung'}</span>
                    <span class="time-countdown">
                        ${order.pending ? 'Einen Moment...' : progress >= 100 ? 'Abgeschlossen' : calculateTimeLeft(order)}
                    </span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill ${progress < 100 ? 'active' : ''}" 
                         style="width: ${progress}%"></div>
                </div>
            </div>

            ${progress >= 100 && !order.pending ? `
                <button class="craft-button" onclick="collectOrder(${order.id})">
                    <i class="fas fa-box"></i>
                    <span>Abholen</span>
                </button>
            ` : ''}
        `;

        container.appendChild(card);
    });

    startOrderUpdates();
}

function calculateProgress(order) {
    const now = new Date().getTime();
    const start = new Date(order.start_time).getTime();
    const end = new Date(order.completion_time).getTime();
    
    // Wenn der Auftrag pending ist, zeige 0% an
    if (order.pending) {
        return 0;
    }
    
    // Berechne den Fortschritt
    const elapsedTime = now - start;
    const totalTime = end - start;
    const progress = (elapsedTime / totalTime) * 100;
    
    // Runde auf 2 Dezimalstellen für smoothere Animation
    return Math.min(Math.max(Math.round(progress * 100) / 100, 0), 100);
}

function calculateTimeLeft(order) {
    const now = new Date().getTime();
    const end = new Date(order.completion_time).getTime();
    const timeLeft = end - now;

    if (timeLeft <= 0) return '';

    const seconds = Math.floor(timeLeft / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);

    if (hours > 0) {
        return `${hours}h ${minutes % 60}m übrig`;
    } else if (minutes > 0) {
        return `${minutes}m ${seconds % 60}s übrig`;
    } else {
        return `${seconds}s übrig`;
    }
}

function startCrafting() {
    const amount = parseInt(document.getElementById('amount-input').value);
    if (amount > 0 && selectedRecipe) {
        fetch(`https://${GetParentResourceName()}/startCrafting`, {
            method: 'POST',
            body: JSON.stringify({
                recipe: selectedRecipe,
                amount: amount
            })
        });
        
        closeModal();
    }
}

function collectOrder(orderId) {
    fetch(`https://${GetParentResourceName()}/collectOrder`, {
            method: 'POST',
            body: JSON.stringify({
                orderId: orderId
            })
        });
}

function closeModal() {
    document.getElementById('amount-modal').classList.remove('active');
    selectedRecipe = null;
}

function closeUI() {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST'
    });
}

window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.type) {
        case 'showUI':
            document.querySelector('.container').style.display = 'block';
            playerInventory = data.inventory || {};
            recipes = data.recipes;
            currentLocation = data.location;
            document.getElementById('location-title').textContent = data.location.label;
            updateRecipeDisplay();
            updateInventoryList();
            break;
            
        case 'hideUI':
            document.querySelector('.container').style.display = 'none';
            stopOrderUpdates();
            break;
            
        case 'updateOrders':
            loadActiveOrders(data.orders, data.pendingOrderId);
            break;
            
        case 'updateInventory':
            playerInventory = data.inventory;
            updateRecipeDisplay();
            updateInventoryList();
            break;
            
        case 'removePendingOrder':
            pendingOrderId = null;
            loadActiveOrders(activeOrders);
            break;
    }
});

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        if (document.getElementById('amount-modal').classList.contains('active')) {
            closeModal();
        } else {
            closeUI();
        }
    }
});

document.querySelector('.container').style.display = 'none';