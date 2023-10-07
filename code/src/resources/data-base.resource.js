const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

class DataBaseNoSQL {
    constructor() {
        this.dynamodbClient = new DynamoDBClient({ region: "us-east-1" })
    }

    async create(tableName, item) {
        try {
            const params = {
                TableName: tableName,
                Item: item,
            };


            await this.dynamodbClient.send(new PutItemCommand(params));
        } catch (error) {
            console.log(error.message);
        }
    }
}

exports.DataBaseNoSQL = DataBaseNoSQL;