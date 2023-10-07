const { PersonService } = require("../../services/person.service")

const personService = new PersonService();

exports.getPersonList = async (event, context) => {
    return {
        statusCode: 200,
        body: 'Listar personas'
    };
}

exports.createPerson = async (event, context) => {
    const { body } = event;
    return await personService.create(JSON.parse(body));
}