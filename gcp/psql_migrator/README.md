# Database migrator

## Instructions

* Setup python
    ```bash
    brew install python@3.8
    python3.8 -m venv venv
    source venv/bin/activate
    ```
* Install requirements
    ```bash
    pip install -r tools/migrate_db/requirements.txt
    ```

### Running the migrator

> The script has multiple argumets:
* --ex_project: source google cloud project
* --im_project: destination google cloud project
* --bucket: s3 bucket that stores the files | **(default: gs://import_export_db/python/)**
* --ex_databases: which databases to export?
* --ex_sql: export source google cloud sql id | **required**
* --im_sql: import destination google cloud sql id | **required**

```bash
python migrate_db/migrate_db.py --ex_sql <SOURCE_DB> --im_sql <DEST_DB>
```

### Running the localhost migrator

**make sure you have installed postgresql via brew**
```bash
brew install postgresql@14 # or 13
```
* run the migrator with the desired database to migrate
```bash
./tools/migrate_db/init.sh <DB_1> <DB_2>

# I.E:
./tools/migrate_db/init.sh emr
```

### Test

> To check if the migration worked
* connect to the database via ssh tunneling (if migrated between google SQLs)
```bash
psql postgres://postgres:<SQL_PASS>@localhost:5432/
\list
```

* if migrated to localhost then
```bash
psql postgres://postgres:password@localhost:5432/
\list
```

### Run as a Docker
> the docker run should have the google credential file as volume and as environment variable 
* GOOGLE_APPLICATION_CREDENTIALS 

```bash
    docker run -e GOOGLE_APPLICATION_CREDENTIALS=/adc.json \
    -v ~/.config/gcloud/legacy_credentials/<EMAIL>/adc.json:/adc.json sql_migrator \
    --ex_sql=source --im_sql=target
```
