#!/bin/bash
PORT="$1"
rm -rf ../client_persistent_storage
cd ~/
mkdir client_persistent_storage
# cp ass2/mydata.txt client_persistent_storage/
cd ass2
echo "The Port which is going to be served for server is $PORT"
sudo docker rm client_container
sudo docker build -f client_dockerfile -t assignment2_client .
server_ip="$(sudo docker inspect -f '{{.NetworkSettings.Networks.ass2_network_server.IPAddress }}' server_container)"
echo "The server docker container IP adress is $server_ip"
sudo docker run --name client_container -it --network ass2_network_client --mount type=bind,src=/users/abhag017/client_persistent_storage,dst=/usr/src/assignment2_client/client_storage assignment2_client $server_ip:$1 client_storage/mydata.txt