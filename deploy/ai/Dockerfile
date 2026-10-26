FROM ubuntu:24.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp.git

WORKDIR /src/llama.cpp
RUN cmake -B build -DGGML_NATIVE=ON -DLLAMA_BUILD_SERVER=ON \
    && cmake --build build --config Release -j$(nproc)

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libgomp1 python3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/llama.cpp/build/bin/ /usr/local/bin/
RUN ldconfig /usr/local/bin

EXPOSE 8080

WORKDIR /app
COPY server.py test_server.py ./
RUN python3 -m unittest -v test_server
USER 65534:65534
HEALTHCHECK --interval=10s --timeout=3s --retries=6 CMD python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=2)"
ENTRYPOINT ["python3", "/app/server.py"]
