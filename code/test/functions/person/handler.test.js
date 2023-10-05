const { getPersonList, createPerson } = require('../../../src/functions/person/handler');

describe('Unit test. Handler function', () => {
    test('Unit test. index', async () => {
        const result = await getPersonList();
        expect(result).toEqual({
            statusCode: 200,
            body: 'Listar personas'
        })
    })

    test('Unit test. index', async () => {
        const result = await createPerson();
        expect(result).toEqual({
            statusCode: 200,
            body: 'Crear personas'
        })
    })
})