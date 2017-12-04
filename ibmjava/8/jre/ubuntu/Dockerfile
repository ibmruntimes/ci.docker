# (C) Copyright IBM Corporation 2016, 2017
#
# ------------------------------------------------------------------------------
#               NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
#                       PLEASE DO NOT EDIT IT DIRECTLY.
# ------------------------------------------------------------------------------
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

MAINTAINER Dinakar Guniguntala <dinakar.g@in.ibm.com> (@dinogun)

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION 1.8.0_sr5fp6

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='b6ccb3db145f0b31e92a9621c81e6247704852daa6fbabc72ac4a36dd5f5df24'; \
         YML_FILE='jre/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='053ec23dca6a3cb98ca4128aa726ac7e8b06c9aed330a38dafa6817732451f6f'; \
         YML_FILE='jre/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='26a7d65089f4a9cdbdcd93318a1c28017e9ef15bf66228e9984aa9fed5efb53e'; \
         YML_FILE='jre/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='0f806c5e2c04fc5fea7f815885db05530744616e2a5bafc2fecbd617350f325f'; \
         YML_FILE='jre/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='7da8158760e2ce87cc258e8a69dfc08c86e4276cf798f47745d134a05732cc32'; \
         YML_FILE='jre/linux/s390x/index.yml'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"; \
    wget -q -U UA_IBM_JAVA_Docker -O /tmp/index.yml ${BASE_URL}/${YML_FILE}; \
    JAVA_URL=$(cat /tmp/index.yml | sed -n '/'${JAVA_VERSION}'/{n;p}' | sed -n 's/\s*uri:\s//p' | tr -d '\r'); \
    wget -q -U UA_IBM_JAVA_Docker -O /tmp/ibm-java.bin ${JAVA_URL}; \
    echo "${ESUM}  /tmp/ibm-java.bin" | sha256sum -c -; \
    echo "INSTALLER_UI=silent" > /tmp/response.properties; \
    echo "USER_INSTALL_DIR=/opt/ibm/java" >> /tmp/response.properties; \
    echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties; \
    mkdir -p /opt/ibm; \
    chmod +x /tmp/ibm-java.bin; \
    /tmp/ibm-java.bin -i silent -f /tmp/response.properties; \
    rm -f /tmp/response.properties; \
    rm -f /tmp/index.yml; \
    rm -f /tmp/ibm-java.bin; \
    cd /opt/ibm/java/jre/lib; \
    rm -rf icc;

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH
