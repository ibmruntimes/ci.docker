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

FROM ubuntu:22.04

MAINTAINER Jayashree Gopi <jayasg12@in.ibm.com> (@jayasg12)

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION 8.0.8.21

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='a381d174001bbc558c8911b952c30c2a4fe6dea78a9ff6a25a2db9ac5e7fd952'; \
         YML_FILE='8.0/jre/linux/x86_64/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='7e1ee0174aea6cd2a41a561beb4e9b61b7b1d73bc3b8bf68a7d47c2f6ba7e555'; \
         YML_FILE='8.0/jre/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='80aed9b6510c2cdc2484435d44d7a50fb744ce4f2ae673fa090eddb222cf66fc'; \
         YML_FILE='8.0/jre/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='e7f5d2623a6932095deb2320b3eaa8fd70cf4131653113eb7ff950e276af1cfb'; \
         YML_FILE='8.0/jre/linux/s390x/index.yml'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"; \
    wget -q -U UA_IBM_JAVA_Docker -O /tmp/index.yml ${BASE_URL}/${YML_FILE}; \
    JAVA_URL=$(sed -n '/^'${JAVA_VERSION}:'/{n;s/\s*uri:\s//p}'< /tmp/index.yml); \
    wget -q -U UA_IBM_JAVA_Docker -O /tmp/ibm-java.tgz ${JAVA_URL}; \
    echo "${ESUM}  /tmp/ibm-java.tgz" | sha256sum -c -; \
    mkdir -p /opt/ibm/java; \
    tar -xf /tmp/ibm-java.tgz -C /opt/ibm/java --strip-components=1; \
    rm -f /tmp/index.yml; \
    rm -f /tmp/ibm-java.tgz;

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH \
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"
