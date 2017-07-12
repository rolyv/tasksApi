
import boto3
import json
import uuid

print('Loading function')
dynamo = boto3.resource('dynamodb')
table = dynamo.Table('Tasks')

def respond(err, res=None):
    return {
        'statusCode': '400' if err else '200',
        'body': err.message if err else json.dumps(res),
        'headers': {
            'Content-Type': 'application/json',
        },
    }

def handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))
    payload = json.loads(event["body"])
    payload["id"] = str(uuid.uuid4())

    response = table.put_item(Item=payload)

    return respond(None, payload)
