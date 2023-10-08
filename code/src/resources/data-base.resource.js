const { DynamoDBClient, PutItemCommand, ScanCommand } = require("@aws-sdk/client-dynamodb");

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

    async list(tableName) {
        try {
            const params = {
                TableName: tableName
            };

            const result = await this.dynamodbClient.send(new ScanCommand(params));

            return {
                error: false,
                data: result.Items
            }
        } catch (error) {
            console.log(error.message);

            return {
                error: true,
                data: error.message
            }
        }
    }
}

exports.DataBaseNoSQL = DataBaseNoSQL;