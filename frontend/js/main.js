// Main JavaScript Utilities for RentFlow

// 1. Auth State Management
function checkAuth() {
    const user = JSON.parse(localStorage.getItem('user'));
    // If not on a login page and not authenticated, could redirect, but for this mock we just update UI
    if (user) {
        // Update user profile display in navbar if it exists
        const userNameDisplays = document.querySelectorAll('.user-name-display');
        userNameDisplays.forEach(el => el.textContent = user.name);
    }
}

function logout() {
    localStorage.removeItem('user');
    window.location.href = window.location.pathname.includes('/pages/') 
        ? '../../index.html' 
        : './index.html';
}

// 2. Cart Management
function getCart() {
    return JSON.parse(localStorage.getItem('rentflow_cart')) || [];
}

function saveCart(cart) {
    localStorage.setItem('rentflow_cart', JSON.stringify(cart));
    updateCartBadge();
}

function addToCart(product, quantity, duration) {
    const cart = getCart();
    // Check if item exists
    const existing = cart.find(item => item.id === product.id && item.duration === duration);
    if (existing) {
        existing.quantity += quantity;
    } else {
        cart.push({ ...product, quantity, duration });
    }
    saveCart(cart);
    showToast(`Added ${product.name} to cart`);
}

function updateCartBadge() {
    const cart = getCart();
    const count = cart.reduce((sum, item) => sum + item.quantity, 0);
    const badges = document.querySelectorAll('.cart-badge');
    badges.forEach(badge => {
        badge.textContent = count;
        badge.style.display = count > 0 ? 'inline-flex' : 'none';
    });
}

// 3. UI Utilities
function showToast(message, type = 'success') {
    // Create toast container if it doesn't exist
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.style.cssText = 'position: fixed; bottom: 20px; right: 20px; z-index: 9999; display: flex; flex-direction: column; gap: 10px;';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    // Inline styling for the toast based on white/orange theme
    const bgColor = type === 'success' ? 'var(--status-green)' : 'var(--primary)';
    toast.style.cssText = `
        background-color: #333;
        color: white;
        padding: 12px 24px;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        display: flex;
        align-items: center;
        gap: 8px;
        opacity: 0;
        transform: translateY(20px);
        transition: all 0.3s ease;
        border-left: 4px solid ${bgColor};
    `;

    toast.innerHTML = `
        <i class="fa-solid ${type === 'success' ? 'fa-check-circle' : 'fa-info-circle'}" style="color: ${bgColor}"></i>
        <span>${message}</span>
    `;

    container.appendChild(toast);

    // Animate in
    setTimeout(() => {
        toast.style.opacity = '1';
        toast.style.transform = 'translateY(0)';
    }, 10);

    // Remove after 3 seconds
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(20px)';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    checkAuth();
    updateCartBadge();
});
