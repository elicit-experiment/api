# Base image:
FROM ruby:2.3.4

ARG SITE_SUFFIX
 
RUN cat /etc/os-release

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Install node 8
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -y install nodejs
RUN node --version
rUN npm --version

# Install arn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install yarn

# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /var/www/Cockpit.API
RUN mkdir -p $RAILS_ROOT
 
# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT
 
# Gems:
COPY Gemfile Gemfile
RUN gem install bundler
RUN bundle install

# Node:
COPY package.json .
RUN npm install
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
#RUN bundle exec rails webpacker:install

#RUN RAILS_ENV=production bin/webpack

# Copy the main application.
COPY . .

# fake DB per https://iprog.com/posting/2013/07/errors-when-precompiling-assets-in-rails-4-0
RUN RAILS_ENV=production PRECOMPILE=1 DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname bundle exec rake assets:precompile

RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rake db:drop
RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rake db:create
RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rake db:setup
RUN RAILS_ENV=test PRECOMPILE=1 bundle exec rails test

# generate cookie key
RUN PRECOMPILE=1 bundle exec rake secret > ~/secret-key-base.txt

CMD ["/bin/sh", "-c", "./run-server.sh  2>&1 | tee log/run-server.log"]
