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

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest


RUN microdnf install openssl wget ca-certificates gzip tar \
    && microdnf update; microdnf clean all

LABEL org.opencontainers.image.authors="Jayashree Gopi <jayasg12@in.ibm.com>" \
    name="IBM JAVA" \
    vendor="IBM" \
    version=8.0.8.20 \ 
    release=8 \
    run="docker run --rm -ti <image_name:tag> /bin/bash" \
    summary="Image for IBM JAVA with UBI as the base image" \
    description="This image contains the IBM JAVA with Red Hat UBI as the base OS.  For more information on this image please see https://github.com/ibmruntimes/ci.docker/blob/master/README.md"

ENV JAVA_VERSION 8.0.8.20

RUN set -eux; \
    microdnf -y install shadow-utils; \
    useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='c8055351ef6f0e475c934a1aed1d8cb8aa5c493d58dccaa9b6e9b10b58d7865f'; \
         YML_FILE='8.0/sfj/linux/x86_64/index.yml'; \
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
    mkdir -p /licenses; \
    cp /opt/ibm/java/license_en.txt /licenses; \
    chown -R 1001:0 /opt/ibm/java; \
    microdnf -y remove shadow-utils; \
    microdnf clean all; \
    rm -f /tmp/ibm-java.tgz;

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH \
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"

USER 1001
