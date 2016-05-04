# (C) Copyright IBM Corporation 2016.
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

FROM alpine:latest

MAINTAINER Dinakar Guniguntala <dinakar.g@in.ibm.com> (@dinogun)

RUN apk --update add curl wget ca-certificates tar \
    && ln -s /lib /lib64 \
    && curl -Ls https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk \
    && apk add --allow-untrusted /tmp/glibc-2.21-r2.apk \
    && apk --update add xz \
    && curl -Ls https://www.archlinux.org/packages/core/x86_64/gcc-libs/download > /tmp/gcc-libs.tar.gz \
    && tar -xvf /tmp/gcc-libs.tar.gz -C / usr/lib/libgcc_s.so.1 usr/lib/libgcc_s.so

ENV JAVA_VERSION 1.8.0_sr3

RUN ESUM="b34f89078048ba0ac650bf56c06331028a71d505c65743383623d94ca29f2c4e" \
    && BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/" \
    && YML_FILE="jre/linux/x86_64/index.yml" \
    && wget -q -U UA_IBM_JAVA_Docker -O /tmp/index.yml $BASE_URL/$YML_FILE \
    && JAVA_URL=$(cat /tmp/index.yml | sed -n '/'$JAVA_VERSION'/{n;p}' | sed -n 's/\s*uri:\s//p' | tr -d '\r') \
    && wget -q -U UA_IBM_JAVA_Docker -O /tmp/ibm-java.bin $JAVA_URL \
    && echo "INSTALLER_UI=silent" > /tmp/response.properties \
    && echo "USER_INSTALL_DIR=/opt/ibm/java" >> /tmp/response.properties \
    && echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties \
    && mkdir -p /opt/ibm \
    && chmod +x /tmp/ibm-java.bin \
    && /tmp/ibm-java.bin -i silent -f /tmp/response.properties \
    && rm -f /tmp/response.properties \
    && rm -f /tmp/index.yml \
    && rm -f /tmp/ibm-java.bin \
    && rm -f /tmp/gcc-libs.tar.gz \
    && rm -f /tmp/glibc-2.21-r2.apk

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH
