FROM python:3.9-alpine

COPY requirements.txt .
COPY entrypoint.py .

RUN mkdir /output \
    && pip3 install -r requirements.txt \
    && chmod +x entrypoint.py


ENTRYPOINT ["python", "entrypoint.py"]