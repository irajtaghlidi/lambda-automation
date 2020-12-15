import json
import os
import urllib.request
import boto3

url = "https://blockchain.info/blocks/?format=json"


# Create an SNS client
sns = boto3.client('sns')


def handler(event, context):
    # Entery point of function
    blocks = fetch_blocks()

    process_blocks(blocks)



def fetch_blocks():
    # Fetch Blockchain blocks from API
    try:
        response = urllib.request.urlopen(url, timeout=60)
        blocks = json.load(response)
    except urllib.request.URLError as err:
        raise SystemExit(err)
    else:
        return blocks['blocks']
    


def process_blocks(blocks):
    # Process each block information
    for block in blocks:
        height = block['height']
        hash = block['hash']
        time = block['time']

        publish_sns(height, hash, time)



def publish_sns(height, hash, time):
    # Publish block information to the specified SNS topic
    message = f'Mined Block with Height: {height}, Hash: {hash}, At: {time}'
    
    sns.publish(
        TopicArn=os.environ['sns_topic'],
        Message=message,
    )