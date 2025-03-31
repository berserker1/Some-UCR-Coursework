#!/bin/bash
PORT="$1"
cd ~/
mkdir server_persistent_storage
cp ass2/mydata.txt server_persistent_storage/
cd ass2
echo "The Port which is going to be served for server is $PORT"
sudo docker container prune -f
sudo docker network prune -f
sudo docker network create --driver bridge ass2_network_server
sudo docker network create --driver bridge ass2_network_client
sudo docker build -t assignment2_server .
sudo docker run --name server_container -p $PORT:$PORT -e PORT_VAR=$PORT -d --network ass2_network_server --mount type=bind,src=/users/abhag017/server_persistent_storage,dst=/usr/src/assignment2_server/server_storage assignment2_server $PORT server_storage/mydata.txt