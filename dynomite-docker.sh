#!/bin/bash

seeds1="179.18.0.101:8102:rack1:dc:100|179.18.0.102:8102:rack2:dc:100|179.18.0.103:8102:rack3:dc:100"
seeds2="179.18.0.201:8102:rack1:dc:100|179.18.0.202:8102:rack2:dc:100|179.18.0.203:8102:rack3:dc:100"
DV=$2

export EC2_AVAILABILTY_ZONE=rack1

function bake(){
   docker build -t diegopacheco/dynomitedocker . --network=host
}

function cleanUp(){
  docker stop dynomite1 > /dev/null 2>&1 ; docker rm dynomite1 > /dev/null 2>&1
  docker stop dynomite2 > /dev/null 2>&1 ; docker rm dynomite2 > /dev/null 2>&1
  docker stop dynomite3 > /dev/null 2>&1 ; docker rm dynomite3 > /dev/null 2>&1

  docker stop dynomite21 &>/dev/null ; docker rm dynomite21 > /dev/null 2>&1
  docker stop dynomite22 &>/dev/null ; docker rm dynomite22 > /dev/null 2>&1
  docker stop dynomite23 &>/dev/null ; docker rm dynomite23 > /dev/null 2>&1

  docker network rm myDockerNetDynomite > /dev/null 2>&1
  echo "Docker images and Network clean up DONE."
}

function setUpNetwork(){
  docker network create --subnet=179.18.0.0/16 myDockerNetDynomite
  docker network ls
}

function setupClusters(){
  SHARED=/usr/local/docker-shared/dynomite/:/var/lib/redis/
  setupSingleClusters
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.201 --name dynomite21 -e DYNOMITE_NODE=21 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.202 --name dynomite22 -e DYNOMITE_NODE=22 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.203 --name dynomite23 -e DYNOMITE_NODE=23 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
}

function setupSingleClusters(){
  SHARED=/usr/local/docker-shared/dynomite/:/var/lib/redis/
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.101 --name dynomite1 -e DYNOMITE_NODE=1 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.102 --name dynomite2 -e DYNOMITE_NODE=2 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.103 --name dynomite3 -e DYNOMITE_NODE=3 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
}

function getDcc(){
  mkdir /tmp/dcc > /dev/null 2>&1
  cd /tmp/dcc/
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
      echo "Mising Dynomite version! Aborting! You need pass the version: 0.5.7, 0.5.8, 0.5.9, 0.6.0"
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
      echo "Mising Dynomite version! Aborting! You need pass the version: 0.5.7, 0.5.8, 0.5.9, 0.6.0"
    fi
}

function infoSingle(){
  echo "Cluster 1 - Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - 179.18.0.101"
  echo "  rack2 - 179.18.0.102"
  echo "  rack3 - 179.18.0.103"
  echo "Seeds: $seeds1"
  echo ""
  echo "Avaliable Dynomite version: v0.5.7, v0.5.8, v0.5.9, v0.6.0"
}

function info(){
  echo "Cluster 1 - Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - 179.18.0.101"
  echo "  rack2 - 179.18.0.102"
  echo "  rack3 - 179.18.0.103"
  echo "Seeds: $seeds1"
  echo ""
  echo "Cluster 2- Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - 179.18.0.201"
  echo "  rack2 - 179.18.0.202"
  echo "  rack3 - 179.18.0.203"
  echo "Seeds: $seeds2"
  echo ""
  echo "Avaliable Dynomite version: v0.5.7, v0.5.8, v0.5.9, v0.6.0"
}

function help(){
   echo " "
   echo "    #                                \"      m                      #                #                             "
   echo "mmmm#  m   m  m mm    mmm   mmmmm  mmm    mm#mm   mmm           mmm#   mmm    mmm   #  m   mmm     m mm         "
   echo "#\" \"#  \"m m\"  #\"  #  #\" \"#  # # #    #      #    #\"  #         #\" \"#  #\" \"#  #\"  \"  # m\"   #\"  #   #\""
   echo "#   #   #m#   #   #  #   #  # # #    #      #    #\"\"\"\"   \"\"\"   #   #  #   #  #      #\"#    #\"\"\"\"   #     "
   echo "\"#m##   \"#    #   #  \"#m#\"  # # #  mm#mm    \"mm  \"#mm\"         \"#m##  \"#m#\"  \"#mm\"  #  \"m  \"#mm\"   #  "
   echo " "
   
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
