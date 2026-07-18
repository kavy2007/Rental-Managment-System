// API functions for RentX (Replaces mockData.js)

window.RentXAPI = {
    // Products
    getProducts: async () => {
        return await apiFetch('/products/');
    },
    
    getProduct: async (id) => {
        return await apiFetch(`/products/${id}`);
    },

    deleteProduct: async (id) => {
        return await apiFetch(`/products/${id}`, {
            method: 'DELETE'
        });
    },

    updateProduct: async (id, data) => {
        return await apiFetch(`/products/${id}`, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    },
    
    // Orders
    getOrders: async () => {
        return await apiFetch('/orders/');
    },
    
    getOrder: async (id) => {
        return await apiFetch(`/orders/${id}`);
    },
    
    createOrder: async (orderData) => {
        return await apiFetch('/orders/', {
            method: 'POST',
            body: JSON.stringify(orderData)
        });
    },
    
    // Dashboard KPIs
    getKPIs: async () => {
        return await apiFetch('/dashboard/kpis');
    },

    // Payments
    createPaymentOrder: async (amount) => {
        return await apiFetch('/payments/create-order', {
            method: 'POST',
            body: JSON.stringify({ amount })
        });
    },

    verifyPayment: async (paymentData) => {
        return await apiFetch('/payments/verify', {
            method: 'POST',
            body: JSON.stringify(paymentData)
        });
    },

    // Auth
    login: async (email, password) => {
        return await apiFetch('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ email, password })
        });
    },

    register: async (email, password, name) => {
        return await apiFetch('/auth/register', {
            method: 'POST',
            body: JSON.stringify({ email, password, name })
        });
    },

    // Auth & Profile
    updateProfile: async (data) => {
        return await apiFetch('/auth/profile', {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    }
};
