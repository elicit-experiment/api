# Cockpit API
Ruby on Rails Web API for Cockpit experiments. 
- Can send POST requests to localhost:3000/experiments by using JSON, XML or plain HTML
- Can send GET requests to localhost:3000/experiments, /experiments.json, or /experiments.xml to see all experiments in the specified format
- Models, Views and Controllers can be found in separate folders in `/Cockpit_API/app/`

#Requirements:
- Ruby version 2.3.0
- Rails version 5.0.1 (not backward compatible with previous versions)
- SQL server running(I used XAMPP MySQL) as per `/Cockpit_API/config/database.yml`
** remember to change username, password, host, socket, database_name to values used in SQL server

#How to run:
- change directory to Cockpit_API: `cd /Cockpit_API/`
- run bundle to install dependencies: `bundle`
- start the webserver (default localhost:3000): `rails server`

#To do list(incomplete):
- find out how to communicate with the UI/Typescript server
- add the remaining models (based on the wanted database structure)
- add security


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
