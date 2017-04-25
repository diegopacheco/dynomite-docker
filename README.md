# dynomite-docker
Simple Docker Image for Dynomite. 

## How to use it?
```bash
1. Download and instal Java 8
2. Download and install Docker.
3. Bake docker images $ ./bake_docker.sh
3. Create the Dynomite clusters $ ./create-dynomite-docker-cluster.sh
```

## How it works? 
1. We bake a docker image with Dynomiete v0.5.7-14 and Redis 3.x.
2. We create 2 clusters - each cluster has 3 nodes.
3. In the end of the script(create-dynomite-docker-cluster.sh) you will see all seeds(We also run Dynomite Cluster Checker)
4. You just need run bake_docker.sh 1 time.
5. You can run create-dynomite-docker-cluster.sh as many times as you want. First thing on the script we delete old docker images and old docker network - so we create new docker images and network everything you the script create-dynomite-docker-cluster.sh. 

## What are my seeds?

Cluster 1
```bash
172.18.0.101:8101:rack1:dc:100|172.18.0.102:8101:rack2:dc:100|172.18.0.103:8101:rack3:dc:100
```
Cluster 2
```bash
172.18.0.201:8101:rack1:dc:100|172.18.0.202:8101:rack2:dc:100|172.18.0.203:8101:rack3:dc:100
```

## Integrated with DCC checks. 

This scritps will run DCC(https://github.com/diegopacheco/dynomite-cluster-checker). You should see something like this.

```bash
**** BEGIN DYNOMITE CLUSTER CHECKER ****
1. Checking cluster connection... 
    OK - All nodes are accessible! 
2. Checking cluster data replication... 
SEEDS: [172.18.0.101:8101:rack1:dc:100, 172.18.0.102:8101:rack2:dc:100, 172.18.0.103:8101:rack3:dc:100]
Checking Node: 172.18.0.101
  TIME to   Insert DCC_dynomite_123_kt - Value: DCC_replication_works: 6.0 ms - 0 s
  TIME to   Get: DCC_dynomite_123_kt : 4.0 ms - 0 s
  200 OK - set/get working fine!
Checking Node: 172.18.0.102
  TIME to   Get: DCC_dynomite_123_kt : 3.0 ms - 0 s
  200 OK - set/get working fine!
Checking Node: 172.18.0.103
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
    "server":"172.18.0.101",
    "seeds":"[172.18.0.101:8101:rack1:dc:100, 172.18.0.102:8101:rack2:dc:100, 172.18.0.103:8101:rack3:dc:100]",
    "insertTime":"6.0 ms",
    "getTime":"4.0 ms",
    "consistency":"true"
  },
  {
    "server":"172.18.0.102",
    "getTime":"3.0 ms",
    "consistency":"true"
  },
  {
    "server":"172.18.0.103",
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
SEEDS: [172.18.0.201:8101:rack1:dc:100, 172.18.0.202:8101:rack2:dc:100, 172.18.0.203:8101:rack3:dc:100]
Checking Node: 172.18.0.201
  TIME to   Insert DCC_dynomite_123_kt - Value: DCC_replication_works: 5.0 ms - 0 s
  TIME to   Get: DCC_dynomite_123_kt : 2.0 ms - 0 s
  200 OK - set/get working fine!
Checking Node: 172.18.0.202
  TIME to   Get: DCC_dynomite_123_kt : 2.0 ms - 0 s
  200 OK - set/get working fine!
Checking Node: 172.18.0.203
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
    "server":"172.18.0.201",
    "seeds":"[172.18.0.201:8101:rack1:dc:100, 172.18.0.202:8101:rack2:dc:100, 172.18.0.203:8101:rack3:dc:100]",
    "insertTime":"5.0 ms",
    "getTime":"2.0 ms",
    "consistency":"true"                                                                  },

  {
    "server":"172.18.0.202",
    "getTime":"2.0 ms",
    "consistency":"true"
  },
  {
    "server":"172.18.0.203",
    "getTime":"2.0 ms",
    "consistency":"true"
  }
]
}


**** END DYNOMITE CLUSTER CHECKER ****
```

