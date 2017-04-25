# dynomite-docker
Simple Docker Image for Dynomite. 

## How to use it?
```bash
1. Download and install Docker.
2. Bake docker images $ ./bake_docker.sh
3. Create the Dynomite clusters $ ./create-dynomite-docker-cluster.sh
```

## How it works? 
```bash
1. We bake a docker image with Dynomiete v0.5.7-14 and Redis 3.x.
2. We create 2 clusters - each cluster has 3 nodes.
3. In the end of the first script you will see all seeds(We also run Dynomite Cluster Checker)
```
```bash
CONTAINER ID        IMAGE                             COMMAND                  CREATED              STATUS              PORTS                                NAMES
3e273393eb11        diegopacheco/dynomite-v0.5.7-14   "/usr/local/dynomi..."   54 seconds ago       Up 53 seconds       6379/tcp, 8101-8102/tcp, 22222/tcp   dynomite23
d6835259bbc8        diegopacheco/dynomite-v0.5.7-14   "/usr/local/dynomi..."   55 seconds ago       Up 54 seconds       6379/tcp, 8101-8102/tcp, 22222/tcp   dynomite22
330769ed7657        diegopacheco/dynomite-v0.5.7-14   "/usr/local/dynomi..."   57 seconds ago       Up 55 seconds       6379/tcp, 8101-8102/tcp, 22222/tcp   dynomite21
bf7ea7eed165        diegopacheco/dynomite-v0.5.7-14   "/usr/local/dynomi..."   About a minute ago   Up 57 seconds       6379/tcp, 8101-8102/tcp, 22222/tcp   dynomite3
c702a236d536        diegopacheco/dynomite-v0.5.7-14   "/usr/local/dynomi..."   About a minute ago   Up About a minute   6379/tcp, 8101-8102/tcp, 22222/tcp   dynomite2
b560579787bc        diegopacheco/dynomite-v0.5.7-14   "/usr/local/dynomi..."   About a minute ago   Up About a minute   6379/tcp, 8101-8102/tcp, 22222/tcp   dynomite1
Seeds - Cluster 1
172.18.0.101:8101:rack1:dc:100|172.18.0.102:8101:rack2:dc:100|172.18.0.103:8101:rack3:dc:100
Seeds - Cluster 2
172.18.0.201:8101:rack1:dc:100|172.18.0.202:8101:rack2:dc:100|172.18.0.203:8101:rack3:dc:100
```
