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

FROM ubuntu:16.04

MAINTAINER Bethany Griggs <bethany.griggs@uk.ibm.com> (@BethGriggs)

ENV IBM_VERSION 6.11.3.0
ENV NODE_VERSION 6.11.3

RUN buildDeps='wget ca-certificates unzip openjdk-8-jre'; \
    apt-get update \
      && apt-get install -y --no-install-recommends $buildDeps \
      && rm -rf /var/lib/apt/lists/* \
    set -eux; \
    AMD64_SHA="f5d71b287912fc2564f6deac10dec979606310c9a781dbb2033d6fc573a777a8"; \
    PPC64LE_SHA="95a37e205c36f50a9237efa1a172b7373b16b5bef561e18cd44a08933979f81e"; \
    S390X_SHA="2c3fa6cca28f67b49c9947538ab7b6b4291782e258739d3c24ac579972708db7"; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         BINARY="$IBM_VERSION/linux/x86_64/ibm-$IBM_VERSION-node-v$NODE_VERSION-linux-x64.bin"; \
         ;; \
         ppc64el|ppc64le) \
         BINARY="$IBM_VERSION/linux/ppc64le/ibm-$IBM_VERSION-node-v$NODE_VERSION-linux-ppc64le.bin"; \
           ;; \
         s390x) \
         BINARY="$IBM_VERSION/linux/s390x/ibm-$IBM_VERSION-node-v$NODE_VERSION-linux-s390x.bin"; \
           ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/nodejs/"; \
    CHECKSUM=$(wget -qO- ${BASE_URL}/${SHA256} | awk '{print $1}'); \
    wget -q -U UA_IBM_Node_Docker -O /tmp/ibm-node.bin ${BASE_URL}/${BINARY}; \
    echo "${CHECKSUM}  /tmp/ibm-node.bin" | sha256sum -c -; \
    mkdir -p /opt/ibm; \
    chmod +x /tmp/ibm-node.bin; \
    /tmp/ibm-node.bin -i silent  -DLICENSE_ACCEPTED=true -DUSER_INSTALL_DIR="/usr/local/bin/node"; \
    apt-get purge -y --auto-remove $buildDeps

ENV NODE_HOME=/usr/local/bin/node/bin/ \
    PATH=/usr/local/bin/node/bin:$PATH
