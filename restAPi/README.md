# Spring Boot backend

For local Java execution, use a full JDK 17 or newer and an existing PostgreSQL
database. Docker Compose can run both services without a local JDK or database.
Run commands from `restAPi` unless a section says otherwise.

For the full stack with Nginx and the Flutter frontend, see the
[root deployment guide](../README.md#full-stack-with-docker-compose).

## Run the backend and database together

From **`restAPi`**, create `.env` from `.env.example`
if you do not already have one. Set `DB_USERNAME` and `DB_PASSWORD`, then run:

```sh
docker compose up --build -d
docker compose logs -f backend
```

The API is available at `http://localhost:8080`. Compose starts PostgreSQL 17,
creates the database on first initialization, and waits for its health check
before starting the backend. PostgreSQL is accessible on the Compose network
as `db:5432`; its port is not published to the host.

Compose constructs `DB_URL` for its own database, so the standalone `DB_URL`
in `.env` is not used in this mode. `DB_NAME` defaults to `wordwolf` and
`BACKEND_PORT` defaults to `8080`. Both services use the same username and password.
Compose parses `.env` values for interpolation; single-quote a password containing
literal `$` characters when using Compose.

```sh
# Show service status
docker compose ps

# Stop and remove containers while keeping database data
docker compose down
```

Database data persists in the `postgres_data` named volume. Do not add `--volumes`
to `down` unless you intend to delete that data. PostgreSQL initialization settings
apply only to an empty volume; changing the credentials in `.env` does not change
users or passwords in an existing database.

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


## Local meaning suggestions

`POST /suggest_meaning` requires the same Authorization token as word operations.
The JSON body contains `word` (1–200 characters), `wordLang`, and `meaningLang`.
Supported languages: English, Persian, German, French, Spanish and Arabic
(MADLAD tags `en`, `fa`, `de`, `fr`, `es`, `ar`). Equal source and target languages
return 400 because this model translates rather than writing definitions.
The response is `{"meaning":"...","review":{"status":"scored","correctnessProbability":0.93,"model":"Julia-1"}}`.
Invalid inputs return 400; unavailable,
timed-out or invalid model responses return 503. Suggestions do not write data.

`LOCAL_AI_URL` defaults to `http://localhost:8081` for a standalone backend.
The root Compose stack supplies `http://ai:8080`. Only loopback and the local
container hostnames `ai` / `host.docker.internal` are allowed, with redirects
disabled. `LOCAL_AI_TIMEOUT_SECONDS` defaults to 60 (maximum 120). The server uses
llama.cpp's `/v1/completions` with the MADLAD-400 translation model and bounded generation.
The backend-only Compose stack does not start a model; use the root stack for the
complete app. Lesson generation does not depend on AI availability.

`LOCAL_DECISION_URL` is empty (disabled) outside the root stack; root Compose uses
`http://julia:8080`. Only local HTTP origins are accepted, without redirects.
`LOCAL_DECISION_TIMEOUT_SECONDS` defaults to 8 (maximum 10). A Julia failure returns
`review.status=unavailable` while retaining the generated meaning. The model server
is private to Docker and has no published port.

Every generated word–meaning pair is sent to Julia with `word`, `wordLang`,
`meaning`, and `meaningLang`; there is no database/reference lookup. Julia returns
`status=scored` and numeric `correctnessProbability` in [0, 1], the full softmax
probability assigned to “correct” in a correct/incorrect choice. The frontend
multiplies it by 100 and displays one decimal place. It never uses the probability
of the winning option in place of P(correct). This score is not calibrated accuracy.
Invalid, missing, out-of-range or unavailable model results produce
`status=unavailable` with no probability; the MADLAD meaning is still returned.

For `/new_lesson`, Julia receives only IDs and mastery values for the selected
words. Advice is limited to review, forward recognition and reverse recall;
unknown IDs/modes and premature reverse recall are ignored. Highly practiced
words do not acquire extra reviews from Julia. Existing answer generation,
mandatory weak-word review and the recall mix remain authoritative.

### Progress after downtime

Word progress decays by 2 points per elapsed calendar day, stopping at zero.
Each saved word stores `progress_updated_on` in PostgreSQL. The backend catches
up before accepting requests and checks again every minute, including after a
temporary database outage. Updating progress and its date is one atomic SQL
statement, so repeated checks and restarts do not apply the same day twice.
Calendar dates use the PostgreSQL session time zone (UTC in the default Docker setup).
Existing words start tracking on the migration date; earlier missed days cannot
be reconstructed because the old version did not store an update date.

Run the PostgreSQL regression test entirely in Docker with
`bash scripts/test-word-progress.sh`.
