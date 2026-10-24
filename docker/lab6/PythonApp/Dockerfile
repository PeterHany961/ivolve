FROM python:3.12-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
ENV APP_NAME=iVolveApp3
ENV APP_ENV=dev
EXPOSE 5000
CMD ["python3", "app.py"]
