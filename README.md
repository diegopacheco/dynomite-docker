# dynomite-docker

Simple Docker Image for Dynomite. Dynomite-docker provides utilities to create clusters(3 node cluster), get seeds, test cluster health and replication via DCC.

## Linux: How to use it? (native)

1. Download and instal Java 8  -> http://www.oracle.com/technetwork/java/javase/downloads/index.html
2. Download and install Docker. -> https://docs.docker.com/engine/installation/
3. Bake docker images $ ./dynomite-docker.sh bake
3. Create the Dynomite clusters $ ./dynomite-docker.sh run_single 0.5.8

## Windows/Mac: How to use it?

#### (MAC) Docker (Require changes on bash script)

1. Install docker -> https://docs.docker.com/docker-for-mac/install/
2. (just 1 time) Bake docker images $ sudo ./dynomite-docker-mac.sh bake
3. Create the Dynomite clusters $ sudo ./dynomite-docker-mac.sh run_single 0.5.8

#### Vagrant (native)

1. Download and instal Virtual Box 5 -> https://www.virtualbox.org/wiki/Downloads
2. Download and install Vagrant -> https://www.vagrantup.com/downloads.html
3. vagrant up
4. vagrant ssh
5. Create the Dynomite clusters $ cd dynomite-docker/ && sudo ./dynomite-docker.sh run_single 0.5.8

### What about my data?

You can dump from ypou production cluster and import it with redis-cli and redis-dump. <br>
More information here: https://gist.github.com/diegopacheco/6c1862553a8b35a2680f914a2e08accc

## What dynomite versions are suppoorted?

* 0.5.7-14 <BR>
* 0.5.8-5  <BR>
* 0.5.9-2  <BR>
* 0.6.0    <BR>

## What parameters can I use?
```bash
$ ./dynomite-docker.sh help
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
```

## How it works?

1. We bake a docker image with Dynomiete v0.5.X and Redis 3.x.
2. We create 2 clusters - each cluster has 3 nodes.
3. In the end of the script(./dynomite-docker.sh run DYNOMITE_VERSION) you will see all seeds(We also run Dynomite Cluster Checker)
4. You just need run ./dynomite-docker.sh bake 1 time.
5. You can run ./dynomite-docker.sh run as many times as you want. First thing on the script we delete old docker images and old docker network - so we create new docker images and network every time you run the script create-dynomite-docker-cluster.sh.

## What are my seeds?

Cluster 1A
```bash
179.18.0.101:8101:rack1:dc:100|179.18.0.102:8101:rack2:dc:100|179.18.0.103:8101:rack3:dc:100
```
Cluster 1B
```bash
179.18.0.201:8101:rack1:dc:100|179.18.0.202:8101:rack2:dc:100|179.18.0.203:8101:rack3:dc:100
```

Cluster 2 - Single
```bash
179.18.0.101:8101:rack1:dc:100|179.18.0.102:8101:rack2:dc:100|179.18.0.103:8101:rack3:dc:100
```

Cluster 3 - Shard
```bash
179.18.0.101:8102:rack1:dc:1383429731|179.18.0.102:8102:rack2:dc:1383429731|179.18.0.103:8102:rack3:dc:1383429731|179.18.0.104:8102:rack1:dc:2815085496|179.18.0.105:8102:rack2:dc:2815085496|179.18.0.106:8102:rack3:dc:2815085496
```

## What's is the cluster Topology?

## Summary

Cluster 1(1A and 1B): This cluster is create by command run        - This is ideal for Dual write tests. <BR/>
Cluster 2(Single)   : This cluster is create by command run_single - This is ideal dev tests. <BR/>
Cluster 3(Shard)    : This cluster is create by command run_shard  - This is ideal dev sharding keys tests. <BR/>

## Topologies

Cluster 1A
```bash
node: 1 - ip: 179.18.0.101 - Tokens: 100 - Rack: rack1 - DC: dc
node: 2 - ip: 179.18.0.102 - Tokens: 100 - Rack: rack2 - DC: dc
node: 3 - ip: 179.18.0.103 - Tokens: 100 - Rack: rack3 - DC: dc
```

Cluster 1B
```bash
node: 1 - ip: 179.18.0.201 - Tokens: 100 - Rack: rack1 - DC: dc
node: 2 - ip: 179.18.0.202 - Tokens: 100 - Rack: rack2 - DC: dc
node: 3 - ip: 179.18.0.203 - Tokens: 100 - Rack: rack3 - DC: dc
```

Cluster 2 - Single
```bash
node: 1 - ip: 179.18.0.101 - Tokens: 100 - Rack: rack1 - DC: dc
node: 2 - ip: 179.18.0.102 - Tokens: 100 - Rack: rack2 - DC: dc
node: 3 - ip: 179.18.0.103 - Tokens: 100 - Rack: rack3 - DC: dc
```

Cluster 3 - Shard
```bash
node: 1 - ip: 179.18.0.101 - Tokens: 1383429731 - Rack: rack1 - DC: dc
node: 2 - ip: 179.18.0.102 - Tokens: 1383429731 - Rack: rack2 - DC: dc
node: 3 - ip: 179.18.0.103 - Tokens: 1383429731 - Rack: rack3 - DC: dc
node: 4 - ip: 179.18.0.104 - Tokens: 2815085496 - Rack: rack1 - DC: dc
node: 5 - ip: 179.18.0.105 - Tokens: 2815085496 - Rack: rack2 - DC: dc
node: 6 - ip: 179.18.0.106 - Tokens: 2815085496 - Rack: rack3 - DC: dc
```

```

## Integrated with DCC checks.

This scritps will run DCC(https://github.com/diegopacheco/dynomite-cluster-checker). You should see something like this.

```bash
**** BEGIN DYNOMITE CLUSTER CHECKER ****
1. Checking cluster connection...
    OK - All nodes are accessible!
2. Checking cluster data replication...
SEEDS: [179.18.0.101:8101:rack1:dc:100, 179.18.0.102:8101:rack2:dc:100, 179.18.0.103:8101:rack3:dc:100]
Checking Node: 179.18.0.101
  TIME to   Insert DCC_dynomite_123_kt - Value: DCC_replication_works: 6.0 ms - 0 s
  TIME to   Get: DCC_dynomite_123_kt : 4.0 ms - 0 s
  200 OK - set/get working fine!
Checking Node: 179.18.0.102
  TIME to   Get: DCC_dynomite_123_kt : 3.0 ms - 0 s
  200 OK - set/get working fine!
Checking Node: 179.18.0.103
  TIME to   Get: DCC_dynomite_123_kt : 3.0 ms - 0 s
  200 OK - set/get working fine!
3. Checking cluster failover...
All Seeds Cluster Failover test: OK
4. Results as JSON...
{
 "timeToRun": "3 seconds",
 "failoverStatus": "OK",
 "badNodes": [],
 "nodesReport":
[
  {
    "server":"179.18.0.101",
    "seeds":"[179.18.0.101:8101:rack1:dc:100, 179.18.0.102:8101:rack2:dc:100, 179.18.0.103:8101:rack3:dc:100]",
    "insertTime":"6.0 ms",
    "getTime":"4.0 ms",
    "consistency":"true"
  },
  {
    "server":"179.18.0.102",
    "getTime":"3.0 ms",
    "consistency":"true"
  },
  {
    "server":"179.18.0.103",
    "getTime":"3.0 ms",
    "consistency":"true"
  }
]
}

**** END DYNOMITE CLUSTER CHECKER ****
```

```bash
**** BEGIN DYNOMITE CLUSTER CHECKER ****

1. Checking cluster connection...
    OK - All nodes are accessible!
2. Checking cluster data replication...
SEEDS: [179.18.0.201:8101:rack1:dc:100, 179.18.0.202:8101:rack2:dc:100, 179.18.0.203:8101:rack3:dc:100]
Checking Node: 179.18.0.201
  TIME to   Insert DCC_dynomite_123_kt - Value: DCC_replication_works: 5.0 ms - 0 s
  TIME to   Get: DCC_dynomite_123_kt : 2.0 ms - 0 s
  200 OK - set/get working fine!
Checking Node: 179.18.0.202
  TIME to   Get: DCC_dynomite_123_kt : 2.0 ms - 0 s
  200 OK - set/get working fine!
Checking Node: 179.18.0.203
  TIME to   Get: DCC_dynomite_123_kt : 2.0 ms - 0 s
  200 OK - set/get working fine!
3. Checking cluster failover...
All Seeds Cluster Failover test: OK
4. Results as JSON...
{
 "timeToRun": "2 seconds",
 "failoverStatus": "OK",
 "badNodes": [],
 "nodesReport":
[
  {
    "server":"179.18.0.201",
    "seeds":"[179.18.0.201:8101:rack1:dc:100, 179.18.0.202:8101:rack2:dc:100, 179.18.0.203:8101:rack3:dc:100]",
    "insertTime":"5.0 ms",
    "getTime":"2.0 ms",
    "consistency":"true"                                                                  },

  {
    "server":"179.18.0.202",
    "getTime":"2.0 ms",
    "consistency":"true"
  },
  {
    "server":"179.18.0.203",
    "getTime":"2.0 ms",
    "consistency":"true"
  }
]
}


**** END DYNOMITE CLUSTER CHECKER ****
```
