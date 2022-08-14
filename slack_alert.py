import os
from dataclasses import dataclass

import requests as rq


@dataclass
class AlertData:
    """
    Fetches env variables from github actions file: build-ci.yaml
    Dataclass for variables to be kept immutable on run
    """

    author: str = os.getenv("AUTHOR")
    event: str = os.getenv("EVENT")
    namespace: str = os.getenv("NAMESPACE")
    tag: str = os.getenv("TAG")
    webhook: str = os.getenv("SLACK_WEBHOOK")

    def post_alert(self) -> str:
        developers: dict = {
            "mikejoseph": os.getenv("SLACK_M"),
        }
        headers = {
            "Content-type": "application/json",
        }
        json_data = {
            "text": f"CI Finished for {self.event}: {self.namespace}.{self.tag}, Author: <@{developers[self.author]}>",
        }
        res = rq.post(
            url=f"https://hooks.slack.com/services/{self.webhook}",
            headers=headers,
            json=json_data,
        )
        print(res.status_code)


if __name__ == "__main__":
    AlertData().post_alert()
