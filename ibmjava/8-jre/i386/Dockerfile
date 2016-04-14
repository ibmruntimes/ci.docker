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

FROM ubuntu:14.04

MAINTAINER Dinakar Guniguntala <dinakar.g@in.ibm.com> (@dinogun)

# Install some 32bit compatibility libraries to run 32bit Java
RUN apt-get update \
    && apt-get install -y wget unzip lib32z1 lib32ncurses5 lib32bz2-1.0 lib32gcc1 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VER=8 \
    JAVA_REL=0 \
    JAVA_MF=2.10 \
    JAVA_PACKAGE="jre" \
    JAVA_TYPE="javase" \
    TARGET_ARCH="i386" \
    ESUM="a4bcb81e354d8ebd7edb28da39fbec32" \
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta"

# Install JRE if the downloaded md5sum matches what is available in the .yml file
RUN JAVA_VRMF=$JAVA_VER.$JAVA_REL-$JAVA_MF \
    && YML_FILENAME=ibm-java-$JAVA_PACKAGE-$JAVA_VRMF-linux-$TARGET_ARCH-$JAVA_TYPE.yml \
    && wget -q -U UA-IBM_JAVA_Docker -O /tmp/$YML_FILENAME $BASE_URL/$JAVA_VER$JAVA_REL/$YML_FILENAME \
    && JAVA_URL=$(cat /tmp/$YML_FILENAME | sed -n 's/\s*uri:\s//p' | tr -d '\r') \
    && wget -q -U UA-IBM-JAVA-Docker -O /tmp/ibm-java.bin $JAVA_URL \
    && echo "$ESUM /tmp/ibm-java.bin" | md5sum -c - \
    && echo "INSTALLER_UI=silent" > /tmp/response.properties \
    && echo "USER_INSTALL_DIR=/opt/ibm/java" >> /tmp/response.properties \
    && echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties \
    && mkdir -p /opt/ibm \
    && chmod +x /tmp/ibm-java.bin \
    && /tmp/ibm-java.bin -i silent -f /tmp/response.properties \
    && rm -f /tmp/response.properties \
    && rm -f /tmp/ibm-java.bin

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH
