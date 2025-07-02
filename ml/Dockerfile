FROM python:3.10-slim  # или 3.11

RUN pip install faiss-cpu

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    swig \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY app.py app.py

ENTRYPOINT ["python3"]
CMD ["app.py"]
