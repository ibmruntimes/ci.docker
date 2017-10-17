#!/bin/bash -ex
#
# (C) Copyright IBM Corporation 2016, 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
[ -z "$IBM_VERSION" -o -z "$NODE_VERSION" -o -z \
  "$AMD64_SHA" -o -z "$PPC64LE_SHA" -o -z "$S390X_SHA" ] &&
  echo "Please set env vars properly" && exit 1

MAJOR_VERSION=$(echo $IBM_VERSION | cut -f1 -d".")

sed -e "s/{{IBM_VERSION}}/$IBM_VERSION/g" \
-e "s/{{NODE_VERSION}}/$NODE_VERSION/g" \
-e "s/{{AMD64_SHA}}/$AMD64_SHA/g" \
-e "s/{{PPC64LE_SHA}}/$PPC64LE_SHA/g" \
-e "s/{{S390X_SHA}}/$S390X_SHA/g" Dockerfile-base  > $MAJOR_VERSION/Dockerfile
