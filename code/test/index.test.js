const { handler } = require('../src/index');

describe('Unit test. Handler function', () => {
    test('Unit test. index', async () => {
        const result = await handler();
        expect(result).toEqual({
            statusCode: 200,
            body: 'Hola mundo'
        })
    })
})