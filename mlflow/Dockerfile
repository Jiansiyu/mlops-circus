FROM python:3.10-slim-buster
# Install python packages
COPY requirements.txt /tmp
RUN pip install psycopg2-binary & pip install -r /tmp/requirements.txt
