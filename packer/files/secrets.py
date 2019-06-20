#!/usr/local/bin/python3

##
## secrets.py
## fetch server certificates from iam
## fetch encrypted s3 objects
## get secrets from secrets manager
##
import argparse
import ast
import boto3
import json

from pprint import pprint
from botocore.exceptions import ClientError

def boto_client(region_name, service_name):
    ## Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name=service_name,
        region_name=region_name
    )
    return client

def get_secret(region_name, secret_name):
  try:
      client = boto_client(region_name, 'secretsmanager')
      get_secret_value_response = client.get_secret_value(SecretId=secret_name)
      return get_secret_value_response

  except ClientError as e:
      if e.response['Error']['Code'] == 'DecryptionFailureException':
          ## Secrets Manager can't decrypt the protected secret text using the provided KMS key.
          raise e
      elif e.response['Error']['Code'] == 'InternalServiceErrorException':
          ## An error occurred on the server side.
          raise e
      elif e.response['Error']['Code'] == 'InvalidParameterException':
          ## You provided an invalid value for a parameter.
          raise e
      elif e.response['Error']['Code'] == 'InvalidRequestException':
          ## You provided a parameter value that is not valid for the current state of the resource.
          raise e
      elif e.response['Error']['Code'] == 'ResourceNotFoundException':
          ## We can't find the resource that you asked for.
          raise e
      else:
          ## Decrypts secret using the associated KMS CMK.
          ## The secret is a string or binary and one of these fields will be populated.
          if 'SecretString' in get_secret_value_response:
              secret = get_secret_value_response['SecretString']
              return secret
          else:
              decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
              return decoded_binary_secret

def get_server_cert(region_name, name):
    try:
        client = boto_client(region_name, 'iam')
        cert = client.get_server_certificate(ServerCertificateName=name)
        print(cert["ServerCertificate"]["CertificateBody"])
    except ClientError as e:
        print(e)

def get_object(region_name, bucket, key, filename):
    try:
        s3 = boto3.resource('s3')
        s3.Bucket(bucket).download_file(key, filename)
    except ClientError as e:
        if e.response['Error']['Code'] == 'AccessDenied':
            print(e)

def main():
    parser = argparse.ArgumentParser(description="Retrieve SSL Certificates")
    parser.add_argument("-b", "--bucket", required=True, help="name of encrypted s3 bucket")
    parser.add_argument("-k", "--key", help="s3 bucket key")
    parser.add_argument("-f", "--filename", help="output filename")
    parser.add_argument("-r", "--region-name", help="region name")
    args = parser.parse_args()

    if args.name:
        region_name='us-west-1'
        bucket='secure.gturn.xyz'
        key='mail.bitpusher.org.key'
        filename='/tmp/mail.key'
        response = get_object(region_name, bucket, key, filename)
        pprint(response)

#        response=get_server_cert(region_name, args.name)
#        print(response)
#        print(f'the name is {args.name}')
#
#        response=get_server_key(region_name, "mail_bitpusher_org_key")
#        secret=(json.loads(response['SecretString']))
#        print(secret)

main()

