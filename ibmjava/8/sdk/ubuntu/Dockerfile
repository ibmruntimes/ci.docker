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

ENV JAVA_VERSION 1.8.0_sr6fp30

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='afd31dea9c65fdfef664ac93140115f7c0746445bbe24fc7c62891236d28689d'; \
         YML_FILE='sdk/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='763acaa61abc4e58b6c910b909b4d7ca2459ca1d4cc17d15cab328db94bf4ae7'; \
         YML_FILE='sdk/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='d5dfe0aebd5f6bf09797aad1962f7feb3950546ac6e67174cd66447d00daf576'; \
         YML_FILE='sdk/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='b5faf5cf5d5cfeb0dbb390059a56f4e5da3a902604d3f821104879f18c78ffb6'; \
         YML_FILE='sdk/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='663c68478b7888b3455838c4fcd4cc9d1e09c8b55ec5dd1eb7eba786df9cee46'; \
         YML_FILE='sdk/linux/s390x/index.yml'; \
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
    PATH=/opt/ibm/java/bin:$PATH \
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"
