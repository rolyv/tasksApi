import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
from lambda_functions import decimalencoder

dynamo = boto3.resource('dynamodb')
ses = boto3.client('ses', region_name='us-east-1')

table = dynamo.Table('Tasks')

def handler(event, context):
    # TODO: find different way to scan so that I can group
    # by user
    items = table.scan(
        FilterExpression = Attr('completed').not_exists()
    )['Items']

    # print(len(items))

    # only send one email right now
    for i in items[0:1]:
        response = ses.send_email(
            # TODO: move FROM email to environment variable
            Source = "rolyv19+ses@gmail.com",
            Destination = {
                'ToAddresses': [
                    i['user']
                ],
            },
            Message = {
                'Subject': {
                    'Data': "Slacker! Look at all the shtuff you have to do"
                },
                'Body' : {
                    'Text': {
                        'Data': json.dumps(i, indent=4, cls=decimalencoder.DecimalEncoder)
                    }
                }
            }
        )

        # print(response)
