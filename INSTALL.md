INSTALL.md



## Create the SSL certificates

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
 