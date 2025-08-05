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

ENV JAVA_VERSION 8.0.8.50

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='5bd4cc4749040ff2af6126adac1259dddc09d4c43dfc14779b1c6e83fb77c47a'; \
         YML_FILE='8.0/sdk/linux/x86_64/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='58d2b8c23e815fa02019874109f78ad8ae01dee8f44e44ea0c69e29ececfd844'; \
         YML_FILE='8.0/sdk/linux/ppc64le/index.yml'; \
         ;; \
       s390x) \
         ESUM='0c17796c0c75f71717b95843b93a93e27f1d91f23bc6e2d1d1005feb20fd7530'; \
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
    wget -q -U UA_IBM_JAVA_Docker -O /tmp/ibm-java.tgz ${JAVA_URL}; \
    echo "${ESUM}  /tmp/ibm-java.tgz" | sha256sum -c -; \
    mkdir -p /opt/ibm/java; \
    tar -xf /tmp/ibm-java.tgz -C /opt/ibm/java --strip-components=1; \
    rm -f /tmp/index.yml; \
    rm -f /tmp/ibm-java.tgz;

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/bin:$PATH \
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"
