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

FROM registry.access.redhat.com/rhel7

MAINTAINER Jayashree Gopi <jayasg12@in.ibm.com> (@jayasg12)

RUN yum makecache fast \
    && yum update -y \
    && yum -y install openssl wget ca-certificates \
    && yum clean packages \
    && yum clean headers \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /var/tmp/yum-*


ENV JAVA_VERSION 8.0.7.16

RUN set -eux; \
    ARCH="$(arch)"; \
    case "${ARCH}" in \
       amd64|x86_64) \
         ESUM='70b5592485b0188b421cb0a072e913e3f93dfebcbc63096651258b622f19e710'; \
         YML_FILE='8.0/jre/linux/x86_64/index.yml'; \
         ;; \
       i386) \
         ESUM='2cf9c65de9a8dce78ebb4403b0d83a173cda3b3b5064ce5f6f63236f89e607c0'; \
         YML_FILE='8.0/jre/linux/i386/index.yml'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='eaae9e57e497ab9850203384a373a473f0d8648b02c1de5c1e01af14794c5af9'; \
         YML_FILE='8.0/jre/linux/ppc64le/index.yml'; \
         ;; \
       s390) \
         ESUM='aa301e7f2fa12ba5b3c2183674d232e8942fd6061ea2efa589d1f404969d810b'; \
         YML_FILE='8.0/jre/linux/s390/index.yml'; \
         ;; \
       s390x) \
         ESUM='e091ac9b24b35f1c6cf28f3fb494e3643841bc7949c28bf6899bc384ef547ba7'; \
         YML_FILE='8.0/jre/linux/s390x/index.yml'; \
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
