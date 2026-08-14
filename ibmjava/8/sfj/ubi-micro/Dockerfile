# (C) Copyright IBM Corporation 2026
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

FROM registry.access.redhat.com/ubi10/ubi-minimal AS builder

RUN microdnf install -y \
    curl \
    gzip \
    tar \
    && microdnf clean all

RUN microdnf install -y \
    --installroot /mnt/rootfs \
    --releasever 10 \
    --config /etc/dnf/dnf.conf \
    --noplugins \
    --setopt=reposdir=/etc/yum.repos.d \
    --setopt=cachedir=/var/cache/dnf \
    --setopt=varsdir=/etc/dnf/vars \
    --setopt=install_weak_deps=0 \
    --nodocs \
    openssl \
    ca-certificates \
    && microdnf clean all \
    --installroot /mnt/rootfs \
    --config /etc/dnf/dnf.conf \
    --noplugins \
    --setopt=reposdir=/etc/yum.repos.d \
    --setopt=cachedir=/var/cache/dnf \
    --setopt=varsdir=/etc/dnf/vars \
    && rm -rf \
    /mnt/rootfs/var/cache/dnf \
    /mnt/rootfs/var/lib/dnf \
    /mnt/rootfs/var/log/dnf* \
    /mnt/rootfs/var/log/hawkey.log \
    /var/cache/dnf

RUN set -eux; \
    microdnf -y install shadow-utils; \
    useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='9294b4d1c8f648dc59c1237d7e5fd4c2a3236e29fb79f83e34c1de1c03522eaa'; \
         YML_FILE='8.0/sfj/linux/x86_64/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='82a74387fe138a7f79260fb5a52fda243d1f875bf2955209d55db9952d60135e'; \
         YML_FILE='8.0/sfj/linux/ppc64le/index.yml'; \
         ;; \
       s390x) \
         ESUM='a5512b6afa58e9a086713de9ef2ab42e80b1541eba51a32a76833b56ed508922'; \
         YML_FILE='8.0/sfj/linux/s390x/index.yml'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"; \
    curl -sL -A "UA_IBM_JAVA_Docker" -o /tmp/index.yml "${BASE_URL}/${YML_FILE}" && \
    JAVA_URL=$(sed -n '/^'${JAVA_VERSION}:'/{n;s/\s*uri:\s//p}'< /tmp/index.yml); \
    curl -sL -A "UA_IBM_JAVA_Docker" -o /tmp/ibm-java.tgz "${JAVA_URL}" && \
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

FROM registry.access.redhat.com/ubi10/ubi-micro

LABEL org.opencontainers.image.authors="Jayashree Gopi" \
    maintainer="jayasg12@in.ibm.com" \
    name="IBM JAVA" \
    vendor="IBM" \
    version=8.0.8.70 \
    release=8 \
    run="docker run --rm -ti <image_name:tag> /bin/bash" \
    summary="Image for IBM JAVA with UBI 10 Micro as the base image" \
    description="This image contains the IBM JAVA with Red Hat UBI 10 MICRO as the base OS.  For more information on this image please see https://github.com/ibmruntimes/ci.docker/blob/master/README.md"

ENV JAVA_VERSION 8.0.8.70

COPY --from=builder /mnt/rootfs /
COPY --from=builder /opt/ibm/java /opt/ibm/java
COPY --from=builder /licenses /licenses

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH \
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"

USER 1001
