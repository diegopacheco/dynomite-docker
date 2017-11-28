#!/bin/bash

seeds1="179.18.0.101:8102:rack1:dc:100|179.18.0.102:8102:rack2:dc:100|179.18.0.103:8102:rack3:dc:100"
seeds2="179.18.0.201:8102:rack1:dc:100|179.18.0.202:8102:rack2:dc:100|179.18.0.203:8102:rack3:dc:100"
seedsShard1="179.18.0.101:8102:rack1:dc:100|179.18.0.102:8102:rack2:dc:100|179.18.0.103:8102:rack3:dc:100|179.18.0.104:8102:rack4:dc:200|179.18.0.105:8102:rack5:dc:200|179.18.0.106:8102:rack6:dc:200"
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

function setupShardCluster(){
  SHARED=/usr/local/docker-shared/dynomite/:/var/lib/redis/
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.101 --name dynomite1 -e DYNOMITE_NODE=6S1 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.102 --name dynomite2 -e DYNOMITE_NODE=6S2 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.103 --name dynomite3 -e DYNOMITE_NODE=6S3 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.104 --name dynomite4 -e DYNOMITE_NODE=6S4 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.105 --name dynomite5 -e DYNOMITE_NODE=6S5 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.106 --name dynomite6 -e DYNOMITE_NODE=6S6 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
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

function runDccShard(){
  getDcc
  ./gradlew execute -Dexec.args="$seedsShard1"
  docker ps
}

function runShard(){
    echo "$DV"
    if [[ "$DV" = *[!\ ]* ]];
    then
      cleanUp
      setUpNetwork
      setupShardCluster
      runDccShard
      infoShard
    else
      missingVerion
    fi
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
      missingVerion
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
      missingVerion
    fi
}

function missingVerion(){
  echo "Mising Dynomite version! Aborting! You need pass the version: 0.5.7, 0.5.8, 0.5.9, 0.6.0"
}

function avaliableVersions(){
  echo "Avaliable Dynomite version: v0.5.7, v0.5.8, v0.5.9, v0.6.0"
}

function infoShard(){
  echo "Cluster 3 Shard - Topology :"
  echo "dc: dc"
  echo " token: 100"
  echo "  rack1 - 179.18.0.101"
  echo "  rack2 - 179.18.0.102"
  echo "  rack3 - 179.18.0.103"
  echo " token: 200"
  echo "  rack4 - 179.18.0.104"
  echo "  rack5 - 179.18.0.105"
  echo "  rack6 - 179.18.0.106"
  echo "Seeds: $seedsShard1"
  echo ""
  avaliableVersions
}

function infoSingle(){
  echo "Cluster 2 Single - Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - 179.18.0.101"
  echo "  rack2 - 179.18.0.102"
  echo "  rack3 - 179.18.0.103"
  echo "Seeds: $seeds1"
  echo ""
  avaliableVersions
}

function info(){
  echo "Cluster 1A - Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - 179.18.0.101"
  echo "  rack2 - 179.18.0.102"
  echo "  rack3 - 179.18.0.103"
  echo "Seeds: $seeds1"
  echo ""
  echo "Cluster 1B - Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - 179.18.0.201"
  echo "  rack2 - 179.18.0.202"
  echo "  rack3 - 179.18.0.203"
  echo "Seeds: $seeds2"
  echo ""
  infoSingle
  infoShard
  avaliableVersions
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
   echo "run_shard   : Run Dynomite docker Shard cluster"
   echo "dcc         : Run Dynomite Cluster Checker for 2 clusters"
   echo "dcc_single  : Run Dynomite Cluster Checker for single cluster"
   echo "dcc_shard   : Run Dynomite Cluster Checker for shard cluster"
   echo "info        : Get Seeds, IPs and topologies(all 3 possible clusters)"
   echo "log         : Print dynomite logs, you need pass the node number. i.e: ./dynomite-docker log 1"
   echo "cli         : Enters redis-cli on dynomite port. i.e: ./dynomite-docker cli 1"
   echo "keys_shard  : Runs KEYS * command in all nodes(Shard Cluster)"
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

function keys_shard(){
  for i in `seq 1 6`;
  do
    echo "Node 179.18.0.10$i"
    docker exec -it dynomite$i sh -c 'echo "keys *" | redis-cli -p 8102'
  done
}

case $1 in
     "bake")
          bake
          ;;
     "run")
          run
          ;;
     "run_shard")
          runShard
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
     "dcc_single")
          runDccShard
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
      "keys_shard")
          keys_shard
          ;;
     "stop")
          cleanUp
          ;;
     *)
          help
esac
