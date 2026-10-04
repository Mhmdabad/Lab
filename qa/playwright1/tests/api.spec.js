import { test, expect } from '@playwright/test';

test('API example', async ({ request }) => {

  // GET request + query params + headers
  const getResponse = await request.get('/api/users', {
    params: {
      page: 1,
      limit: 10
    },
    headers: {
      Authorization: `Bearer ${process.env.TOKEN}`
    }
  });

  expect(getResponse.status()).toBe(200);      // exact status code
  expect(getResponse.ok()).toBeTruthy();       // any successful 2xx

  const users = await getResponse.json();      // parse JSON response

  expect(users.users.length).toBeGreaterThan(0);


  // POST request + request body
  const createResponse = await request.post('/api/users', {
    data: {
      name: 'Mohammed',
      email: 'test@example.com'
    }
  });

  expect(createResponse.status()).toBe(201);

  const createdUser = await createResponse.json();

  expect(createdUser.name).toBe('Mohammed');

  const userId = createdUser.id;


  // PATCH request - update part of resource
  const updateResponse = await request.patch(`/api/users/${userId}`, {
    data: {
      email: 'new@example.com'
    }
  });

  expect(updateResponse.status()).toBe(200);

  const updatedUser = await updateResponse.json();

  expect(updatedUser.email).toBe('new@example.com');


  // DELETE request
  const deleteResponse = await request.delete(`/api/users/${userId}`);

  expect(deleteResponse.ok()).toBeTruthy();
});