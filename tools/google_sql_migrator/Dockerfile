FROM python:3.8.13-slim

COPY  migrate.py /usr/local/bin/migrate.py
COPY  requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt

ENTRYPOINT ["python", "/usr/local/bin/migrate.py"]
