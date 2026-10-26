#!/usr/bin/env python3
"""Run inside the Julia container; record a small diagnostic, not a benchmark.

sg docker -c 'docker compose --env-file restAPi/.env exec -T julia python' \
  < scripts/evaluate-julia.py > /tmp/julia-evaluation.json
"""
import json
import time
import urllib.request


def request(path, data):
    start = time.monotonic()
    req = urllib.request.Request('http://localhost:8080/' + path,
        data=json.dumps(data).encode(), headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req, timeout=30) as response:
        return json.load(response), round(time.monotonic() - start, 3)


cases = [
    ('book', 'Persian', 'کتاب', True),
    ('book', 'Persian', 'آب', False),
    ('hello', 'Persian', 'سلام', True),
    ('hello', 'Persian', 'خداحافظ', False),
    ('apple', 'Persian', 'سیب', True),
    ('apple', 'Persian', 'موز', False),
    ('book', 'German', 'Buch', True),
    ('book', 'German', 'Wasser', False),
    ('water', 'French', 'eau', True),
    ('water', 'French', 'soleil', False),
    ('sun', 'Spanish', 'sol', True),
    ('sun', 'Spanish', 'agua', False),
    ('book', 'Arabic', 'كتاب', True),
    ('book', 'Arabic', 'ماء', False),
]
results = []
for word, target, meaning, correct in cases:
    response, seconds = request('review', dict(word=word, wordLang='English', meaningLang=target, meaning=meaning))
    assert response['status'] == 'scored' and 0 <= response['correctnessProbability'] <= 1, response
    results.append(dict(word=word, target=target, meaning=meaning, correct=correct, **response, seconds=seconds))
plan, seconds = request('lesson-plan', {'words': [{'id': str(progress), 'progress': progress} for progress in (0, 20, 40, 60, 80, 100)]})
print(json.dumps(dict(model='SupersonicLabs/Julia-1', revision='a85b127321d580d65176c89ced8273f305745d85',
    note='Direct word-meaning pair scoring. P(correct) is an uncalibrated model estimate, not measured factual accuracy.',
    reviews=results, lessonPlan=plan, lessonSeconds=seconds), ensure_ascii=False, indent=2))
