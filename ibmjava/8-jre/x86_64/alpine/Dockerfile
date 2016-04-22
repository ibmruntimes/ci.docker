# (C) Copyright IBM Corporation 2016.
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

RUN apk --update add curl ca-certificates tar \
    && ln -s /lib /lib64 \
    && curl -Ls https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk \
    && apk add --allow-untrusted /tmp/glibc-2.21-r2.apk \
    && apk --update add xz \
    && curl -Ls https://www.archlinux.org/packages/core/x86_64/gcc-libs/download > /tmp/gcc-libs.tar.gz \
    && tar -xvf /tmp/gcc-libs.tar.gz -C /

ENV JAVA_VER=8 \
    JAVA_REL=0 \
    JAVA_MF=2.10 \
    JAVA_PACKAGE="jre" \
    JAVA_TYPE="javase" \
    TARGET_ARCH="x86_64" \
    ESUM="d6a2feb8123361874619d9100b24c58c" \
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta"

# Install JRE if the downloaded md5sum matches what is available in the .yml file
RUN JAVA_VRMF=$JAVA_VER.$JAVA_REL-$JAVA_MF \
    && YML_FILENAME=ibm-java-$JAVA_PACKAGE-$JAVA_VRMF-linux-$TARGET_ARCH-$JAVA_TYPE.yml \
    && curl -jksSLA UA-IBM_JAVA_Docker -o /tmp/$YML_FILENAME $BASE_URL/$JAVA_VER$JAVA_REL/$YML_FILENAME \
    && JAVA_URL=$(cat /tmp/$YML_FILENAME | sed -n 's/\s*uri:\s//p' | tr -d '\r') \
    && curl -jksSLA UA-IBM-JAVA-Docker -o /tmp/ibm-java.bin $JAVA_URL \
    && echo "INSTALLER_UI=silent" > /tmp/response.properties \
    && echo "USER_INSTALL_DIR=/opt/ibm/java" >> /tmp/response.properties \
    && echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties \
    && mkdir -p /opt/ibm \
    && chmod +x /tmp/ibm-java.bin \
    && /tmp/ibm-java.bin -i silent -f /tmp/response.properties \
    && rm -f /tmp/response.properties \
    && rm -f /tmp/ibm-java.bin \
    && rm -f /tmp/gcc-libs.tar.gz \
    && rm -f /tmp/glibc-2.21-r2.apk

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH
