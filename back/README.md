# FishMasters Backend

The project is written in Java 21 using Spring Boot 3.
Requires PostgreSQL database to run.

## Usage
For local application deployment, you need Docker version 2 or higher installed and running.
Create a .env file in the project root and specify the following values:
- POSTGRES_DB=<Database name>
- POSTGRES_USER=<Your PostgreSQL username>
- POSTGRES_PASSWORD=<User password>

### Deployment
Requires Java 21, Maven, and Docker installed.

- In the terminal, run the command:

          docker compose up --build

- If you need to clear the database on restart, run:

          docker-compose down -v
- To check database entries, execute:

        docker exec -it <POSTGRES_DB> bash
        psql -U <POSTGRES_USER> -d <POSTGRES_DB>

- Then enter your user password and run necessary SQL queries

### API Documentation
After application startup, documentation will be available at:
http://localhost:8080/swagger-ui/index.html#/

