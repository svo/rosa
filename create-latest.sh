#!/usr/bin/env bash

image=$1

docker manifest rm "svanosselaer/rosa-${image}:latest" 2>/dev/null || true

docker manifest create \
  "svanosselaer/rosa-${image}:latest" \
  --amend "svanosselaer/rosa-${image}:amd64" \
  --amend "svanosselaer/rosa-${image}:arm64" &&
docker manifest push "svanosselaer/rosa-${image}:latest"
