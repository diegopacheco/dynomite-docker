#!/bin/bash

#mac_docker_ip="192.168.99.100"
#mac_docker_ip="192.168.65.0"
#mac_docker_ip="0.0.0.0"
mac_docker_ip="localhost"

mac_dir=/Users/dynomite_docker/

seeds1="$mac_docker_ip:32102:rack1:dc:100|$mac_docker_ip:32103:rack2:dc:100|$mac_docker_ip:32104:rack3:dc:100"
seeds2="$mac_docker_ip:32105:rack1:dc:100|$mac_docker_ip:32106:rack2:dc:100|$mac_docker_ip:32107:rack3:dc:100"
seedsShard1="$mac_docker_ip:32105:rack1:dc:1383429731|$mac_docker_ip:32106:rack2:dc:1383429731|$mac_docker_ip:32107:rack3:dc:1383429731|$mac_docker_ip:32108:rack1:dc:2815085496|$mac_docker_ip:32109:rack2:dc:2815085496|$mac_docker_ip:32110:rack3:dc:2815085496"
DV=$2

export EC2_AVAILABILTY_ZONE=rack1

function setupShardCluster(){
  SHARED="$mac_dir/dynomite-shard-redis-1/:/var/lib/redis/"
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.101 --name dynomite1 -p 32105:8102 -e DYNOMITE_NODE=6S1 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker

  SHARED="$mac_dir/dynomite-shard-redis-2/:/var/lib/redis/"
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.102 --name dynomite2 -p 32106:8102 -e DYNOMITE_NODE=6S2 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker

  SHARED="$mac_dir/dynomite-shard-redis-3/:/var/lib/redis/"
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.103 --name dynomite3 -p 32107:8102 -e DYNOMITE_NODE=6S3 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker

  SHARED="$mac_dir/dynomite-shard-redis-4/:/var/lib/redis/"
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.104 --name dynomite4 -p 32108:8102 -e DYNOMITE_NODE=6S4 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker

  SHARED="$mac_dir/dynomite-shard-redis-5/:/var/lib/redis/"
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.105 --name dynomite5 -p 32109:8102 -e DYNOMITE_NODE=6S5 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker

  SHARED="$mac_dir/dynomite-shard-redis-6/:/var/lib/redis/"
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.106 --name dynomite6 -p 32110:8102 -e DYNOMITE_NODE=6S6 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
}

function setupClusters(){
  SHARED="$mac_dir/redis/:/var/lib/redis/"
  setupSingleClusters
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.201 --name dynomite21 -p 32105:8102 -e DYNOMITE_NODE=21 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.202 --name dynomite22 -p 32106:8102 -e DYNOMITE_NODE=22 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.203 --name dynomite23 -p 32107:8102 -e DYNOMITE_NODE=23 -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
}

function setupSingleClusters(){
  SHARED="$mac_dir/redis/:/var/lib/redis/"
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.101 --name dynomite1 -p 32102:8102 -e DYNOMITE_NODE=1  -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.102 --name dynomite2 -p 32103:8102 -e DYNOMITE_NODE=2  -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
  docker run -d -v $SHARED --net myDockerNetDynomite --ip 179.18.0.103 --name dynomite3 -p 32104:8102 -e DYNOMITE_NODE=3  -e DYNOMITE_VERSION=$DV diegopacheco/dynomitedocker
}

function bake(){
   sudo mkdir $mac_dir
   sudo mkdir $mac_dir/redis/
   sudo mkdir $mac_dir/dcc/
   for i in `seq 1 6`;
   do
      sudo mkdir $mac_dir/dynomite-shard-redis-$i/
   done
   docker build -t diegopacheco/dynomitedocker . --network=host
}

function cleanUp(){
  docker stop dynomite1 ; docker rm dynomite1
  docker stop dynomite2 ; docker rm dynomite2
  docker stop dynomite3 ; docker rm dynomite3

  docker stop dynomite21 ; docker rm dynomite21
  docker stop dynomite22 ; docker rm dynomite22
  docker stop dynomite23 ; docker rm dynomite23

  docker stop dynomite4 ; docker rm dynomite4
  docker stop dynomite5 ; docker rm dynomite5
  docker stop dynomite6 ; docker rm dynomite6

  docker network rm myDockerNetDynomite
  echo "Docker images and Network clean up DONE."
}

function setUpNetwork(){
  docker network create --subnet=179.18.0.0/16 myDockerNetDynomite
  docker network ls
}

function getDcc(){
  cd $mac_dir/dcc/
  git clone https://github.com/diegopacheco/dynomite-cluster-checker
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

function missingVerion(){
  echo "Mising Dynomite version! Aborting! You need pass the version: 0.5.7, 0.5.8, 0.5.9, 0.6.0"
}

function avaliableVersions(){
  echo "Avaliable Dynomite version: v0.5.7, v0.5.8, v0.5.9, v0.6.0"
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

function infoShard(){
  echo "Cluster 3 Shard - Topology :"
  echo "dc: dc"
  echo " token: 1383429731"
  echo "  rack1 - 179.18.0.101"
  echo "  rack2 - 179.18.0.102"
  echo "  rack3 - 179.18.0.103"
  echo " token: 2815085496"
  echo "  rack1 - 179.18.0.104"
  echo "  rack2 - 179.18.0.105"
  echo "  rack3 - 179.18.0.106"
  echo "Seeds: $seedsShard1"
  echo ""
  avaliableVersions
}

function infoSingle(){
  echo "Cluster 2 - Single Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - $mac_docker_ip:32102"
  echo "  rack2 - $mac_docker_ip:32103"
  echo "  rack3 - $mac_docker_ip:32104"
  echo "Seeds: $seeds1"
  echo ""
  avaliableVersions
}

function info(){
  echo "Cluster 1A - Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - $mac_docker_ip:32102"
  echo "  rack2 - $mac_docker_ip:32103"
  echo "  rack3 - $mac_docker_ip:32104"
  echo "Seeds: $seeds1"
  echo ""
  echo "Cluster 1B- Topology :"
  echo "token: 100 dc: dc"
  echo "  rack1 - 179.18.0.201:32105"
  echo "  rack2 - 179.18.0.202:32106"
  echo "  rack3 - 179.18.0.203:32107"
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
   echo "keys_single : Runs KEYS * command in all nodes(Single Cluster)"
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
    docker exec -it dynomite$i sh -c 'echo "keys *" | redis-cli -p 6379'
  done
}

function keys_single(){
  for i in `seq 1 3`;
  do
    echo "Node 179.18.0.10$i"
    docker exec -it dynomite$i sh -c 'echo "keys *" | redis-cli -p 6379'
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
      "keys_single")
          keys_single
          ;;
      "stop")
          cleanUp
          ;;
      *)
          help
esac
