import os
import json
from dataclasses import dataclass

import requests as rq


@dataclass
class AlertData:
    """
    Fetches env variables from github actions file
    Dataclass for variables to be kept immutable on run
    """

    author: str = os.getenv("AUTHOR")
    event: str = os.getenv("EVENT")
    image: str = os.getenv("IMAGE")
    tag: str = os.getenv("TAG")
    webhook: str = os.getenv("SLACK_WEBHOOK")
    developers: str = os.getenv("DEVELOPERS")

    def post_alert(self) -> str:
        # should be like {"mikejoseph-ah": "U021H4WSYTZ"} in DEVELOPERS secret
        parsed_devs: dict = {dev:id for dev,id in dict(json.loads(self.developers)).items()}
        headers = {
            "Content-type": "application/json",
        }
        json_data = {
            "text": f"Build & Push finished successfully for {self.image}:{self.tag}, Event: {self.event}, Author: <@{parsed_devs[self.author]}>",
        }
        res = rq.post(
            url=f"https://hooks.slack.com/services/{self.webhook}",
            headers=headers,
            json=json_data,
        )
        print(json_data)
        print(res, res.status_code)


if __name__ == "__main__":
    AlertData().post_alert()
