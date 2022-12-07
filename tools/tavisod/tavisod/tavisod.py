from google.cloud import secretmanager
from google_crc32c import Checksum
from dataclasses import dataclass
import os

@dataclass(init=True, frozen=True)
class gSM(object):
    # Create the Secret Manager client.
    client = secretmanager.SecretManagerServiceClient()
    project_id: str = os.getenv('PROJECT_ID')
    check_env: bool = False
    version: str = "latest"

    @staticmethod
    def verifyData(response):
        # Verify payload checksum.
        crc32c = Checksum()
        crc32c.update(response.payload.data)
        if response.payload.data_crc32c != int(crc32c.hexdigest(), 16):
            print("Data corruption detected.")
    
    @staticmethod
    def parseData(response):
        payload = response.payload.data.decode("UTF-8")
        return payload

    def get(self, secret_id: str) -> str:
        if self.check_env and os.getenv(secret_id):
            return os.getenv(secret_id)
        # Build the resource name of the secret version.
        name: str = f"projects/{self.project_id}/secrets/{secret_id}/versions/{self.version}"
        # Access the secret version.
        response = self.client.access_secret_version(name=name)
        # Verify Checksum
        self.verifyData(response)
        # return parsed response
        return self.parseData(response)
