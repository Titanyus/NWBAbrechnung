# syntax=docker/dockerfile:1
FROM ruby:3.4-slim@sha256:9833b550489549d20cd1b40746d1d1227db309d2667c70695e239c6a99a87d3f
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libpq-dev git && rm -rf /var/lib/apt/lists/*
ENV BUNDLE_FROZEN=true
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN --mount=type=secret,id=proxy_ca \
    if [ -f /run/secrets/proxy_ca ]; then export SSL_CERT_FILE=/run/secrets/proxy_ca; fi; \
    BUNDLE_FROZEN=true bundle install --jobs 4 --retry 3
COPY . .
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
