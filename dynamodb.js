const { DynamoDBClient, PutItemCommand, GetItemCommand } = require('@aws-sdk/client-dynamodb');
const { marshall, unmarshall } = require('@aws-sdk/util-dynamodb');

const region = process.env.DEMO_DYNAMO_DB_REGION;
const tableName = process.env.DEMO_DYNAMO_DB_TABLE_NAME;
const client = new DynamoDBClient({ region });

const saveItem = async (data) => {
    const ttl = Math.floor(Date.now() / 1000) + (5 * 60);
    const item = marshall({ ...data, pk: data.city, ttl: Math.floor(ttl)});
    const params = {
        TableName: tableName,
        Item: item
    };
    const command = new PutItemCommand(params);
    return client.send(command);
};

const fetchItem = async (city) => {
    const params = {
        TableName: tableName,
        Key: {
            pk: { S: city }
        }
    };
    const command = new GetItemCommand(params);
    const result = await client.send(command);
    return unmarshall(result.Item);
};

module.exports = { saveItem, fetchItem };
