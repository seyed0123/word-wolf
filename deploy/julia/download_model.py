"""Download only the pinned runtime and checkpoint, once during image build."""
import hashlib
import json
from pathlib import Path
import shutil
import urllib.request

REVISION = 'a85b127321d580d65176c89ced8273f305745d85'
ROOT = Path('/opt/julia-model')
base = 'https://huggingface.co/SupersonicLabs/Julia-1'
with urllib.request.urlopen(f'https://huggingface.co/api/models/SupersonicLabs/Julia-1/revision/{REVISION}', timeout=60) as response:
    files = json.load(response)['siblings']
for entry in files:
    name = entry['rfilename']
    if not (name.startswith(('julia/', 'tokenizer/', 'encoder/')) or name in (
        'model.safetensors', 'config.json', 'julia_config.json', 'inference-policy.json',
        'provenance.json', 'pyproject.toml', 'README.md')):
        continue
    target = ROOT / name
    target.parent.mkdir(parents=True, exist_ok=True)
    print(f'Downloading {name}', flush=True)
    with urllib.request.urlopen(f'{base}/resolve/{REVISION}/{name}', timeout=180) as source, target.open('wb') as dest:
        shutil.copyfileobj(source, dest)
with (ROOT / 'model.safetensors').open('rb') as weights:
    digest = hashlib.file_digest(weights, 'sha256').hexdigest()
if digest != 'df853bf7fe424420011f3d0c47a05d7341aa9eefa7fb9f203ea4aada4ad95b72':
    raise ValueError('Julia checkpoint checksum mismatch')
