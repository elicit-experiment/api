# Base image:
# Debian Bookworm fails to find signatures for apt update on the production server so we fall back to Bullseye.
FROM ruby:3.3.6-bullseye

ARG SITE_SUFFIX
ARG API_SCHEME

ENV API_SCHEME=$API_SCHEME

RUN cat /etc/os-release

# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /var/www/Cockpit.API
RUN mkdir -p $RAILS_ROOT

# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev apt-utils libjemalloc2
ENV LD_PRELOAD="libjemalloc.so.2" \
    MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true,stats_print:true"

# Install node 22
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get -y install nodejs
RUN node --version
RUN npm --version

# Install yarn
RUN apt-get update
RUN npm install -g yarn
RUN yarn set version 3.2.2
RUN yarn --version

# Install dev conveniences
RUN apt-get install -y postgresql-client
RUN apt-get install -y vim

# Gems:
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY gems gems
RUN gem install bundler
RUN bundle install

# Node:
COPY package.json .
COPY yarn.lock .
RUN yarn install
RUN node --version

EXPOSE 3000

# Copy only the pieces needed for webpack, since it can take a long time to run this and we don't want
# extraneous changes to cause an unecessary rebuild.
RUN mkdir -p app/javascript
COPY app/javascript app/javascript
COPY config config
COPY .babelrc .
COPY .bowerrc .
COPY .postcssrc.yml .
COPY bin bin

# Copy the main application.
COPY . .
RUN mkdir log
RUN mkdir -p tmp/pids

# fake DB per https://iprog.com/posting/2013/07/errors-when-precompiling-assets-in-rails-4-0
RUN rm -rf public/assets
RUN rm -rf public/packs
RUN RAILS_ENV=production PRECOMPILE=1 DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname bundle exec rails assets:precompile
RUN ls -als public/packs

# TODO: undisable these; we can't use sqllite because of jsonb columns, so we need a postgres DB to run the tests
#RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rake db:drop
#RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rake db:create
#RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rake db:structure:load
#RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rake db:migrate
#RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rake db:setup
#RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rails test

# generate cookie key
RUN PRECOMPILE=1 bundle exec rails secret > ~/secret-key-base.txt

ENV RAILS_ENV=production
CMD ["/bin/sh", "-c", "./run-server.sh  2>&1 | tee log/run-server.log"]
