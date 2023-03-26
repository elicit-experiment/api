# Elicit Experiment

Elicit experiment is a system for creating psychological studies, presenting them to subject and gathering the results.

## Installation

Installation instructions are found [here](./INSTALL.md).

## Development

### 1. Setup Environment

Follow the instructions in [INSTALL.md](./INSTALL.md) to create a local `.env` file.

### 2. Start the Docker Dependencies

```bash
docker-compose up -d redis postgres
```

### 3. Run the Local Servers

There are 3 separate servers required: the API, the admin/participant frontend and the experiment frontend.

## Production

```bash
docker-compose --env-file .env.production.local up -d --build
```

#### API

```
bundle install
bundle exec rails s -b 0.0.0.0
```

#### Admin/Participant Frontend

```bash
bin/webpack-dev-server
```

#### Experiment Frontend

```bash
pushd docker/experiment-frontend
npm install
gulp build
gulp serve
```

### Common Development Tasks

#### Extract DB diagram

```
bundle exec erd
```

#### Nuke the DB

```bash
RAILS_ENV=development ./redb.sh

DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production ./redb.sh

docker exec api bash -e DISABLE_DATABASE_ENVIRONMENT_CHECK=1 ./redb.sh

```


* anonymous is all auto-created; with or without identifier
* registered is either a fixed set of existing users, or N registered users of any kind

#### Testing

```bash
bin/rails test 2>&1 | ggrep -P -i -C3 'error|fail'
```
