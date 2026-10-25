Lab 8: Containerized Node.js and MySQL Stack Using Docker Compose
1) Clone the application code
git clone https://github.com/Ibrahim-Adel15/iVolveApp.git
cd iVolveApp
2) Create docker-compose.yml configuration
Create docker-compose.yaml specifying services, volumes, environment variables, and network:
Lab 8: Containerized Node.js and MySQL Stack Using Docker Compose
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: ivolve
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - ivolve-net

  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=db
      - DB_USER=root
      - DB_PASSWORD=rootpassword
      - DB_NAME=ivolve
    volumes:
      - app_logs:/app/logs/
    networks:
      - ivolve-net
    depends_on:
      - db

networks:
  ivolve-net:

volumes:
  db_data:
  app_logs:



3) Build and start services using Docker Compose
docker compose up -d --build


4) Verify running containers
docker compose ps
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS          PORTS                                         NAMES
81ca0c49794d   ivolveapp-app        "docker-entrypoint.s…"   33 seconds ago   Up 31 seconds   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   ivolveapp-app-1
12d7efc9a03f   mysql:8.0            "docker-entrypoint.s…"   33 seconds ago   Up 31 seconds   3306/tcp, 33060/tcp                           ivolveapp-db-1
Tag and push application image to Docker Hub
Tag the built application image:

docker tag ivolveapp peter2976/ivolveapp
Push to Docker Hub repository:

docker push peter2976/ivolveapp

