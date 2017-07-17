
import boto3
import json
from lambda_functions import decimalencoder

print('Loading function')
dynamo = boto3.resource('dynamodb')

def handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))
    table = dynamo.Table("Tasks")

    # fetch all tasks from db
    result = table.scan()

    # create a response
    response = {
        "statusCode" : 200,
        "body": json.dumps(results["Items"], cls=decimalencoder.DecimalEncoder)
    }

    return response
