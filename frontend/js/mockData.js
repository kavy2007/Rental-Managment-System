// Mock Data for RentFlow

const MOCK_PRODUCTS = [
    // --- ELECTRONICS ---
    {
        id: 'p1',
        name: 'Pro DSLR Camera Kit',
        brand: 'Canon',
        category: 'Electronics',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTO2z7MN5lI82rMJ2NPhdvFW9twNgKZuXyE6q6_JGmUwA&s=10',
        pricePerHour: 100,
        pricePerDay: 1000,
        pricePerWeek: 2500,
        securityDeposit: 1500,
        status: 'Available',
        variants: ['Black'],
        stock: 5,
        rating: 4.8,
        description: 'Professional DSLR camera with 24-70mm f/2.8 lens included.'
    },
    {
        id: 'p2',
        name: '4K Drone with Gimbal',
        brand: 'DJI',
        category: 'Electronics',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdHV26RrJm0Bf256-GZDQp07SgUDZXlfaO5WFfjmNUTQ&s=10',
        pricePerHour: 300,
        pricePerDay: 2500,
        pricePerWeek: 12000,
        securityDeposit: 5000,
        status: 'Available',
        variants: ['White', 'Dark Gray'],
        stock: 2,
        rating: 4.9,
        description: 'Professional 4K drone with 3-axis gimbal and 45min flight time.'
    },
    {
        id: 'p3',
        name: 'Gaming Laptop',
        brand: 'Razer',
        category: 'Electronics',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeI9UNmsfKuql4WpxYPg2ZDNhvJ83Tuq2Smn-xk64nVQ&s=10',
        pricePerHour: 150,
        pricePerDay: 1500,
        pricePerWeek: 7000,
        securityDeposit: 3000,
        status: 'Available',
        variants: ['Black'],
        stock: 3,
        rating: 4.7,
        description: 'High-performance gaming laptop with RTX 4080.'
    },

    // --- TOOLS ---
    {
        id: 'p4',
        name: 'Heavy Duty Power Drill',
        brand: 'DeWalt',
        category: 'Tools',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdUbMTX1RY9L_YF4_IrvS2VxXopNfQIosyS_4kx8HBeA&s=10',
        pricePerHour: 50,
        pricePerDay: 200,
        pricePerWeek: 8000,
        securityDeposit: 500,
        status: 'Available',
        variants: ['Yellow', 'Black/Silver'],
        stock: 12,
        rating: 4.5,
        description: '20V Max cordless drill/driver kit with 2 batteries.'
    },
    {
        id: 'p5',
        name: 'Portable Generator 5000W',
        brand: 'Honda',
        category: 'Tools',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjz2imSSoKMicKzdXKf3S1YOn5L5XkNo9SBOq99lwGkg&s=10',
        pricePerHour: 100,
        pricePerDay: 800,
        pricePerWeek: 4500,
        securityDeposit: 2000,
        status: 'Available',
        variants: ['Red/Black'],
        stock: 4,
        rating: 4.6,
        description: 'Super quiet portable inverter generator.'
    },
    {
        id: 'p6',
        name: 'Circular Saw',
        brand: 'Makita',
        category: 'Tools',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNmrREsyD6bquJU0NJEKa6x-npnozGzYv_gKAYUcjL3Q&s=10',
        pricePerHour: 40,
        pricePerDay: 250,
        pricePerWeek: 1000,
        securityDeposit: 600,
        status: 'Available',
        variants: ['Teal'],
        stock: 7,
        rating: 4.8,
        description: '7-1/4 Inch Circular Saw with powerful 15 AMP motor.'
    },

    // --- EVENTS ---
    {
        id: 'p7',
        name: 'Party Tent 20x20',
        brand: 'EventPro',
        category: 'Events',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2I7DqKEY1IbbnyKLZVJ9RLPYTtmXTS6vCGhXEwCCNiA&s=10',
        pricePerHour: 500,
        pricePerDay: 1500,
        pricePerWeek: 5000,
        securityDeposit: 2000,
        status: 'Booked',
        variants: ['White', 'Clear Top', 'Blue/White Striped'],
        stock: 0,
        rating: 4.9,
        description: 'Heavy duty commercial event tent, perfect for outdoor parties.'
    },
    {
        id: 'p8',
        name: 'DJ Controller Deck',
        brand: 'Pioneer',
        category: 'Events',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQz7AbR0ZL3QQxaC3clQAcAQyS0G-kkZz3gFrdnrhJhBA&s=10',
        pricePerHour: 150,
        pricePerDay: 1200,
        pricePerWeek: 5000,
        securityDeposit: 3000,
        status: 'Available',
        variants: ['Black', 'Limited Edition Gold'],
        stock: 2,
        rating: 4.8,
        description: 'Professional 4-channel DJ controller with performance pads.'
    },
    {
        id: 'p9',
        name: 'PA Sound System',
        brand: 'Yamaha',
        category: 'Events',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJt524oqSYGqWjlXW5vJz0vPOxjJsdu5sY1405jd9PBA&s=10',
        pricePerHour: 200,
        pricePerDay: 1800,
        pricePerWeek: 6000,
        securityDeposit: 4000,
        status: 'Available',
        variants: ['Black'],
        stock: 3,
        rating: 4.9,
        description: 'Complete PA system with 2 speakers, mixer, and cables.'
    },

    // --- SPORTS ---
    {
        id: 'p10',
        name: 'Electric Mountain Bike',
        brand: 'Trek',
        category: 'Sports',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQByzzv6kwbQ17lUOTVDJ9FYFxjHewP2voF_FekLJkq4g&s=10',
        pricePerHour: 200,
        pricePerDay: 3000,
        pricePerWeek: 20000,
        securityDeposit: 2500,
        status: 'Available',
        variants: ['Matte Black', 'Red', 'Neon Green'],
        stock: 3,
        rating: 4.7,
        description: 'Full suspension e-bike for mountain trails.'
    },
    {
        id: 'p11',
        name: 'Stand Up Paddle Board',
        brand: 'AquaMarina',
        category: 'Sports',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIzqZMqKP0m_dasV-182T6rtdnRnbUN-nH5Ss0qpv1mA&s=10',
        pricePerHour: 50,
        pricePerDay: 400,
        pricePerWeek: 1500,
        securityDeposit: 1000,
        status: 'Available',
        variants: ['Blue/White', 'Orange/Black', 'Teal'],
        stock: 8,
        rating: 4.4,
        description: 'Inflatable SUP board with paddle, pump, and carry bag.'
    },
    {
        id: 'p12',
        name: 'Camping Tent (4-Person)',
        brand: 'Coleman',
        category: 'Sports',
        image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHezMlRpZaAF9auo9d0E-R6KMGr11iqyB08oyRJvM7_Q&s=10',
        pricePerHour: 0,
        pricePerDay: 300,
        pricePerWeek: 1200,
        securityDeposit: 800,
        status: 'Available',
        variants: ['Green', 'Blue'],
        stock: 5,
        rating: 4.6,
        description: 'Spacious 4-person camping tent, weather resistant.'
    }
];

const MOCK_ORDERS = [
    {
        id: 'ORD-1001',
        customer: 'John Doe',
        date: '2026-07-15',
        total: 150,
        status: 'Active', // Active, Completed, Cancelled
        items: [
            { productId: 'p1', quantity: 1, duration: '3 Days' }
        ]
    },
    {
        id: 'ORD-1002',
        customer: 'Sarah Smith',
        date: '2026-07-18',
        total: 80,
        status: 'Pending',
        items: [
            { productId: 'p2', quantity: 1, duration: '1 Week' }
        ]
    }
];

const MOCK_KPIS = {
    activeRentals: 42,
    dueToday: 8,
    upcomingPickups: 12,
    upcomingReturns: 5,
    overdue: 3,
    revenue: '₹14,500',
    depositsHeld: '₹4,200',
    lateFees: '₹350'
};

// Make data available globally
window.RentFlowData = {
    products: MOCK_PRODUCTS,
    orders: MOCK_ORDERS,
    kpis: MOCK_KPIS
};
