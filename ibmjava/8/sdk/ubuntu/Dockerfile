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

ENV JAVA_VERSION 8.0.7.16

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='bb34f647a77ae43611dab3a447da447686352da5426baaff26c22a465dfe40c0'; \
         YML_FILE='8.0/sdk/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='b8c35301b56fde151b14e1bfb1374f579f5a0ed361d6ebc7ffff5f82eb563344'; \
         YML_FILE='8.0/sdk/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='79fde4473b2c489278fdef105bf69097f1f1a0d54d75a59d24008773b512339b'; \
         YML_FILE='8.0/sdk/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='f1989ee7f41d8d697e880dea74f94133841c2f59ded5c9dd551a26b87f4d36cf'; \
         YML_FILE='8.0/sdk/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='eb1cd5b6bf532f10558e7067768d14884d9fce375d2782f91b2218365152bc42'; \
         YML_FILE='8.0/sdk/linux/s390x/index.yml'; \
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
