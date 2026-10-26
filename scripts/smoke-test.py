#!/usr/bin/env python3
"""Exercise an isolated Docker test stack. Creates uniquely named test accounts."""
import json
import os
import time
import uuid
import urllib.error
import urllib.request

base = os.environ.get('SMOKE_URL', 'http://localhost:18080').rstrip('/')
token = ''


def request(path, data=None):
    headers = {'Content-Type': 'application/json', 'Authorization': token}
    req = urllib.request.Request(base + '/api/' + path,
                                 data=None if data is None else json.dumps(data).encode(), headers=headers)
    with urllib.request.urlopen(req, timeout=145) as response:
        raw = response.read()
        return json.loads(raw) if raw else None


for attempt in range(90):
    try:
        request('get_popular_word')
        break
    except (urllib.error.URLError, TimeoutError):
        time.sleep(2)
else:
    raise SystemExit('Backend did not become ready')

name = 'smoke_' + uuid.uuid4().hex[:12]
account = {'username': name, 'password': uuid.uuid4().hex, 'email': name + '@example.test'}
signed_up = request('sign_up', account)
assert signed_up['message'] == 'ok', signed_up.get('message')
token = signed_up['token']
assert request('login', account)['message'] == 'ok'
assert request('new_lesson')['questions'] == []
for word, meaning in [('hello', 'سلام'), ('book', 'کتاب'), ('water', 'آب'), ('sun', 'خورشید')]:
    assert request('add_word', {'word': word, 'wordMeaning': meaning,
                              'wordLang': 'English', 'meaningLang': 'Persian'})['message'] == 'ok'
words = request('get_word')
assert len(words) == 4
assert any(word['meaning'] == 'سلام' for word in words)
lesson = request('new_lesson')
assert len(lesson['questions']) == 4
for question in lesson['questions']:
    assert 2 <= len(question['answers']) <= 4
    assert len(question['answers']) == len(set(question['answers']))
    assert 0 <= question['correct'] < len(question['answers'])
request('res_lesson', {'lesson_id': lesson['id'], 'success': True, 'ans': [True] * 4})
assert request('get_user')['xp'] >= 14
assert request('get_user')['practiceToday']
print('PASS: accounts, Unicode vocabulary, lessons, XP and streaks')

# Check known translations in different selected meaning languages. This is a
# small integration sample, not a guarantee of model translation quality.
for word, target, expected in [('book', 'Persian', 'کتاب'), ('book', 'German', 'buch'), ('water', 'French', 'eau')]:
    for attempt in range(5):
        try:
            suggestion = request('suggest_meaning', {'word': word, 'wordLang': 'English', 'meaningLang': target})
            assert expected in suggestion['meaning'].casefold(), (word, target, suggestion)
            assert suggestion['review']['model'] == 'Julia-1'
            assert suggestion['review']['status'] == 'scored', suggestion
            assert 0 <= suggestion['review']['correctnessProbability'] <= 1, suggestion
            print(f'PASS: local {word} → {target}: {suggestion["meaning"]}')
            break
        except urllib.error.HTTPError as error:
            if error.code != 503 or attempt == 4:
                raise
            time.sleep(5)

with urllib.request.urlopen(base) as response:
    assert b'flutter_bootstrap.js' in response.read()
with urllib.request.urlopen(base + '/assets/assets/env.txt') as response:
    assert b'SERVER_URL=/api' in response.read()
print('PASS: Flutter web serving and same-origin API configuration')
