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
```


