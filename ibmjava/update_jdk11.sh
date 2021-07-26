#!/bin/bash
#
# (C) Copyright IBM Corporation 2021
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
set -eo pipefail

# Dockerfiles to be generated
version="11"
package="jdk"
arches="ppcle s390x x86_64"
osver="ubuntu ubi ubi-min"

# sha256sum for the various versions, packages and arches
# Version 11 sums [DO NO EDIT THIS LINE]
declare -A jdk_11_sums=(
	[version]="11.0.11.0"
	[ppc64le]="717d3c0427d34af710f10f62be68cc78576ebb80523ff65ab3e8c1fe6a785569"
	[s390x]="b2e64a73dab3fed0a845144377a9cd2945b87c005ba2418f1abbefea45321167"
	[x86_64]="037363b1dd35d7b6a67137baf1c73589b4f7b4e177d40394897726ad6056babd"
)

# Generate the common license and copyright header
print_legal() {
	cat > $1 <<-EOI
	# (C) Copyright IBM Corporation 2021
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

	EOI
}

# Print the supported Ubuntu OS
print_ubuntu_os() {
	cat >> $1 <<-EOI
	FROM ubuntu:20.04

	EOI
}

# Print the supported UBI Minimal OS
print_ubi-min_os() {
	cat >> $1 <<-EOI
	FROM registry.access.redhat.com/ubi8/ubi-minimal:8.4

	EOI
}

# Print the supported UBI Minimal OS
print_ubi_os() {
	cat >> $1 <<-EOI
	FROM registry.access.redhat.com/ubi8/ubi:8.4

	EOI
}

# Print the maintainer
print_maint() {
	cat >> $1 <<-EOI
	MAINTAINER Jayashree Gopi <jayasg12@in.ibm.com> (@jayasg12)
	EOI
}

# Select the ubuntu OS packages
print_ubuntu_pkg() {
	cat >> $1 <<'EOI'

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*
EOI
}
# Select the ubi-min OS packages
print_ubi-min_pkg() {
	cat >> $1 <<'EOI'

RUN microdnf install openssl wget ca-certificates gzip tar \
    && microdnf update; microdnf clean all

EOI
}

# Select the ubi OS packages
print_ubi_pkg() {
	cat >> $1 <<'EOI'

RUN yum install -y wget openssl ca-certificates gzip tar \
    && yum update; yum clean all

EOI
}

# Print the Java version that is being installed here
print_env() {
        srcpkg=$2
        shasums="${srcpkg}"_"${ver}"_sums
        jverinfo=${shasums}[version]
        eval jver=\${$jverinfo}
	if [ "${os}" == "ubi-min" -o "${os}" == "ubi" ]; then
                cat >> $1 <<-EOI
LABEL org.opencontainers.image.authors="Jayashree Gopi <jayasg12@in.ibm.com>" \\
    name="IBM JAVA" \\
    vendor="IBM" \\
    version=${jver} \
    release=${ver} \\
    run="docker run --rm -ti <image_name:tag> /bin/bash" \\
    summary="Image for IBM JAVA with UBI as the base image" \\
    description="This image contains the IBM JAVA with Red Hat UBI as the base OS.  For more information on this image please see https://github.com/ibmruntimes/ci.docker/blob/master/README.md"
EOI
        fi
                cat >> $1 <<-EOI
ENV JAVA_VERSION ${jver}

EOI

}

# OS independent portion (Works for UBI, Alpine and Ubuntu)
print_java_install() {
	if [ "${os}" == "ubi" -o "${os}" == "ubi-min" ]; then
		cat >> $1 <<-EOI
       amd64|x86_64) \\
         ESUM='$(sarray=${shasums}[x86_64]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='11.0/${srcpkg}/linux/x86_64/index.yml'; \\
         ;; \\
       ppc64el|ppc64le) \\
         ESUM='$(sarray=${shasums}[ppc64le]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='11.0/${srcpkg}/linux/ppc64le/index.yml'; \\
         ;; \\
       s390x) \\
         ESUM='$(sarray=${shasums}[s390x]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='11.0/${srcpkg}/linux/s390x/index.yml'; \\
         ;; \\
       *) \\
         echo "Unsupported arch: \${ARCH}"; \\
         exit 1; \\
         ;; \\
    esac; \\
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"; \\
EOI
	else
		cat >> $1 <<-EOI
       amd64|x86_64) \\
         ESUM='$(sarray=${shasums}[x86_64]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='11.0/${srcpkg}/linux/x86_64/index.yml'; \\
         ;; \\
       ppc64el|ppc64le) \\
         ESUM='$(sarray=${shasums}[ppc64le]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='11.0/${srcpkg}/linux/ppc64le/index.yml'; \\
         ;; \\
       s390x) \\
         ESUM='$(sarray=${shasums}[s390x]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='11.0/${srcpkg}/linux/s390x/index.yml'; \\
         ;; \\
       *) \\
         echo "Unsupported arch: \${ARCH}"; \\
         exit 1; \\
         ;; \\
    esac; \\
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"; \\
EOI
	fi

	cat >> $1 <<'EOI'
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
EOI
	if [ "${os}" == "ubi" -o "${os}" == "ubi-min" ]; then
		cat >> $1 <<'EOI'
    mkdir -p /licenses; \
    cp /opt/ibm/java/legal/java.base/license/license_en.txt /licenses; \
    chown -R 1001:0 /opt/ibm/java; \
EOI
	fi
	if [ "${os}" == "ubi-min" ]; then
	        cat >> $1 <<'EOI'
    microdnf -y remove shadow-utils; \
    microdnf clean all; \
EOI
	fi

        JCMD="rm -f /tmp/ibm-java.bin;"

	cat >> $1 <<EOI
    ${JCMD}
EOI
}

# Print the main RUN command that installs Java on ubuntu.
print_ubuntu_java_install() {
	srcpkg=$2
	dstpkg=$3
	shasums="${srcpkg}"_"${ver}"_sums
	cat >> $1 <<'EOI'
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
EOI
	print_java_install ${file} ${srcpkg} ${dstpkg};
}

# Print the main RUN command that installs Java on ubi-min.
print_ubi-min_java_install() {
	srcpkg=$2
	dstpkg=$3
	shasums="${srcpkg}"_"${ver}"_sums
	cat >> $1 <<'EOI'
RUN set -eux; \
    microdnf -y install shadow-utils; \
    useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
EOI
	print_java_install ${file} ${srcpkg} ${dstpkg};
}

# Print the main RUN command that installs Java on ubi.
print_ubi_java_install() {
	srcpkg=$2
	dstpkg=$3
	shasums="${srcpkg}"_"${ver}"_sums
	cat >> $1 <<'EOI'
RUN set -eux; \
    useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
EOI
	print_java_install ${file} ${srcpkg} ${dstpkg};
}

print_java_env() {
	if [ "${pack}" == "sdk" ]; then
		if [ "${ver}" == "8" ]; then
			JHOME="/opt/ibm/java/jre"
			JPATH="/opt/ibm/java/bin"
		elif [ "${ver}" == "9" ]; then
			JHOME="/opt/ibm/java"
			JPATH="/opt/ibm/java/bin"
		fi
	elif [ "${pack}" == "jdk" ]; then
	       JHOME="/opt/ibm/java"
               JPATH="/opt/ibm/java/bin"
        else
		JHOME="/opt/ibm/java/jre"
		JPATH="/opt/ibm/java/jre/bin"
	fi
	TPATH="PATH=${JPATH}:\$PATH"

	cat >> $1 <<-EOI

ENV JAVA_HOME=${JHOME} \\
    ${TPATH} \\
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"
EOI
}

print_exclude_file() {
	srcpkg=$2
	dstpkg=$3
	if [ "${ver}" == "9" -a "${dstpkg}" == "sfj" ]; then
		cp sfj-exclude.txt `dirname ${file}`
		cat >> $1 <<-EOI
COPY sfj-exclude.txt /tmp

EOI
	fi
}

#print to run the docker image with user other than root.
print_user() {
	cat >> $1 <<-EOI

USER 1001
EOI
}

generate_java() {
	if [ "${ver}" == "9" ]; then
		srcpkg="sdk";
	else
		srcpkg=${pack};
	fi
	dstpkg=${pack};
	print_env ${file} ${srcpkg};
	print_exclude_file ${file} ${srcpkg} ${dstpkg};
if [ "${os}" == "ubuntu" ]; then
		print_ubuntu_java_install ${file} ${srcpkg} ${dstpkg};
elif [ "${os}" == "ubi" ]; then
		print_ubi_java_install ${file} ${srcpkg} ${dstpkg};
elif [ "${os}" == "ubi-min" ]; then
		print_ubi-min_java_install ${file} ${srcpkg} ${dstpkg};
fi
	print_java_env ${file};
}

generate_ubuntu() {
	file=$1
	mkdir -p `dirname ${file}` 2>/dev/null
	echo -n "Writing ${file}..."
	print_legal ${file};
	print_ubuntu_os ${file};
	print_maint ${file};
	print_ubuntu_pkg ${file};
	generate_java ${file};
	echo "done"
}

generate_alpine() {
	file=$1
	mkdir -p `dirname ${file}` 2>/dev/null
	echo -n "Writing ${file}..."
	print_legal ${file};
	print_alpine_os ${file};
	print_maint ${file};
	print_alpine_pkg ${file};
	generate_java ${file};
	cp sgerrand.rsa.pub `dirname ${file}`
	echo "done"
}

generate_ubi() {
	file=$1
	mkdir -p `dirname ${file}` 2>/dev/null
	echo -n "Writing ${file}..."
	print_legal ${file};
	print_ubi_os ${file};
	print_ubi_pkg ${file};
	generate_java ${file};
	print_user ${file};
	echo "done"
}

generate_ubi-min() {
	file=$1
	mkdir -p `dirname ${file}` 2>/dev/null
	echo -n "Writing ${file}..."
	print_legal ${file};
	print_ubi-min_os ${file};
	print_ubi-min_pkg ${file};
	generate_java ${file};
	print_user ${file};
	echo "done"
}

# Print the ibmjava image version
print_java() {
	cat >> $1 <<-EOI
	FROM ibmjava:${ver}-jdk

	EOI
}

# Iterate through all the Java versions for each of the supported packages,
# architectures and supported Operating Systems.
for ver in ${version}
do
	for pack in ${package}
	do
		for os in ${osver}
		do
			file=${ver}/${pack}/${os}/Dockerfile
			# Ubuntu is supported for everything
			if [ "${os}" == "ubuntu" ]; then
				generate_ubuntu ${file}
			elif [ "${os}" == "ubi" ]; then
				generate_ubi ${file}
			elif [ "${os}" == "ubi-min" ]; then
				generate_ubi-min ${file}
			fi
		done
	done
done

