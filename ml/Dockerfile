FROM python

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY app.py app.py

ENTRYPOINT ["python3"]
CMD ["app.py"]