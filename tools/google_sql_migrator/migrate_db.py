from pprint import pprint

from data import Data
from googleapiclient import discovery, errors
from local_db import LocalDb
from oauth2client.client import GoogleCredentials


class Migrate(Data):
    def __init__(self):
        credentials = GoogleCredentials.get_application_default()
        self.service = discovery.build("sqladmin", "v1beta4", credentials=credentials)
        print(
            f"project: {self.project}, instance: {self.instance}, bucket: {self.bucket}, databases: {self.databases}"
        )

    def get_body(self, action, db) -> dict:
        instances_export_request_body = {
            f"{action}Context": {
                "fileType": "SQL",
                "uri": f"{self.bucket}/exported-{db}-{self.instance}",
                "databases" if action == "export" else "database": db,
            }
        }
        return instances_export_request_body

    def __export__(self, database):
        request = self.service.instances().export(
            project=self.project,
            instance=self.instance,
            body=self.get_body(action="export", db=database),
        )
        response = request.execute()
        pprint(response)
        return response

    def __import__(self, database):
        if self.im_instance == "localhost":
            LocalDb(database=database)
        else:
            request = self.service.instances().import_(
                project=self.im_project,
                instance=self.im_instance,
                body=self.get_body(action="import", db=database),
            )
            response = request.execute()
            pprint(response)
            return response

    def main(self):
        while self.databases:
            for database in self.databases:
                try:
                    if self.__export__(database=database):
                        self.databases.remove(database)
                        self.__import__(
                            database=database
                        ) if self.im_instance else print(
                            "\nOnly did backup, --im_sql wasn't used"
                        )
                        print(f"databases left to migrate: {self.databases}")
                except errors.HttpError as er:
                    if er.status_code == 409:
                        continue
                    else:
                        print(er)
                        break


if __name__ == "__main__":
    Migrate().main()
