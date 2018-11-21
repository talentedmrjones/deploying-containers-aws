
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
docker info

# install self-signed certificate
# this is OK for EC2 <-> ELB
# this is NOT OK for EC2 <-> Anything else!
openssl req -x509 -newkey rsa:4096 -keyout server-key.pem -out server-cert.pem -days 365 -nodes -sha256

# openssl genrsa -aes256 -out ca-key.pem 4096
# openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
# openssl genrsa -out server-key.pem 4096
# openssl req -subj "/CN=docker.cerulean.systems" -sha256 -new -key server-key.pem -out server.csr
# echo subjectAltName = DNS:docker.cerulean.systems,IP:13.58.175.120 >> extfile.cnf
# echo extendedKeyUsage = clientAuth >> extfile.cnf
# openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf

docker run --entrypoint htpasswd registry:2 -Bbn admin password >> ./htpasswd

docker run -d \
  --restart=always \
  --name registry \
  -v `pwd`:/conf \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/conf/server-cert.pem \
  -e REGISTRY_HTTP_TLS_KEY=/conf/server-key.pem \
	-e REGISTRY_AUTH=htpasswd \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/conf/htpasswd \
  -p 443:443 \
  registry:2

# on local
docker pull nginxdemos/hello
docker login -u admin -p password docker.cerulean.systems
docker tag nginxdemos/hello docker.cerulean.systems/hello
docker push docker.cerulean.systems/hello
curl --user admin:password -X GET https://docker.cerulean.systems/v2/_catalog
