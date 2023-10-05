exports.getPersonList = async (event, context) => {
    return {
        statusCode: 200,
        body: 'Listar personas'
    }
}

exports.createPerson = async (event, context) => {
    return {
        statusCode: 200,
        body: 'Crear personas'
    }
}