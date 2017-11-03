#!/bin/bash

mac_docker_ip="192.168.99.100"

seeds1="$mac_docker_ip:32102:rack1:dc:100|$mac_docker_ip:32103:rack2:dc:100|$mac_docker_ip:32104:rack3:dc:100"
seeds2="$mac_docker_ip:32105:rack1:dc:100|$mac_docker_ip:32106:rack2:dc:100|$mac_docker_ip:32107:rack3:dc:100"
DV=$2

function setu_docker_machine(){
  curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
  chmod +x /usr/local/bin/docker-machine
  docker-machine create --driver virtualbox default
  docker-machine env default
  eval "$(docker-machine env default)"
}

function start_docker_machine(){
  docker-machine start default
  docker-machine env default
  eval "$(docker-machine env default)"
}

function stop_docker_machine(){
  docker-machine stop default
}

function setupClusters(){
  SHARED=$TMPDIR:/var/lib/redis/
  setupSingleClusters
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.201 --name dynomite21 -p 8102:32105 -e DYNOMITE_NODE=21 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.202 --name dynomite22 -p 8102:32106 -e DYNOMITE_NODE=22 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.203 --name dynomite23 -p 8102:32107 -e DYNOMITE_NODE=23 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
}

function setupSingleClusters(){
  SHARED=$TMPDIR:/var/lib/redis/
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.101 --name dynomite1 -p 8102:32102 -e DYNOMITE_NODE=1  -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.102 --name dynomite2 -p 8102:32103 -e DYNOMITE_NODE=2  -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 172.18.0.103 --name dynomite3 -p 8102:32104 -e DYNOMITE_NODE=3  -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
}

function bake(){
   docker build -t diegopacheco/dynomitedocker . --network=host
}

function cleanUp(){
  docker stop dynomite1 ; docker rm dynomite1
  docker stop dynomite2 ; docker rm dynomite2
  docker stop dynomite3 ; docker rm dynomite3

  docker stop dynomite21 ; docker rm dynomite21
  docker stop dynomite22 ; docker rm dynomite22
  docker stop dynomite23 ; docker rm dynomite23

  docker network rm myDockerNetDynomite
  echo "Docker images and Network clean up DONE."
}

function setUpNetwork(){
  docker network create --subnet=172.18.0.0/16 myDockerNetDynomite
  docker network ls
}

function getDcc(){
  mkdir $TMPDIR/dcc
  cd $TMPDIR/dcc/
  git clone https://github.com/diegopacheco/dynomite-cluster-checker > /dev/null 2>&1
  cd dynomite-cluster-checker/dynomite-cluster-checker
}

function runDcc(){
  getDcc
  ./gradlew execute -Dexec.args="$seeds1"
  ./gradlew execute -Dexec.args="$seeds2"
  docker ps
}

function runDccSingle(){
  getDcc
  ./gradlew execute -Dexec.args="$seeds1"
  docker ps
}

function run(){
    echo "$DV"
    if [[ "$DV" = *[!\ ]* ]];
    then
      cleanUp
      setUpNetwork
      setupClusters
      runDcc
      info
    else
      echo "Mising Dynomite version! Aborting! You need pass the version: 0.5.7, 0.5.8 or 0.5.9"
    fi
}

function runSingle(){
    echo "$DV"
    if [[ "$DV" = *[!\ ]* ]];
    then
      cleanUp
      setUpNetwork
      setupSingleClusters
      infoSingle
    else
      echo "Mising Dynomite version! Aborting! You need pass the version: 0.5.7, 0.5.8 or 0.5.9"
    fi
}

function infoSingle(){
  echo "Cluster 1 - Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - $mac_docker_ip:32102"
  echo "  rack2 - $mac_docker_ip:32103"
  echo "  rack3 - $mac_docker_ip:32104"
  echo "Seeds: $seeds1"
  echo ""
  echo "Avaliable Dynomite version: v0.5.7, v0.5.8 and v0.5.9"
}

function info(){
  echo "Cluster 1 - Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - $mac_docker_ip:32102"
  echo "  rack2 - $mac_docker_ip:32103"
  echo "  rack3 - $mac_docker_ip:32104"
  echo "Seeds: $seeds1"
  echo ""
  echo "Cluster 2- Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - 172.18.0.201:32105"
  echo "  rack2 - 172.18.0.202:32106"
  echo "  rack3 - 172.18.0.203:32107"
  echo "Seeds: $seeds2"
  echo ""
  echo "Avaliable Dynomite version: v0.5.7, v0.5.8 and v0.5.9"
}

function help(){
   echo "dynomite-docker: easy setup for dynomite clusters for development. Created by: Diego Pacheco."
   echo "functions: "
   echo ""
   echo "bake        : Bakes docker image"
   echo "run         : Run Dynomite docker 2 clusters for dual write"
   echo "run_single  : Run Dynomite docker Single cluster"
   echo "dcc         : Run Dynomite Cluster Checker for 2 clusters"
   echo "dcc_single  : Run Dynomite Cluster Checker for single cluster"
   echo "info        : Get Seeds, IPs and topologies"
   echo "log         : Print dynomite logs, you need pass the node number. i.e: ./dynomite-docker log 1"
   echo "cli         : Enters redis-cli on dynomite port. i.e: ./dynomite-docker cli 1"
   echo "stop        : Stop and clean up all docker running images"
   echo "help        : help documentation"
}

function log(){
  docker exec -i -t dynomite$DV cat /var/log/dynomite/dynomite_log.txt
}

function rediscli(){
  if [[ "$DV" = *[!\ ]* ]];
  then
    docker exec -it dynomite$DV redis-cli -p 8102
  else
    echo "Mising Dynomite node! Aborting! You need pass the node: 1, 2 or 3"
  fi
}

case $1 in
     "bake")
          bake
          ;;
     "run")
          run
          ;;
     "run_single")
          runSingle
          ;;
     "dcc")
          runDcc
          ;;
     "dcc_single")
          runDccSingle
          ;;
     "info")
          info
          ;;
     "log")
          log
          ;;
      "cli")
          rediscli
          ;;
     "stop")
          cleanUp
          ;;
     *)
          help
esac
