# syntax=docker/dockerfile:1
FROM node:22.23.4-bookworm AS admin-build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --include=dev --no-audit --no-fund
COPY app/javascript app/javascript
COPY config/webpack config/webpack
COPY config/shakapacker.yml config/shakapacker.yml
COPY .babelrc babel.config.js .browserslistrc .postcssrc.yml postcss.config.js ./
COPY LICENSE.md ./
ENV NODE_ENV=production RAILS_ENV=production \
    PUBLIC_CLIENT_ID=admin_public PUBLIC_CLIENT_SECRET=elicit-demo-public-admin \
    WEBAPP_CLIENT_SECRET=elicit-demo-public-webapp
RUN ./node_modules/.bin/webpack --config config/webpack/webpack.config.js

FROM rust:1.85.1-bookworm AS rust-tools
RUN rustup target add wasm32-unknown-unknown \
    && cargo install wasm-pack --version 0.13.1 --locked

FROM node:22.23.4-bookworm AS experiment-build
COPY --from=rust-tools /usr/local/cargo /usr/local/cargo
COPY --from=rust-tools /usr/local/rustup /usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/cargo/bin:$PATH NODE_ENV=production
WORKDIR /experiment
# One dependency has a GitHub SSH URL in the lockfile; fetch it over public HTTPS.
RUN git config --global url."https://github.com/".insteadOf ssh://git@github.com/
COPY docker/experiment-frontend/package.json docker/experiment-frontend/package-lock.json ./
RUN npm ci --include=dev --no-audit --no-fund
COPY docker/experiment-frontend/ ./
ARG ELICIT_DEMO_HOST=localhost
ARG ELICIT_DEMO_PORT=8080
# Configuration is a build artifact, never a bind mount or a change to the submodule.
RUN node -e 'const fs = require("fs"); const url = `http://${process.env.ELICIT_DEMO_HOST}:${process.env.ELICIT_DEMO_PORT}/`; fs.writeFileSync("source/configuration.json", JSON.stringify({PortalPath: url, ElicitLandingPath: url}));' \
    && npm run build

FROM ruby:3.4.4-slim-bookworm AS gems
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git libpq-dev libyaml-dev libffi-dev libsqlite3-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Gemfile Gemfile.lock ./
COPY gems/swagger_ui_engine gems/swagger_ui_engine
ENV BUNDLE_WITHOUT=development:test BUNDLE_FROZEN=true
RUN gem install bundler -v 2.5.22 --no-document && bundle _2.5.22_ install --jobs 4

FROM ruby:3.4.4-slim-bookworm AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libpq5 libyaml-0-2 libffi8 libsqlite3-0 libvips42 libstdc++6 libatomic1 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 elicit
COPY --from=gems /usr/local/bundle /usr/local/bundle
COPY --from=admin-build /usr/local/bin/node /usr/local/bin/node
ENV BUNDLE_WITHOUT=development:test BUNDLE_FROZEN=true RAILS_ENV=production
WORKDIR /app
COPY --chown=elicit:elicit . .
COPY --from=admin-build --chown=elicit:elicit /app/public/packs public/packs
RUN mkdir -p storage public/uploads tmp/pids log && chown -R elicit:elicit storage public/uploads tmp log
USER elicit

FROM runtime AS assets
RUN ELICIT_DEMO_DATA=/tmp/demo-build ruby docker/demo/boot.rb assets

FROM runtime AS app
COPY --from=assets --chown=elicit:elicit /app/public/assets public/assets
EXPOSE 3000
ENTRYPOINT ["ruby", "docker/demo/boot.rb"]
CMD ["web"]

FROM nginx:1.28-alpine AS experiment
COPY docker/demo/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=experiment-build /experiment/dist /usr/share/nginx/html
