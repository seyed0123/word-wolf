# Spring Boot backend

Requires Java 17 or newer and an existing PostgreSQL database. Run these commands
from `restAPi`.

## Configuration

Copy `.env.example` to `.env` and set your database details:

```sh
cp .env.example .env
```

`DB_URL` must be a JDBC URL, such as `jdbc:postgresql://db-host:5432/wordwolf`.
`DB_USERNAME` and `DB_PASSWORD` are also required; missing or blank settings stop
startup. The app creates its tables, but the database itself must already exist.

Spring loads `.env` from the working directory as a Java properties file. Use
plain `KEY=value` lines without shell `export` or surrounding quotes. Literal
backslashes must be escaped as `\\`. Environment variables override file values.
The `.env` file is excluded from Git and the Docker build context.

## Run locally

```sh
bash ./mvnw spring-boot:run
```

For an IDE launch, set its working directory to `restAPi`.

## Run with Docker

```sh
docker build -t word-wolf-api .
docker run --rm --name word-wolf-api -p 8080:8080 --env-file .env word-wolf-api
```

The build runs the tests and packages the app with Java 17. The runtime image
contains only the JRE and application JAR and runs as a non-root user. Database
settings are supplied at runtime, so credentials are not baked into the image.
Docker reads `--env-file` values literally; use unquoted values and literal
backslashes for this mode.

Inside Docker, `localhost` refers to the application container. Set `DB_URL` to
a database hostname reachable from it, such as the PostgreSQL container name
on a shared Docker network. To reach a database on the Linux host, add
`--add-host=host.docker.internal:host-gateway` and use `host.docker.internal`
in `DB_URL`.
