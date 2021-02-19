#!/bin/bash

DIR=~/.config/pgadmin
FILE=pgadmin-env.list

if [ "$(docker ps -q -f name=pgadmin4)" ]; then
    docker container stop pgadmin4
    docker container rm pgadmin4
fi

if [ ! "$(docker volume ls | grep pga4volume)" ]; then
  docker volume create --driver local --name=pga4volume
fi

if [ ! -d "$DIR" ]; then
    mkdir $DIR
fi

cd $DIR

if [ ! -f "$FILE" ]; then
    cat << EOF > $FILE
PGADMIN_DEFAULT_EMAIL=root
PGADMIN_DEFAULT_PASSWORD=pepito
EOF

fi

docker pull dpage/pgadmin4
docker run --restart unless-stopped \
  --volume=pga4volume:/var/lib/pgadmin \
  --env-file=$FILE \
  --name="pgadmin4" \
  --hostname="pgadmin4" \
  --network="host" \
  --detach dpage/pgadmin4

