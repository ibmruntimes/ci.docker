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

ENV IBM_VERSION 4.8.4.0
ENV NODE_VERSION 4.8.4

RUN set -eux; \
    buildDeps='wget ca-certificates unzip openjdk-8-jre'; \
    apt-get update && apt-get install -y --no-install-recommends $buildDeps \
      && rm -rf /var/lib/apt/lists/*; \
    AMD64_SHA="0ef5b46a53e7477d50f40e1544b337adc19b9144565e99f0718ee38cc6365217"; \
    PPC64LE_SHA="89bb8d55af668b332eae62a2965be45d30160c98cff612dfd11a53d23cfb8a4d"; \
    S390X_SHA="69ea0a03919944414b45bf1e5a6a77894804e6d6edcd5ddaf390897b0c541c69"; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         BINARY="$IBM_VERSION/linux/x86_64/ibm-$IBM_VERSION-node-v$NODE_VERSION-linux-x64.bin"; \
         SHA=$AMD64_SHA; \
         ;; \
         ppc64el|ppc64le) \
         BINARY="$IBM_VERSION/linux/ppc64le/ibm-$IBM_VERSION-node-v$NODE_VERSION-linux-ppc64le.bin"; \
         SHA=$PPC64LE_SHA; \
         ;; \
         s390x) \
         BINARY="$IBM_VERSION/linux/s390x/ibm-$IBM_VERSION-node-v$NODE_VERSION-linux-s390x.bin"; \
         SHA=$S390X_SHA; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/nodejs/"; \
    wget -q -U UA_IBM_Node_Docker -O /tmp/ibm-node.bin $BASE_URL/$BINARY; \
    echo "$SHA  /tmp/ibm-node.bin" | sha256sum -c - || exit 1; \
    mkdir -p /opt/ibm; \
    chmod +x /tmp/ibm-node.bin; \
    /tmp/ibm-node.bin -i silent  -DLICENSE_ACCEPTED=true -DUSER_INSTALL_DIR="/usr/local/bin/node"; \
    apt-get purge -y --auto-remove $buildDeps

ENV NODE_HOME=/usr/local/bin/node/bin/ \
    PATH=/usr/local/bin/node/bin:$PATH

ONBUILD RUN echo 'Please note that by using this image you are accepting the license terms.' \
            'Licenses are available at /usr/local/bin/node/license/'
