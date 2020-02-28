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
         ESUM='ffb63fdc83eb7fbf77966e8939ffabfba2838d0cd3c31ef2039e429fc6c32e08'; \
         YML_FILE='sfj/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='05760e27bf84719ea57f4e6606c7517a47aa035784c64007aa9419ff713f45e3'; \
         YML_FILE='sfj/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='79cdddb40485c292996adbde2a5033be2984ae8536655f59afccdc0b67874bbf'; \
         YML_FILE='sfj/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='f1f26da49fae25257539a550521981e996e325eead18919c2240e88a8f50b74e'; \
         YML_FILE='sfj/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='6b94b8c3299995d78a0524f091f49c9d33bf093dcec99f85d41b2456185cf331'; \
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
