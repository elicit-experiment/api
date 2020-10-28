# How to Install Elicit

Assuming you're stating with a server with Ubuntu Linux installed, here's how you install Elicit. 

## 0 Install Helpful Utilities (Optional)

```
apt install -y mosh vim

```

## 1 Install Docker

Docker instructions can be found in many places. We use the ones [here](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04) since our server is Ubuntu running in DO. Other services or your own development system will have similar instructions. The main thing is to get Docker installed.

```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker

```

Create the docker user, so you're not running everything as root:

```
adduser dockeruser
usermod -aG docker dockeruser
```


## 2 Install Docker Compose

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## 3 Install Git

```
sudo apt install git 
```

## 4 Clone the Repo

(as `dockeruser`)

````
git clone https://github.com/elicit-experiment/api.git
cd api
git submodule init
git submodule update
````

## Create the .env file

This file specifies fundamental configuration parameters for the server:

```
cat > .env
API_SCHEME=https
EXTERNAL_API_SCHEME=https
API_URL=elicit.compute.dtu.dk
ELICIT_URL=elicit.compute.dtu.dk
SITE_SUFFIX=compute.dtu.dk
POSTGRES_USER=elicit
POSTGRES_PASSWORD=<choose a safe password>
POSTGRES_DB=elicit_production
REDIS_PASSWORD=<choose a safe password>
^D 
```

| ENV Var           | Meaning |
|-------------------|------:|
| API_SCHEME          | Protocol scheme for ingress; `http` or `https` |
| EXTERNAL_API_SCHEME | Protocol scheme for external access; `http` or `https` |
| API_URL             | URL of the API service |
| SITE_SUFFIX         | Domain name suffix for the API and frontend endpoints. |
| POSTGRES_USER       | Postgres DB engine user name |
| POSTGRES_PASSWORD   | Postgres DB engine user password |
| POSTGRES_DB         | Name of postgres DB to use |
| REDIS_PASSWORD      | Password for redis |


## Build the Docker Images

```
docker-compose build
```

# Run Elicit

```
docker-compose up -d
```


# Create SSL Certificates Using Let's Encrypt

```bash
pushd /elicit
git clone https://github.com/dtu-compute/dtu-enote-letsencrypt

pushd dtu-enote-letsencrypt
docker build -t letsencrypt .
docker create -p 80:80  --name letsencrypt -v /elicit/certs:/etc/letsencrypt -t letsencrypt
docker start letsencrypt
docker exec -t letsencrypt ./make-cert.sh elicit.compute.dtu.dk
docker exec -t letsencrypt ./make-cert.sh api-elicit.compute.dtu.dk
docker exec -t letsencrypt ./make-cert.sh admin-elicit.compute.dtu.dk
docker exec -t letsencrypt ./make-cert.sh experiment-elicit.compute.dtu.dk
```


## Update SSL Certificates

```bash
docker exec -t letsencrypt ./update-certs.sh
```
 
 ```
 yes | cp -R --dereference -f ../certs/live/* certs
 ```
