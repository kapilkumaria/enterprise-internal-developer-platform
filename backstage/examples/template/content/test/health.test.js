const test = require('node:test');
const assert = require('node:assert/strict');

test('service configuration is valid', () => {
  const serviceName = '${{ values.name }}';

  assert.ok(serviceName);
  assert.match(serviceName, /^[a-z0-9]+(?:-[a-z0-9]+)*$/);
});
