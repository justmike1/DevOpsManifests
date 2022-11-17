# Import the Secret Manager client library.
from google.cloud import secretmanager
import os

# TODO: add manyy functions for every provider and one line all fetches
class getSecret(object):
    def __init__(self, secret_id) -> str:
        if os.getenv(secret_id):
            return os.getenv(secret_id) 
        client = secretmanager.SecretManagerServiceClient()
        name = f"projects/{os.getenv('PROJECT_ID')}/secrets/{secret_id}/versions/latest"
        response = client.access_secret_version(name=name)
        return response
