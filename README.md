# Word Wolf

A vocabulary learning app built with Flutter and Spring Boot. Save multilingual
vocabulary, practice it in adaptive lessons, and track your progress. Optional
local models can suggest translations, estimate their correctness, and screen
lesson choices without sending learning data to a cloud service.

<p align="center">
  <img src="shots/icon.jpg" alt="Word Wolf logo" width="280">
</p>

## Features

- Create an account and sign in.
- Add vocabulary in English, Persian, German, French, Spanish, and Arabic.
- Suggest editable meanings locally with MADLAD-400 and review Julia-1's
  uncalibrated correctness estimate before saving.
- Browse your word list, search vocabulary, and discover popular words.
- Practice weaker words first with review cards, forward questions, and reverse
  recall. Julia-1 filters distractors that may also be correct answers.
- Track experience points, levels, and daily streaks.
- Use the responsive interface on mobile, desktop, or the web.

## Explore the app

### A focused start

The full-height opening sequence introduces Word Wolf without delaying access to
the learning flow.

| First frame | Second frame |
| --- | --- |
| ![Black wolf and white wolf opening frame](shots/splash-first.png) | ![White wolf and black wolf opening frame](shots/splash-second.png) |

### Access your account

Create an account or return to an existing learning profile.

| Sign in | Create an account |
| --- | --- |
| ![Word Wolf sign-in page](shots/login-1440.png) | ![Word Wolf account creation page](shots/sign-up-1440.png) |

### Your learning dashboard

Start a lesson, follow XP and streak progress, or jump directly to saved,
searchable, and popular vocabulary.

| Desktop | Mobile |
| --- | --- |
| ![Word Wolf desktop dashboard](shots/dashboard-1440.png) | ![Word Wolf mobile dashboard](shots/dashboard-320.png) |

### Build your vocabulary

Choose both languages, enter a word, and either write its meaning or request a
local suggestion. The same form stays readable on narrow and wide screens.

| Add a word | Local suggestion | Narrow layout |
| --- | --- | --- |
| ![Empty add-word form](shots/add-word-1440.png) | ![Local suggestion with Julia correctness estimate](shots/suggestion-1440.png) | ![Responsive add-word form with an editable Persian meaning](shots/word-form-320.png) |

MADLAD suggestions remain editable and require an explicit save. Julia's displayed
percentage is a model estimate, not measured accuracy; it can be confidently wrong.

### Find and manage words

Review saved vocabulary, search the shared collection, and browse words other
learners are practicing.

| My words | Search | Popular words |
| --- | --- | --- |
| ![Saved vocabulary and progress](shots/my-words-1440.png) | ![Vocabulary search results](shots/search-1440.png) | ![Popular vocabulary](shots/popular-words-1440.png) |

### Practice a lesson

Lessons begin with review cards, continue with checked questions, and save
progress after completion.

| Review | Question | Complete |
| --- | --- | --- |
| ![Lesson review card](shots/lesson-review-1024.png) | ![Checked lesson question](shots/lesson-1024.png) | ![Completed lesson summary](shots/lesson-complete-1024.png) |

### Track your account

Explore streak milestones and update account details from the dashboard.

| Streak levels | Account settings |
| --- | --- |
| ![Streak level journey](shots/streak-levels-1440.png) | ![Account settings page](shots/settings-1440.png) |

_All current page captures were produced from the live app in isolated Ungoogled
Chromium sessions._

## How it works

The Flutter client sends authenticated HTTP requests to the Spring Boot API. The
API handles accounts, vocabulary, progress, and lessons, and stores data in
PostgreSQL through JDBC. MADLAD-400 and Julia-1 run as private local services on
the Docker network; only Nginx publishes a host port.

| Component | Technology | Location |
| --- | --- | --- |
| Client | Flutter 3.35.7 / Dart 3.9 | [`lib/`](lib/) |
| API | Spring Boot 3.3.0 / Java 17 | [`restAPi/`](restAPi/) |
| Database | PostgreSQL | Configured in `restAPi/.env` |
| Translation model | MADLAD-400 through llama.cpp | [`deploy/ai/`](deploy/ai/) |
| Decision model | Julia-1 | [`deploy/julia/`](deploy/julia/) |
| Full-stack deployment | Docker Compose and Nginx | [`compose.yaml`](compose.yaml) |
| Standalone web deployment | Vercel | [`vercel.json`](vercel.json) |

### C4 container diagram

<a href="shots/c4-container.svg">
  <img src="shots/c4-container.svg" alt="C4 container diagram for Word Wolf" width="900">
</a>

_Open the diagram for the full-size vector version._

Nginx serves the Flutter build and proxies API requests. The model services and
database stay inside the Compose network. A one-shot preparation container copies
the mounted GGUF into a compatible Docker volume without changing the source file.

### Database structure

```mermaid
erDiagram
    PERSON ||--o{ WORD_USER : learns
    WORD ||--o{ WORD_USER : tracks
    PERSON ||--o{ LESSON : owns

    PERSON {
        text id PK
        text username
        text password
        text email
        integer strike_level
        integer xp
        integer level
        integer strike
        text is_practice_today
    }
    WORD {
        text id PK
        text actword
        text meaning
        text wordlang
        text meanLang
    }
    WORD_USER {
        text wordid PK, FK
        text userid PK, FK
        double progress
        date progress_updated_on
    }
    LESSON {
        text id PK
        text userid FK
        text date
        text data
    }
```

Vocabulary is shared by content, while `word_user` keeps each learner's progress.
Lessons store their generated question data until the authenticated owner submits
the result.

## Run locally

These commands use Bash. Start the API first, then launch the client in a second
terminal.

### Prerequisites

- Git and Bash.
- Flutter **3.35.7**, including its Dart SDK. The installer below can download
  this version into the project.
- A full **JDK 17 or newer** for the backend. Maven is downloaded by the included
  wrapper, so a separate Maven installation is unnecessary.
- A running PostgreSQL server with a database and credentials for the app.
- Chrome for the browser development command below, or a configured Flutter
  device for mobile development.
- Docker if you want to run the API as a container.

### 1. Clone the project

```bash
git clone https://github.com/seyed0123/word-wolf.git
cd word-wolf
```

### 2. Configure and start the API

```bash
cd restAPi
cp .env.example .env
```

For an existing checkout, keep your configured `.env` instead of overwriting it.
Edit the new file to match your PostgreSQL database:

```dotenv
DB_URL=jdbc:postgresql://localhost:5432/wordwolf
DB_USERNAME=wordwolf
DB_PASSWORD=your-database-password
```

The database and role must already exist. On startup, the API creates its tables;
the role needs permission to create and use them. All three settings are required.
The `.env` file is ignored by Git.

Start the API from `restAPi` so it can find `.env`:

```bash
bash ./mvnw spring-boot:run
```

The default API address is `http://localhost:8080`. See the
[backend README](restAPi/README.md) for environment variable precedence, file
format details, and container networking.

### 3. Point the client at the API

From the repository root, edit [`assets/env.txt`](assets/env.txt):

```dotenv
SERVER_URL=http://localhost:8080
```

Use the base URL without a trailing slash. For an Android emulator, use
`http://10.0.2.2:8080`; for a physical device, use your computer's reachable LAN
address.

`assets/env.txt` is bundled with the client and is public. It contains only the
API address; database credentials belong in the backend's `.env`. Rebuild the
client after changing its bundled configuration.

### 4. Install dependencies and launch the client

In a second terminal, from the repository root:

```bash
bash scripts/install-flutter.sh
.flutter-sdk/3.35.7/bin/flutter run -d chrome
```

The installer downloads the pinned SDK and installs the versions recorded in
`pubspec.lock`. If Flutter 3.35.7 is already on your PATH, you can instead use:

```bash
flutter pub get --enforce-lockfile
flutter run -d chrome
```

For a configured mobile device, run `flutter devices`, then
`flutter run -d <device-id>`.

## Deployment

### Frontend on Vercel

Set `SERVER_URL` in `assets/env.txt` to your deployed API's HTTPS base URL before
building. Setting a Vercel environment variable alone does not change this asset.
The API must be deployed separately and reachable from the user's browser.

Use the **repository root** as the Vercel project root. The committed
[`vercel.json`](vercel.json) supplies these settings:

| Setting | Value |
| --- | --- |
| Framework preset | Other (`null` in configuration) |
| Install command | `bash scripts/install-flutter.sh` |
| Build command | `.flutter-sdk/3.35.7/bin/flutter build web --release` |
| Output directory | `build/web` |

To build the same output locally:

```bash
bash scripts/install-flutter.sh
.flutter-sdk/3.35.7/bin/flutter build web --release
```

The SDK is pinned to keep deployments reproducible. When changing dependencies,
use that SDK and commit the updated `pubspec.lock` alongside `pubspec.yaml`.

### Full stack with Docker Compose (no host Java or Flutter needed)

The root [`compose.yaml`](compose.yaml) builds and tests both applications inside
containers, and runs Nginx, Spring Boot, PostgreSQL, llama.cpp (MADLAD-400) and Julia-1.
Only Nginx publishes a host port. Your existing GGUF file is mounted read-only.
A one-shot `model-prep` container adapts its metadata and tensor names into the
`madlad_model` volume (about 3.2 GB extra). Quantized tensor bytes are verified
unchanged; the original file is preserved. The official tokenizer is downloaded
once during the preparation image build.
The Julia image downloads its pinned checkpoint during the first build; both
models run locally without cloud inference.

1. Keep your existing `restAPi/.env`, or copy `restAPi/.env.example` to it.
2. Set `DB_USERNAME` and `DB_PASSWORD` in that file.
3. Place your model at `~/models/madlad400-3b-mt-q8_0.gguf`, or set
   `LOCAL_MODEL_PATH` to an absolute GGUF path in `restAPi/.env`.
4. From the repository root, run:

```bash
docker compose up --build -d
docker compose logs -f backend ai julia nginx
```

Open **http://localhost:8080**. Change `HTTP_PORT` in `restAPi/.env` if needed.
The first build downloads container images and dependencies. Subsequent builds
reuse Docker's cache. MADLAD runs locally on CPU through llama.cpp’s encoder-decoder completion executable; `LLAMA_THREADS` defaults
to 4 and `LOCAL_AI_TIMEOUT_SECONDS` to 60. Allow model loading to finish before
requesting a suggestion. Build and dependency downloads need network access;
inference stays local.

On **Add a word**, choose both languages, enter a word, and select **Suggest a
meaning**. Review the suggestion and use it to populate the editable meaning
field. Saving still asks for confirmation. Model errors do not prevent manual
entry. MADLAD translates using the selected target language. It does not generate
same-language definitions: choose different languages for suggestions or type a
definition manually. Translations remain editable and require review, particularly
for isolated words with multiple senses. See [MADLAD setup and verification](docs/madlad.md).

Lessons prioritize less familiar vocabulary, review weaker words, and mix forward
and reverse recall for practiced words. Answers come from saved vocabulary in the
same language pair, with distinct alternatives. Small collections get two or three
choices; when no distinct alternative exists, the word remains a review card.
An empty collection offers an action to add the first word. Lesson generation
works without the model.

Julia-1 runs in its own CPU container (`JULIA_CPU_THREADS=4` by default). Its
checkpoint is about 551 MiB, baked into the image with a verified SHA-256. Runtime
uses offline model loading. No extra model file or host Python package is needed.

After every MADLAD suggestion, Julia compares the original word and generated
meaning using both selected languages. The suggestion card displays **Estimated
correctness: N%**, calculated from Julia's probability for the “correct” option.
No saved word or reference is required, and no saved-vocabulary lookup occurs.
The percentage is an uncalibrated model estimate and may be confidently wrong;
it does not automatically accept or save the meaning. If Julia is unavailable,
the meaning remains editable and the card says its estimate is unavailable.
[Scoring contract and evaluation](docs/julia.md).

Julia also advises on practice formats for the six selected words and rejects
candidate test options that may also be correct translations. The backend keeps
mandatory weak-word reviews, the existing reverse-recall mix and saved answers;
when Julia finds no safe distractor, that item becomes a review card. This is
experimental advice; improved learning outcomes have not been established. If
Julia is stopped or times out, suggestions remain editable and lessons use the
existing deterministic duplicate checks.

Nginx provides `SERVER_URL=/api`, so no change to `assets/env.txt` is needed.
The Flutter build is included in the Nginx image; a host `build/web` directory is
not required. Rebuild after source changes.

Compose waits for PostgreSQL readiness and stores data in a named volume. Stop
with `docker compose down`; data is retained. Database
initialization settings apply only to an empty volume. Changing credentials in
`restAPi/.env` does not update an existing database's credentials.

#### Docker verification

The backend Docker build runs JUnit; the frontend build runs Flutter widget tests
before compiling the release web app. To build and exercise an isolated test stack
(accounts, vocabulary, lessons, progress, real local inference and web serving):

```bash
bash scripts/docker-check.sh
```

This uses project `wordwolf-check` and port 18080 (`TEST_HTTP_PORT` overrides it),
leaving the normal database volume untouched. It creates uniquely named test users.
The script leaves the stack running for browser inspection. Stop it with:

```bash
docker compose --project-name wordwolf-check down
```

If Docker reports permission denied on `/var/run/docker.sock`, enable Docker access
for your user before running these commands. No host Java or Flutter is required.

The llama.cpp integration follows its official
[server API](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)
and [Docker setup](https://github.com/ggml-org/llama.cpp/blob/master/docs/docker.md).

### Backend with Docker

For only the backend and database, run from `restAPi`:

```bash
docker compose up --build -d
```

That separate configuration publishes the API directly at `http://localhost:8080`
(configurable with `BACKEND_PORT`). Run only one stack on that port at a time.

To run **only the backend against an existing database**, use the standalone image.
After configuring `restAPi/.env`, run from the repository root:

```bash
docker build -t word-wolf-api ./restAPi
docker run --rm --name word-wolf-api -p 8080:8080 --env-file restAPi/.env word-wolf-api
```

The image builds and tests the API with Maven, then runs the executable JAR as a
non-root user in a Java 17 runtime. Credentials are supplied when the container
starts and are excluded from the image.

Inside the container, `localhost` refers to the container itself. Use a reachable
PostgreSQL hostname in `DB_URL`; see [container networking](restAPi/README.md#run-with-docker)
for connecting to a database on the host machine.

## Development commands

The frontend commands below assume Flutter 3.35.7 is on your PATH. Alternatively,
use `.flutter-sdk/3.35.7/bin/flutter` from the repository root.

| Command | Working directory | Purpose |
| --- | --- | --- |
| `flutter pub get --enforce-lockfile` | Repository root | Install locked dependencies |
| `flutter analyze` | Repository root | Run static analysis |
| `flutter build web --release` | Repository root | Build the web client |
| `bash ./mvnw test` | `restAPi` | Run backend tests |
| `bash ./mvnw package` | `restAPi` | Test and build the executable JAR |

### Browser regression checks

With the Docker stack running and Chromium installed:

```bash
npm install --prefix /tmp/wordwolf-browser playwright
NODE_PATH=/tmp/wordwolf-browser/node_modules BROWSER_URL=http://localhost:8080 node scripts/browser-check.cjs
```

Set `CHROMIUM_PATH` if Chromium is not at `/usr/lib/ungoogled-chromium/chromium`.
The runner creates a test account, exercises suggestions and learning flows, and
writes screenshots to `/tmp/wordwolf-browser-artifacts` (`BROWSER_ARTIFACTS` overrides it).
See [verification notes](docs/improvements.md) for results and screenshots.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| API reports a missing database setting | Ensure `DB_URL`, `DB_USERNAME`, and `DB_PASSWORD` are set, and launch from `restAPi`. |
| Database connection fails | Check the database exists, credentials are correct, and the host and port are reachable from the API. |
| Client cannot reach the API | Check `assets/env.txt`, device-specific host addressing, and the browser network console. An HTTPS frontend needs an HTTPS API. |
| `FontWeight` constant evaluation error | Use the pinned Flutter SDK and committed lockfile, which includes `google_fonts` 6.3.3. |
| Legacy `dart:html` warning from preferences | Install from the current lockfile, which includes `shared_preferences_web` 2.3.0. |
| Maven reports an unsupported Java release | Check `JAVA_HOME` points to a full JDK 17 or newer. |

## Contributing

Open an issue to discuss a bug or proposed feature, or submit a focused pull
request. Include a description of the change and the commands you used to verify
it. For frontend changes, include screenshots when they help explain the result.
Keep backend credentials out of commits and update the setup documentation when
configuration changes.

## License

Word Wolf is available under the [MIT License](LICENSE).
