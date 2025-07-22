# FishMasters Backend

The project is written in Java 21 using Spring Boot 3.
Requires PostgreSQL database to run.

## Usage
For local application deployment, you need Docker version 2 or higher installed and running.
Create a .env file in the project root and specify the following values:
- POSTGRES_DB=fish_masters
- POSTGRES_USER=postgres
- POSTGRES_PASSWORD=postgres

### Deployment
Requires Java 21, Maven, and Docker installed.

- In the terminal, run the command:

          docker-compose up --build


### API Documentation
After application startup, documentation will be available at:
http://localhost:8080/swagger-ui/index.html#/

