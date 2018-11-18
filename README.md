## Running Docker

### 1. Set Environment

```bash
export $(grep -v '^#' .env-local | xargs)
```

OR

```bash
ln -s .env-local .env
```

(`.env` will automatically be picked up by `docker-compose`)

### 2. Build Docker

```bash
docker-compose build
```

### 2. Run Docker

```bash
docker-compose up -d
```

## Generating test files


### Experiments

```
guid=a9f56a58-aaaa-eeee-1355-012345678901
guid=a9f56a58-aaaa-eeee-1355-012345678904
guid=a9f56a58-aaaa-eeee-1355-012345678902
guid=a9f56a58-aaaa-eeee-1355-012345678903
guid=a9f56a58-aaaa-eeee-1355-012345678905

curl "https://dev-api.cosound.dk/v6/Experiment/Get?id=${guid}&format=json2&userHTTPStatusCodes=False" -H 'Origin: http://localhost:5504' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36' -H 'Accept: */*' -H 'Referer: http://localhost:5504/' -H 'Connection: keep-alive' --compressed > test/fixtures/files/production_examples/experiment_${guid}.json
```

### Questions

```
guid=a9f56a58-aaaa-eeee-1355-012345678901
guid=a9f56a58-aaaa-eeee-1355-012345678904
guid=a9f56a58-aaaa-eeee-1355-012345678902
guid=a9f56a58-aaaa-eeee-1355-012345678903
guid=a9f56a58-aaaa-eeee-1355-012345678905
i=2
echo "https://dev-api.cosound.dk/v6/Question/Get?id=${guid}&index=${i}&format=json3&userHTTPStatusCodes=False"
curl "https://dev-api.cosound.dk/v6/Question/Get?id=${guid}&index=${i}&format=json3&userHTTPStatusCodes=False" -H 'Origin: http://localhost:5504' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36' -H 'Accept: */*' -H 'Referer: http://localhost:5504/' -H 'Connection: keep-alive' --compressed > test/fixtures/files/production_examples/questions_${guid}_${i}.json
```


# Design

## Extract DB diagram

```
bundle exec erd
```

# Common Tasks

## Nuke the DB

```bash
RAILS_ENV=development ./redb.sh

DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production ./redb.sh
```


