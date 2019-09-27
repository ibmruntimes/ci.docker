# (C) Copyright IBM Corporation 2016, 2018
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

ENV JAVA_VERSION 1.8.0_sr5fp41

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='8d791449cd7a3075bb98e15ee03aa9f223e3df41b13af5426f91b08cf8e6c705'; \
         YML_FILE='sfj/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='8560ddf237e14154ba3a7bbc8552038db5b12f4ca68136b5db2774851229308d'; \
         YML_FILE='sfj/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='07896e5226841a54e6d1f28c44516135a1d1eace1b0b603af3227209b0402d6e'; \
         YML_FILE='sfj/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='1547e8261c65ef1ef4ffa11dfe61ac5f7e7c5974418e2947d44c7e38e4c022fc'; \
         YML_FILE='sfj/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='2aca7845df7fb33327a3a46e28880526fdb16cf33b16127ba1330a59683bad27'; \
         YML_FILE='sfj/linux/s390x/index.yml'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"; \
    wget -q -U UA_IBM_JAVA_Docker -O /tmp/index.yml ${BASE_URL}/${YML_FILE}; \
    JAVA_URL=$(sed -n '/^'${JAVA_VERSION}:'/{n;s/\s*uri:\s//p}'< /tmp/index.yml); \
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
    rm -f /tmp/ibm-java.bin;

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH \
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"
