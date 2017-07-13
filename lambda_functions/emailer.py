import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
import decimal

dynamo = boto3.resource('dynamodb')
ses = boto3.client('ses', region_name='us-east-1')

table = dynamo.Table('Tasks')

class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

def handler(event, context):
    '''
    TODO: group task items by 'user' to consolidate into single email
    TODO: format message body
    '''
    items = table.scan(
        FilterExpression = Attr('completed').not_exists()
    )['Items']

    print(len(items))

    # only send one email right now
    for i in items[0:1]:
        #print(i)
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
                        'Data': json.dumps(i, indent=4, cls=DecimalEncoder)
                    }
                }
            }
        )

        print(response)
