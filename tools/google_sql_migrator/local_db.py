import os
import subprocess

import psycopg2
from data import Data
from google.cloud import storage
from psycopg2 import Error


class LocalDb(Data):
    def __init__(self, database):
        """import to local postgres instance"""

        # connect to gcs bucket
        storage_client = storage.Client()

        _B = self.split_gs_path(self.bucket)
        self.gs_client = storage_client.bucket(_B)
        self._uri = f"exported-{database}-{self.instance}"
        self.local_uri = f"./{self._uri}"
        self.database: str = database

        self.main()

    def split_gs_path(self, gs_path):
        path_parts = gs_path.replace("gs://", "").split("/")
        bucket = path_parts.pop(0)
        return bucket

    def db_conn(self, db):
        return psycopg2.connect(
            user="postgres",
            password="password",
            host="localhost",
            port="5432",
            database=db,
        )

    def __setup__(self):
        try:
            connection = self.db_conn("postgres")
            connection.autocommit = True
            cursor = connection.cursor()
            cursor.execute(f"""DROP DATABASE IF EXISTS {self.database};""")
            cursor.execute(f"""CREATE DATABASE {self.database};""")
            print("Set up postgres successfully")
        except (Exception, Error) as error:
            print("Error while connecting to PostgreSQL", error)
        finally:
            if connection:
                cursor.close()
                connection.close()
                print("PostgreSQL connection is closed")

    def __download__(self):
        print(
            "Downloading storage object {} from bucket {} to local file {}.".format(
                self._uri, self.bucket, self.local_uri
            )
        )
        blob = self.gs_client.blob(f"python/{self._uri}")
        blob.download_to_filename(self.local_uri)
        print("Downloaded successfully")

    def __import__(self):
        print(f"importing database {self.database} to localhost")
        _ = subprocess.run(
            [f"psql {self.database} < {os.path.dirname(__file__)}/{self._uri}"],
            capture_output=True,
            check=True,
            shell=True,
        )
        print(f"imported successfully")

    def main(self):
        self.__setup__()
        self.__download__()
        self.__import__()
