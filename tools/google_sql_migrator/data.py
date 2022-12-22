import argparse
from dataclasses import dataclass


@dataclass(init=True)
class Data:
    parser = argparse.ArgumentParser(description="Process export data.")

    # export data
    parser.add_argument("--ex_project", type=str, help="which project to check on?")
    parser.add_argument(
        "--bucket",
        type=str,
        help="which gcs bucket save this export?",
        default="gs://import_export_db/python",
    )
    parser.add_argument(
        "--ex_databases", nargs="*", type=str, help="which databases to export?"
    )

    # import data
    parser.add_argument("--im_project", type=str, help="which project to check on?")
    parser.add_argument("--ex_sql", type=str, help="google cloud sql id")
    parser.add_argument("--im_sql", type=str, help="google cloud sql id", default=False)

    args = parser.parse_args()

    project: str = args.ex_project
    instance: str = args.ex_sql
    bucket: str = args.bucket
    im_project: str = args.im_project
    im_instance: str = args.im_sql

    databases = args.ex_databases
