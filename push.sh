#!/usr/bin/env bash

image=$1 &&
architecture=$2 &&

if [ -z "$architecture" ]; then
  docker push "svanosselaer/rosa-${image}" --all-tags
else
  docker push "svanosselaer/rosa-${image}:${architecture}"
fi
