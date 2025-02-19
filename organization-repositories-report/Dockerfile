FROM python:3.9-alpine

# Set working directory
WORKDIR /app

# Copy necessary files
COPY requirements.txt .
COPY entrypoint.py .

RUN mkdir /output \
    && pip3 install -r requirements.txt \
    && chmod +x entrypoint.py


ENTRYPOINT ["python", "/app/entrypoint.py"]