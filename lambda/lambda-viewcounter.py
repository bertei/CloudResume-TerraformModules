##ver. updates dynamodb but doesn't display view counter in html
##not working, old ver, placeholder file
import json, boto3

client = boto3.client('dynamodb')
TableName = 'PageViews'

def lambda_handler(event, context):
    
    response = client.update_item(
        TableName='PageViews',
        Key = {
            'stat': {'S': 'view-count'}
        },
        UpdateExpression = 'ADD Quantity :inc',
        ExpressionAttributeValues = {":inc" : {"N": "1"}},
        ReturnValues = 'UPDATED_NEW'
        )
        
    value = response['Attributes']['Quantity']['N']
    
    return {      
        'statusCode': 200,
        'body': value
    }