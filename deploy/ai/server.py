"""Local MADLAD API using llama-completion's encoder-decoder inference path."""
import json
import os
from pathlib import Path
import re
import subprocess
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

MODEL = '/models/model.gguf'
SLOT = threading.BoundedSemaphore(1)


def complete(data, run=subprocess.run):
    prompt = data.get('prompt')
    if not isinstance(prompt, str) or not re.fullmatch(r'<2(en|fa|de|fr|es|ar)> [\s\S]{1,200}', prompt):
        raise ValueError('Expected a MADLAD target-language tag and up to 200 characters')
    limit = data.get('max_tokens', 160)
    if type(limit) is not int or not 1 <= limit <= 160 or data.get('stream', False) is not False:
        raise ValueError('Invalid token limit or streaming request')
    result = run(['llama-completion', '-m', MODEL, '-p', prompt, '-n', str(limit),
                  '--temp', '0', '--seed', '1', '--no-display-prompt', '--simple-io', '--no-warmup',
                  '-t', str(max(1, min(16, int(os.getenv('LLAMA_THREADS', '4')))))],
                 stdin=subprocess.DEVNULL, capture_output=True, text=True, encoding='utf-8',
                 timeout=55, check=True)
    output = result.stdout.strip()
    ended = output.endswith('[end of text]')
    meaning = output.removesuffix('[end of text]').strip() if ended else output
    if not meaning or len(meaning) > 1000:
        raise RuntimeError('Empty or oversized translation')
    return {'choices': [{'text': meaning, 'finish_reason': 'stop' if ended else 'length'}]}


class Handler(BaseHTTPRequestHandler):
    def setup(self):
        super().setup()
        self.connection.settimeout(10)

    def respond(self, status, data):
        body = json.dumps(data, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        try:
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def do_GET(self):
        self.respond(200 if self.path == '/health' else 404,
                     {'model': 'MADLAD-400-3B-MT', 'status': 'ready'} if self.path == '/health' else {'error': 'Not found'})

    def do_POST(self):
        if self.path != '/v1/completions':
            self.respond(404, {'error': 'Not found'})
            return
        if not SLOT.acquire(blocking=False):
            self.respond(503, {'error': 'Local translator is busy. Try again shortly.'})
            return
        try:
            size = int(self.headers.get('Content-Length', 0))
            if not 0 < size <= 4096:
                raise ValueError('Invalid body size')
            data = json.loads(self.rfile.read(size))
            if not isinstance(data, dict):
                raise ValueError('Expected a JSON object')
            self.respond(200, complete(data))
        except (ValueError, TypeError):
            self.respond(400, {'error': 'Invalid translation input'})
        except (subprocess.SubprocessError, RuntimeError, OSError):
            self.log_error('Local MADLAD inference failed')
            self.respond(503, {'error': 'Local translation unavailable'})
        finally:
            SLOT.release()


if __name__ == '__main__':
    if not Path(MODEL).is_file():
        raise SystemExit('Run model-prep first: compatible MADLAD model is missing')
    print('MADLAD translator listening on :8080', flush=True)
    ThreadingHTTPServer(('0.0.0.0', 8080), Handler).serve_forever()
