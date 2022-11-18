# Tools

**tools I use to efficient my development experience**

[tavisod](./tavisod/): tool to fetch secrets from google secret manager in one line
[slack_alert](./slack_alert/): tool to alert to slack for when a build finishes

**make sure you are in project's dir**
```bash
python setup.py sdist
```

### Upload to pypi

```bash
pip install twine
```
```bash
twine upload --repository-url https://upload.pypi.org/legacy/ dist/*
```

### Usage

```bash
export PROJECT_ID=mike-development
```
```py
from tavisod.get_secrets import getSecret
getSecret().fromGsm("DB_PASSWORD")
```