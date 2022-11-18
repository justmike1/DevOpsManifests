# Import the Secret Manager client library.
from google.cloud import secretmanager
from google_crc32c import Checksum
from dataclasses import dataclass
import os

@dataclass(init=True, frozen=True)
class getSecret(object):
    # Create the Secret Manager client.
    client = secretmanager.SecretManagerServiceClient()

    def fromGsm(self, secret_id) -> str:
        if os.getenv(secret_id):
            return os.getenv(secret_id)
        # Build the resource name of the secret version.
        name: str = f"projects/{os.getenv('PROJECT_ID')}/secrets/{secret_id}/versions/latest"
        # Access the secret version.
        response = self.client.access_secret_version(name=name)
        # Verify Checksum
        self.verifyData(response)
        # return response
        self.parseRes(response)

    def verifyData(self, response):
        # Verify payload checksum.
        crc32c = Checksum()
        crc32c.update(response.payload.data)
        if response.payload.data_crc32c != int(crc32c.hexdigest(), 16):
            print("Data corruption detected.")
    
    def parseRes(self, response) -> str:
        payload = response.payload.data.decode("UTF-8")
        return payload
