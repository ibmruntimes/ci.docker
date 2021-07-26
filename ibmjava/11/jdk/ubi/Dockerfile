# (C) Copyright IBM Corporation 2016, 2019
#
# ------------------------------------------------------------------------------
#               NOTE: THIS DOCKERFILE IS GENERATED VIA "update_jdk11.sh"
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

FROM registry.access.redhat.com/ubi8/ubi:8.4


RUN yum install -y wget openssl ca-certificates gzip tar \
    && yum update; yum clean all

LABEL org.opencontainers.image.authors="Jayashree Gopi <jayasg12@in.ibm.com>" \
    name="IBM JAVA" \
    vendor="IBM" \
    version=11.0.11.0     release=11 \
    run="docker run --rm -ti <image_name:tag> /bin/bash" \
    summary="Image for IBM JAVA with UBI as the base image" \
    description="This image contains the IBM JAVA with Red Hat UBI as the base OS.  For more information on this image please see https://github.com/ibmruntimes/ci.docker/blob/master/README.md"
ENV JAVA_VERSION 11.0.11.0

RUN set -eux; \
    useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='037363b1dd35d7b6a67137baf1c73589b4f7b4e177d40394897726ad6056babd'; \
         YML_FILE='11.0/jdk/linux/x86_64/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='717d3c0427d34af710f10f62be68cc78576ebb80523ff65ab3e8c1fe6a785569'; \
         YML_FILE='11.0/jdk/linux/ppc64le/index.yml'; \
         ;; \
       s390x) \
         ESUM='b2e64a73dab3fed0a845144377a9cd2945b87c005ba2418f1abbefea45321167'; \
         YML_FILE='11.0/jdk/linux/s390x/index.yml'; \
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
    echo "USER_INSTALL_DIR=/opt/ibm" >> /tmp/response.properties; \
    echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties; \
    mkdir -p /opt/ibm; \
    chmod +x /tmp/ibm-java.bin; \
    /tmp/ibm-java.bin -i silent -f /tmp/response.properties; \
    mv /opt/ibm/jdk-11* /opt/ibm/java; \
    rm -f /tmp/response.properties; \
    rm -f /tmp/index.yml; \
    mkdir -p /licenses; \
    cp /opt/ibm/java/legal/java.base/license/license_en.txt /licenses; \
    chown -R 1001:0 /opt/ibm/java; \
    rm -f /tmp/ibm-java.bin;

ENV JAVA_HOME=/opt/ibm/java \
    PATH=/opt/ibm/java/bin:$PATH \
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"

USER 1001
