ssh -i /path/to/your/private/key docker@<public-ip-of-docker-master>

docker info

docker node ls

docker service ls

docker service create --name nginx --publish published=80,target=80 nginxdemos/hello

docker ps

docker service ls

docker service update --replicas 2 nginx

docker service ls
