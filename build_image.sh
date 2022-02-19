#!/bin/bash
set -xe

user=$USER
uid=$(id -u)
gid=$(id -g)

WORKDIR=$(readlink -e $(dirname $0))
docker build \
    --build-arg user=$user \
    --build-arg uid=$uid \
    --build-arg gid=$gid \
    -t nvim-ide-base \
    -f $WORKDIR/base.Dockerfile $WORKDIR

docker build \
    --build-arg user=$user \
    --build-arg uid=$uid \
    --build-arg gid=$gid \
    -t nvim-ide-python \
    -f $WORKDIR/python.Dockerfile $WORKDIR
