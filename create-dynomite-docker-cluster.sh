#!/bin/bash

docker stop dynomite1 ; docker rm dynomite1
docker stop dynomite2 ; docker rm dynomite2
docker stop dynomite3 ; docker rm dynomite3

docker stop dynomite21 ; docker rm dynomite21
docker stop dynomite22 ; docker rm dynomite22
docker stop dynomite23 ; docker rm dynomite23

docker network rm myDockerNetDynomite
docker network create --subnet=172.18.0.0/16 myDockerNetDynomite
docker network ls

SHARED=/usr/local/docker-shared/dynomite/:/var/lib/redis/

docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.101 --name dynomite1 -e DYNOMITE_NODE=1 diegopacheco/dynomite-v0.5.7-14
docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.102 --name dynomite2 -e DYNOMITE_NODE=2 diegopacheco/dynomite-v0.5.7-14
docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.103 --name dynomite3 -e DYNOMITE_NODE=3 diegopacheco/dynomite-v0.5.7-14

docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.201 --name dynomite21 -e DYNOMITE_NODE=21 diegopacheco/dynomite-v0.5.7-14
docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.202 --name dynomite22 -e DYNOMITE_NODE=22 diegopacheco/dynomite-v0.5.7-14
docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.203 --name dynomite23 -e DYNOMITE_NODE=23 diegopacheco/dynomite-v0.5.7-14

docker ps

mkdir /tmp/dcc ; cd /tmp/dcc/
git clone https://github.com/diegopacheco/dynomite-cluster-checker
cd dynomite-cluster-checker/dynomite-cluster-checker

seeds1="172.18.0.101:8101:rack1:dc:100|172.18.0.102:8101:rack2:dc:100|172.18.0.103:8101:rack3:dc:100"
./gradlew execute -Dexec.args="$seeds1"

seeds2="172.18.0.201:8101:rack1:dc:100|172.18.0.202:8101:rack2:dc:100|172.18.0.203:8101:rack3:dc:100"
./gradlew execute -Dexec.args="$seeds2"

docker ps

echo "Seeds - Cluster 1"
echo "$seeds1"

echo "Seeds - Cluster 2"
echo "$seeds2"




