# Word Wolf

A vocabulary learning app built with Flutter and Spring Boot. Save words and
translations, practice them in lessons, and track your learning progress.

<p align="center">
  <img src="shots/icon.jpg" alt="Word Wolf logo" width="280">
</p>

## Features

- Create an account and sign in.
- Add vocabulary with word and translation languages.
- Browse your word list, search vocabulary, and discover popular words.
- Review words and answer practice questions in lessons.
- Track experience points, levels, and daily streaks.
- Manage your account settings.

## Explore the app

### Your learning dashboard

Track your progress, revisit saved vocabulary, and find words to learn next.

| Home and progress | Your vocabulary | Popular words |
| --- | --- | --- |
| ![Home and learning progress](shots/home.png) | ![Personal word list](shots/wordList.png) | ![Popular words](shots/popularWords.png) |

### Build your vocabulary

Add words and translations, then search the vocabulary collection.

| Add a word | Search vocabulary |
| --- | --- |
| ![Add a word and translation](shots/newWord.png) | ![Search vocabulary](shots/search.png) |

### Review and practice

Review words and their translations before working through lesson questions.

| Word review | Translation review |
| --- | --- |
| ![Review a word](shots/lessonWord1.png) | ![Review its translation](shots/lessonWord2.png) |

| Practice screen 1 | Practice screen 2 | Practice screen 3 |
| --- | --- | --- |
| ![Lesson question, first example](shots/lessonQues1.png) | ![Lesson question, second example](shots/lessonQues2.png) | ![Lesson question, third example](shots/lessonQues3.png) |

### Your account

Create an account, sign in, and manage your settings.

| Sign in | Create an account | Settings |
| --- | --- | --- |
| ![Sign in](shots/login.png) | ![Sign up](shots/signUp.png) | ![Account settings](shots/setting.png) |

## How it works

The Flutter client sends HTTP requests to the Spring Boot API. The API handles
accounts, vocabulary, and lessons, and stores data in PostgreSQL through JDBC.
Authentication uses JWT tokens.

| Component | Technology | Location |
| --- | --- | --- |
| Client | Flutter 3.35.7 / Dart 3.9 | [`lib/`](lib/) |
| API | Spring Boot 3.3.0 / Java 17 | [`restAPi/`](restAPi/) |
| Database | PostgreSQL | Configured in `restAPi/.env` |
| Web deployment | Vercel | [`vercel.json`](vercel.json) |
| API container | Docker, Maven build, Java runtime | [`restAPi/Dockerfile`](restAPi/Dockerfile) |

### Server structure

![Server structure diagram](shots/serverSTR.png)

### Database structure

![Database structure diagram](shots/DBSTR.png)

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

### Backend with Docker

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
