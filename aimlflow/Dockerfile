FROM python:3.10-slim-buster
# Install python packages
COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

WORKDIR /opt/aim
RUN aim init
ENTRYPOINT ["aim"]
CMD ["up"]
