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

ENV JAVA_VERSION 1.8.0_sr5fp11

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='5bb361cc011e31bb7def6d69ee1b02b1d5b0964926b32c5bb622d0583ddafd78'; \
         YML_FILE='sdk/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='b65cecbfcd1309afc3eb66298a15e96151cc8bc21a3a560c8fa80a77ab0092b2'; \
         YML_FILE='sdk/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='2d14f12f21bfdc4b8ffc058dfc9e0eafbf65180b75a95fc3e73732aa434e1dbe'; \
         YML_FILE='sdk/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='471113433138f30e66db9b677335f33061602bc7191c77e19c86825cd5db121b'; \
         YML_FILE='sdk/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='6e7cd7bdcd940b8e6606e0d5ed396d290500354182c55436d7393b76ee8d9010'; \
         YML_FILE='sdk/linux/s390x/index.yml'; \
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
    rm -f /tmp/ibm-java.bin;

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/bin:$PATH
