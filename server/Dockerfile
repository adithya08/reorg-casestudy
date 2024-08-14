FROM python:3.9-slim

WORKDIR /server
COPY . /server
RUN pip install fastapi uvicorn
EXPOSE 80
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "80"]