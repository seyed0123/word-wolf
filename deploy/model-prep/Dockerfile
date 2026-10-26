FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir sentencepiece==0.2.1 protobuf==6.33.0
# Only the tokenizer is downloaded. Model tensors come from the user's local GGUF.
RUN python -c "import urllib.request; urllib.request.urlretrieve('https://huggingface.co/google/madlad400-3b-mt/resolve/fa184c675da0b5c9e1c8694fccd4e12e2d422094/spiece.model', '/app/spiece.model')"
COPY prepare.py ./
ENTRYPOINT ["python", "/app/prepare.py"]
