from google.cloud import secretmanager
from dataclasses import dataclass
import os

@dataclass(init=True, frozen=True)
class getSecret(object):
    # Create the Secret Manager client.
    client = secretmanager.SecretManagerServiceClient()

    def fromGsm(self, secret_id) -> str:
        if os.getenv(secret_id):
            return os.getenv(secret_id)
        name: str = f"projects/{os.getenv('PROJECT_ID')}/secrets/{secret_id}/versions/latest"
        # Access the secret version.
        response = self.client.access_secret_version(name=name)
        return response
