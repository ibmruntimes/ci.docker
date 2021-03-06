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

ENV JAVA_VERSION 1.8.0_sr6fp31

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='ed09900a0219b40ddfa06098118a701b8633dcf12588e13ff8b7d810ef2769dc'; \
         YML_FILE='jre/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='95bf8be233306b046150b949d2a8b9ce604eb6f4a090aaa7bf54152181fcdc06'; \
         YML_FILE='jre/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='b6a57eff545b75f6fe164c0e96eab56d1a889ae7574e205230f84175b50f6c03'; \
         YML_FILE='jre/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='2b2b73eef781996e570670a2dec541778647a2afb37b516c9a750e7857fc90aa'; \
         YML_FILE='jre/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='70da4d42a8181e7a13ca63320acf856315b993f35222e34fa50032a270d472d4'; \
         YML_FILE='jre/linux/s390x/index.yml'; \
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
