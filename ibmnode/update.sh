#!/bin/bash -ex

[ -z "$IBM_VERSION" -o -z "$NODE_VERSION" -o -z \
  "$AMD64_SHA" -o -z "$PPC64LE_SHA" -o -z "$S390X_SHA" ] &&
  echo "Please set env vars properly" && exit 1

MAJOR_VERSION=$(echo $IBM_VERSION | cut -f1 -d".")

sed -e "s/{{IBM_VERSION}}/$IBM_VERSION/g" \
-e "s/{{NODE_VERSION}}/$NODE_VERSION/g" \
-e "s/{{AMD64_SHA}}/$AMD64_SHA/g" \
-e "s/{{PPC64LE_SHA}}/$PPC64LE_SHA/g" \
-e "s/{{S390X_SHA}}/$S390X_SHA/g" Dockerfile-base  > Dockerfile-$MAJOR_VERSION
