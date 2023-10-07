const { DataBaseNoSQL } = require("../resources/data-base.resource");
const { marshall } = require("@aws-sdk/util-dynamodb");

class PersonService {
    constructor() {
        this.dataBaseNoSQL = new DataBaseNoSQL();
    }

    async create(body) {
        if (!body || !body.id || !body.name || !body.lastName || !body.email) {
            return {
                statusCode: 400,
                body: "Campos requeridos faltantes en la solicitud."
            };
        }

        const { id, name, lastName, email } = body;

        const item = marshall({
            id,
            name,
            lastName,
            email,
        });

        await this.dataBaseNoSQL.create(process.env.PERSON_TABLE, item);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Registro creado exitosamente." })
        };
    }
}

exports.PersonService = PersonService;
