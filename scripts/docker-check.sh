#!/usr/bin/env bash
# Isolated validation stack: never touches the normal deployment's database volume.
set -euo pipefail
cd "$(dirname "$0")/.."
docker info >/dev/null
export HTTP_PORT="${TEST_HTTP_PORT:-18080}"
export SMOKE_URL="http://localhost:$HTTP_PORT"
compose=(docker compose --project-name wordwolf-check --env-file restAPi/.env)
"${compose[@]}" config --quiet
"${compose[@]}" up --build -d --wait --wait-timeout 180
python3 scripts/smoke-test.py
printf 'Test stack is running at %s\nStop it with: docker compose --project-name wordwolf-check --env-file restAPi/.env down\n' "$SMOKE_URL"
