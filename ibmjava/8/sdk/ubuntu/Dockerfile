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
         ESUM='761a91dc6e50667675eb6857e80fb1b8faa28c4b018331737eae4d1d3dc7c491'; \
         YML_FILE='sdk/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='86d12c4eb01578f9e080327e07337a5687997bb5f5622a395f5d2d7d88a72599'; \
         YML_FILE='sdk/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='73f6a4188a660b6e6e7ad15caf35eb001645f229155ae2cde154170461359d21'; \
         YML_FILE='sdk/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='aad7d60670d2ce800b9295a2b173f96d0419253767d0e22ce4aa5021576b4b5b'; \
         YML_FILE='sdk/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='3663dbb5ce956b924171167d4801414a21067f492252f7cc68a196a3f7b39a8e'; \
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
