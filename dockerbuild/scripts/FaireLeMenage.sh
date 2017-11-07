#!/bin/bash

#docker rm $(docker ps -a -q)
docker rm $(docker ps -q)
docker rmi $(docker images -a | grep "^<none>" | awk '{print $3}')

exit

