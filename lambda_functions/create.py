import boto3
import json
import uuid
from lambda_functions import decimalencoder

print('Loading function')
dynamo = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamo.Table('Tasks')


def handler(event, context):
    # print("Received event: " + json.dumps(event, indent=2))
    payload = event.copy()
    payload["id"] = str(uuid.uuid4())

    table.put_item(Item=payload)

    response = {
        "statusCode": 201,
        "body": json.dumps(payload, cls=decimalencoder.DecimalEncoder)
    }

    return response
