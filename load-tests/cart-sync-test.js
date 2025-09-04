import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 10 }, // Ramp up to 10 users
    { duration: '1m', target: 50 },  // Ramp up to 50 users
    { duration: '2m', target: 100 }, // Ramp up to 100 users
    { duration: '3m', target: 100 }, // Stay at 100 users
    { duration: '1m', target: 0 },   // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'], // 95% of requests must complete below 200ms
    http_req_failed: ['rate<0.1'],    // Error rate must be below 10%
    errors: ['rate<0.05'],            // Custom error rate must be below 5%
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
const GRAPHQL_ENDPOINT = `${BASE_URL}/graphql`;

// Test data
const products = [
  '1', '2', '3', '4', '5', '6', '7', '8'
];

const cartIds = [];

export function setup() {
  // Create test carts for each virtual user
  const numCarts = 100;
  for (let i = 0; i < numCarts; i++) {
    cartIds.push(`test-cart-${i}-${Date.now()}`);
  }
  return { cartIds };
}

export default function(data) {
  const cartId = data.cartIds[Math.floor(Math.random() * data.cartIds.length)];
  const productId = products[Math.floor(Math.random() * products.length)];
  const quantity = Math.floor(Math.random() * 5) + 1;
  const clientMutationId = `${Date.now()}-${Math.random()}`;

  // Test 1: Add item to cart
  const addItemMutation = {
    query: `
      mutation AddItem($cartId: ID!, $productId: ID!, $quantity: Int!, $clientMutationId: String) {
        addItem(input: {
          cartId: $cartId
          productId: $productId
          quantity: $quantity
          clientMutationId: $clientMutationId
        }) {
          cart {
            id
            totalItems
            subtotalCents
            updatedAt
          }
          errors
        }
      }
    `,
    variables: {
      cartId,
      productId,
      quantity,
      clientMutationId,
    },
  };

  const addResponse = http.post(GRAPHQL_ENDPOINT, JSON.stringify(addItemMutation), {
    headers: {
      'Content-Type': 'application/json',
    },
  });

  const addSuccess = check(addResponse, {
    'add item status is 200': (r) => r.status === 200,
    'add item response time < 100ms': (r) => r.timings.duration < 100,
    'add item has no errors': (r) => {
      const body = JSON.parse(r.body);
      return !body.errors && (!body.data?.addItem?.errors || body.data.addItem.errors.length === 0);
    },
  });

  errorRate.add(!addSuccess);

  sleep(0.1); // 100ms between requests

  // Test 2: Get current cart
  const getCartQuery = {
    query: `
      query GetCurrentCart($cartId: ID!) {
        cartQueries {
          currentCart(cartId: $cartId) {
            id
            totalItems
            subtotalCents
            updatedAt
            items {
              id
              product { id title priceCents }
              quantity
              unitPriceCents
              totalPriceCents
            }
          }
        }
      }
    `,
    variables: { cartId },
  };

  const getResponse = http.post(GRAPHQL_ENDPOINT, JSON.stringify(getCartQuery), {
    headers: {
      'Content-Type': 'application/json',
    },
  });

  const getSuccess = check(getResponse, {
    'get cart status is 200': (r) => r.status === 200,
    'get cart response time < 50ms': (r) => r.timings.duration < 50,
    'get cart has data': (r) => {
      const body = JSON.parse(r.body);
      return body.data?.cartQueries?.currentCart;
    },
  });

  errorRate.add(!getSuccess);

  sleep(0.05); // 50ms between requests

  // Test 3: Get products (less frequent)
  if (Math.random() < 0.3) { // 30% chance
    const getProductsQuery = {
      query: `
        query GetProducts($active: Boolean) {
          cartQueries {
            products(active: $active) {
              id
              title
              priceCents
              stockQuantity
              inStock
            }
          }
        }
      `,
      variables: { active: true },
    };

    const productsResponse = http.post(GRAPHQL_ENDPOINT, JSON.stringify(getProductsQuery), {
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const productsSuccess = check(productsResponse, {
      'get products status is 200': (r) => r.status === 200,
      'get products response time < 100ms': (r) => r.timings.duration < 100,
      'get products has data': (r) => {
        const body = JSON.parse(r.body);
        return body.data?.cartQueries?.products?.length > 0;
      },
    });

    errorRate.add(!productsSuccess);
  }

  sleep(0.2); // 200ms between test cycles
}

export function teardown(data) {
  console.log('Load test completed');
  console.log(`Tested with ${data.cartIds.length} unique carts`);
}
