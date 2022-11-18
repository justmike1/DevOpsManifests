# Setup

```bash
pip install tavisod
```

# Usage

```bash
export PROJECT_ID=mike-development
```
```py
from tavisod.get_secrets import getSecret
getSecret().fromGsm("DB_PASSWORD")
```

## Build project

**make sure you are in project's dir**
```bash
python setup.py sdist
```

## Upload to pypi

```bash
pip install twine
```
```bash
twine upload --repository-url https://upload.pypi.org/legacy/ dist/*
```

### TODO: add all provider's secret managers
