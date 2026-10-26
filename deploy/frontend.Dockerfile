FROM ghcr.io/cirruslabs/flutter:3.35.7 AS build

ARG PUB_HOSTED_URL=https://pub.dev
ARG FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com

ENV PUB_HOSTED_URL=${PUB_HOSTED_URL}
ENV FLUTTER_STORAGE_BASE_URL=${FLUTTER_STORAGE_BASE_URL}

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./

# A mirror changes only the registry URL; locked versions and hashes stay intact.
RUN if [ "$PUB_HOSTED_URL" != "https://pub.dev" ]; then \
      sed -i "s|https://pub.dev|$PUB_HOSTED_URL|g" pubspec.lock; \
    fi && \
    flutter pub get --enforce-lockfile

COPY lib ./lib
COPY assets ./assets
COPY web ./web
COPY test ./test
COPY analysis_options.yaml ./

RUN flutter test --no-pub
RUN flutter build web --release --no-pub --no-web-resources-cdn


FROM nginx:stable-alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80