const { PersonService } = require("../../services/person.service")

const personService = new PersonService();

exports.getPersonList = async (event, context) => {
    return await personService.list();
}

exports.createPerson = async (event, context) => {
    const { body } = event;
    return await personService.create(JSON.parse(body));
}