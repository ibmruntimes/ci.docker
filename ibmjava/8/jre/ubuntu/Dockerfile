# (C) Copyright IBM Corporation 2016, 2019
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

FROM ubuntu:18.04

MAINTAINER Jayashree Gopi <jayasg12@in.ibm.com> (@jayasg12)

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION 1.8.0_sr6fp6

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='cb954cb31724227a6392f68b6f00d4ea32138ce26f0bfd09461a79fefa9759b5'; \
         YML_FILE='jre/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='d2189944a70c9f30b32ab1b98fd45db69b11636428a7bc57787d79a2d91fbf6e'; \
         YML_FILE='jre/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='82fdd590e91185befae222eaa36f6c8c3c0392d7237810dd06f64a6596a1cbfa'; \
         YML_FILE='jre/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='fb07cf24cb81074b60c2044ced28d4ff4aa41a12633786b054490659b278abeb'; \
         YML_FILE='jre/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='a72a8937514bddaaba372dd93a1b84ac71ea6bbdb2bd1a0b506273e8262e0623'; \
         YML_FILE='jre/linux/s390x/index.yml'; \
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
