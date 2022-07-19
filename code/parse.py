from string import digits
import boto3

def lambda_handler(event, context):
    s3 = boto3.resource('s3')
    obj = s3.Object('nice-devops-interview-rotem', 'parse_me.txt')
    data = obj.get()['Body'].read()

    data_decoded = data.decode("utf-8").strip()

    space_zeros =  data_decoded.replace("00", " ")
    remove_digits = str.maketrans('', '', digits)

    result = space_zeros.translate(remove_digits)

    print (result)