FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 JULIA_CPU_THREADS=4
RUN pip install --no-cache-dir torch==2.8.0 --index-url https://download.pytorch.org/whl/cpu
COPY download_model.py ./
RUN python download_model.py && pip install --no-cache-dir /opt/julia-model
ENV HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
COPY server.py test_server.py ./
RUN python -m unittest -v test_server
USER 65534:65534
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=3s --start-period=60s --retries=4 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=2)"
CMD ["python", "server.py"]
