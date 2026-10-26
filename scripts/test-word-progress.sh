#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Run through `sg docker -c 'bash scripts/test-word-progress.sh'` if needed.
test_name="wordwolf-progress-test-$$"
cleanup() {
  docker rm -f "$test_name-app" "$test_name" >/dev/null 2>&1 || true
  docker network rm "$test_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT
docker build --target build -t wordwolf-progress-tests restAPi
docker network create "$test_name" >/dev/null
docker run -d --name "$test_name" --network "$test_name" \
  -e POSTGRES_USER=progress_test -e POSTGRES_PASSWORD=progress_test \
  -e POSTGRES_DB=progress_test postgres:15 >/dev/null
for attempt in {1..30}; do
  if docker exec "$test_name" pg_isready -U progress_test -d progress_test >/dev/null; then break; fi
  sleep 1
done
docker run --rm --network "$test_name" \
  -e "PROGRESS_TEST_DB_URL=jdbc:postgresql://$test_name:5432/progress_test" \
  wordwolf-progress-tests mvn -B -Dtest=WordProgressTests test

# Exercise migration and the actual application startup/restart against isolated data.
psql_test() {
  docker exec "$test_name" psql -X -v ON_ERROR_STOP=1 -U progress_test -d progress_test "$@"
}
psql_test -c "CREATE TABLE word_user (wordid TEXT, userid TEXT, progress DOUBLE PRECISION);
INSERT INTO word_user VALUES ('old-word', 'test-user', 80);"
start_app() {
  docker run -d --name "$test_name-app" --network "$test_name" \
    -e "DB_URL=jdbc:postgresql://$test_name:5432/progress_test" \
    -e DB_USERNAME=progress_test -e DB_PASSWORD=progress_test \
    wordwolf-progress-tests java -jar target/restAPi-0.0.1-SNAPSHOT.jar >/dev/null
  for attempt in {1..60}; do
    if docker logs "$test_name-app" 2>&1 | rg -q 'Started RestAPiApplication'; then return; fi
    sleep 1
  done
  docker logs "$test_name-app"
  return 1
}
assert_saved_progress() {
  actual=$(psql_test -Atc "SELECT progress FROM word_user WHERE wordid = 'old-word'")
  test "$actual" = "$1" || { echo "Expected progress $1, got $actual"; exit 1; }
}
start_app
assert_saved_progress 80
docker rm -f "$test_name-app" >/dev/null
psql_test -c "UPDATE word_user SET progress_updated_on = CURRENT_DATE - 3;"
start_app
assert_saved_progress 74
docker rm -f "$test_name-app" >/dev/null
start_app
assert_saved_progress 74
echo "PASS: migration preserves progress; startup catches up three days; restart does not charge twice."
