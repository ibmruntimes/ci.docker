#!/bin/bash
#
# (C) Copyright IBM Corporation 2016, 2026
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
version="8"
package="jre sdk sfj"
arches="ppc64le s390x x86_64"
osver="ubuntu ubi ubi-min ubi-micro"

# sha256sum for the various versions, packages and arches
# Version 8 sums [DO NO EDIT THIS LINE]
declare -A jre_8_sums=(
	[version]="8.0.8.71"
	[i386]="cf1cd302f156d80f0c358e0fa0f679808a536a6ef3fc587024de143f046570c6"
	[ppc64le]="9c448e74672217bffe705b6c6e3689c493cd8fdb25ef97e722d9c21526950b37"
	[s390x]="eb3eec9f61f9bf433f5c545c74f4c156a37c43c5b10656c3ebb96b2d99436a32"
	[x86_64]="950fde6cd01ee3d8ef2c2c51de27463b1044809fb9131d92f5ea4095878e8a3f"
)

declare -A sdk_8_sums=(
	[version]="8.0.8.71"
	[i386]="ab86c7755bad42d5e49c96f978ca8e62214b7cc23ec82b8575c68d1d19c2cbac"
	[ppc64le]="946f8e56cc033e8b964da34c5554fa6b50b66a0a220699b5dfb436f780c192eb"
	[s390x]="3cb2cb64591dd4c438bed7cf5c5a5368b6b5a390bebb95828323947e5a7a91c1"
	[x86_64]="bf96528c4be42e2fc4520e3e0ef32ec9ccd6fb3492aea2cded29fe39ec1ea503"
)

declare -A sfj_8_sums=(
	[version]="8.0.8.71"
	[i386]="ac014e7c3601e9a200b5bb45ca4f727a0f273805ced6e1f13c3f1fe02c2f5ac5"
	[ppc64le]="87f8fd11be1217a752d579948df4a15ecd9f8d82c5bc687ddfe97904e2311369"
	[s390x]="ca078c1f555989d1f467d2bcf6fd44644087c3b4f5d3f559233f42871ccf2f37"
	[x86_64]="a09e3e5c55a839b5a19a55de76db0ff4db474173da91d20d06a1409896a1c23a"
)

# Version 9 sums [DO NO EDIT THIS LINE]
declare -A sdk_9_sums=(
	[version]="1.9.0_ea2"
	[i386]="5add39cc5ca56b97cf8ce71b9e1a15d19d36864aaed1e0296f50355ba3f34bd5"
	[ppc64le]="3c0dda9f449a667d12fe5f59a1ec059a90a9dc483fd35eef5ff53dd8b096cdf5"
	[s390x]="6e823afa1df83e364381f827f4244bfe29b0ddd58ef0203eb60df9b8c0d123af"
	[x86_64]="0fe3712b54a93695cf4948d9ae171bf5cef038c0e41b364b4e9eb7cb80a60688"
)

# Generate the common license and copyright header
print_legal() {
	cat > $1 <<-EOI
	# (C) Copyright IBM Corporation 2016, 2026
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

	EOI
}

# Generate the license and copyright header for ubi-micro
print_legal_ubi-micro() {
	cat > $1 <<-EOI
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

	EOI
}

# Print the supported Ubuntu OS
print_ubuntu_os() {
	cat >> $1 <<-EOI
	FROM ubuntu:22.04

	EOI
}

# Print the supported UBI Minimal OS
print_ubi-min_os() {
	cat >> $1 <<-EOI
	FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
	EOI
}

# Print the supported UBI Minimal OS
print_ubi_os() {
	cat >> $1 <<-EOI
	FROM registry.access.redhat.com/ubi8/ubi:latest
	EOI
}

# Print the UBI 10 Micro builder stage
print_ubi-micro_os() {
	cat >> $1 <<-EOI
	FROM registry.access.redhat.com/ubi10/ubi-minimal AS builder
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

# Install curl/gzip/tar in the ubi-micro builder stage, then populate a minimal
# /mnt/rootfs with openssl and ca-certificates using --installroot.
print_ubi-micro_pkg() {
	cat >> $1 <<'EOI'

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
LABEL org.opencontainers.image.authors="Jayashree Gopi" \\
    maintainer="jayasg12@in.ibm.com" \\
    name="IBM JAVA" \\
    vendor="IBM" \\
    version=${jver} \\
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

# Print the final stage for ubi-micro (FROM ubi-micro + LABEL + ENV + COPY + USER)
print_ubi-micro_final_stage() {
	srcpkg=$2
	shasums="${srcpkg}"_"${ver}"_sums
	jverinfo=${shasums}[version]
	eval jver=\${$jverinfo}

	if [ "${pack}" == "sdk" ]; then
		JHOME="/opt/ibm/java/jre"
		JPATH="/opt/ibm/java/bin"
	else
		JHOME="/opt/ibm/java/jre"
		JPATH="/opt/ibm/java/jre/bin"
	fi

	cat >> $1 <<-EOI

FROM registry.access.redhat.com/ubi10/ubi-micro

LABEL org.opencontainers.image.authors="Jayashree Gopi" \\
    maintainer="jayasg12@in.ibm.com" \\
    name="IBM JAVA" \\
    vendor="IBM" \\
    version=${jver} \\
    release=${ver} \\
    run="docker run --rm -ti <image_name:tag> /bin/bash" \\
    summary="Image for IBM JAVA with UBI 10 Micro as the base image" \\
    description="This image contains the IBM JAVA with Red Hat UBI 10 MICRO as the base OS.  For more information on this image please see https://github.com/ibmruntimes/ci.docker/blob/master/README.md"

ENV JAVA_VERSION ${jver}

COPY --from=builder /mnt/rootfs /
COPY --from=builder /opt/ibm/java /opt/ibm/java
COPY --from=builder /licenses /licenses

ENV JAVA_HOME=${JHOME} \\
    PATH=${JPATH}:\$PATH \\
    IBM_JAVA_OPTIONS="-XX:+UseContainerSupport"

USER 1001
EOI
}

# OS independent portion (Works for UBI, Alpine and Ubuntu)
# For Java 9 we use jlink to derive the JRE and the SFJ images.
print_java_install() {
	if [ "${os}" == "ubi" -o "${os}" == "ubi-min" -o "${os}" == "ubi-micro" ]; then
		cat >> $1 <<-EOI
       amd64|x86_64) \\
         ESUM='$(sarray=${shasums}[x86_64]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='8.0/${srcpkg}/linux/x86_64/index.yml'; \\
         ;; \\
       ppc64el|ppc64le) \\
         ESUM='$(sarray=${shasums}[ppc64le]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='8.0/${srcpkg}/linux/ppc64le/index.yml'; \\
         ;; \\
       s390x) \\
         ESUM='$(sarray=${shasums}[s390x]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='8.0/${srcpkg}/linux/s390x/index.yml'; \\
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
         YML_FILE='8.0/${srcpkg}/linux/x86_64/index.yml'; \\
         ;; \\
       ppc64el|ppc64le) \\
         ESUM='$(sarray=${shasums}[ppc64le]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='8.0/${srcpkg}/linux/ppc64le/index.yml'; \\
         ;; \\
       s390x) \\
         ESUM='$(sarray=${shasums}[s390x]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='8.0/${srcpkg}/linux/s390x/index.yml'; \\
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
    wget -q -U UA_IBM_JAVA_Docker -O /tmp/ibm-java.tgz ${JAVA_URL}; \
    echo "${ESUM}  /tmp/ibm-java.tgz" | sha256sum -c -; \
    mkdir -p /opt/ibm/java; \
    tar -xf /tmp/ibm-java.tgz -C /opt/ibm/java --strip-components=1; \
    rm -f /tmp/index.yml; \
EOI
	if [ "${os}" == "ubi" -o "${os}" == "ubi-min" -o "${os}" == "ubi-micro" ]; then
		cat >> $1 <<'EOI'
    mkdir -p /licenses; \
    cp /opt/ibm/java/license_en.txt /licenses; \
    chown -R 1001:0 /opt/ibm/java; \
EOI
	fi
	if [ "${os}" == "ubi-min" -o "${os}" == "ubi-micro" ]; then
		cat >> $1 <<'EOI'
    microdnf -y remove shadow-utils; \
    microdnf clean all; \
EOI
	fi

	# For Java 9 JRE, use jlink with the java.se.ee aggregator module.
	if [ "${ver}" == "9" ]; then
		if [ "${dstpkg}" == "jre" ]; then
			JCMD="rm -f /tmp/ibm-java.tgz; \\
    cd /opt/ibm; \\
    ./java/bin/jlink -G --module-path ./java/jmods --add-modules java.se.ee --output jre; \\
    rm -rf java/*; \\
    mv jre java;"

		# For Java 9 SFJ, use jlink with sfj-exclude.txt.
		elif [ "${dstpkg}" == "sfj" ]; then
			JCMD="rm -f /tmp/ibm-java.tgz; \\
    cd /opt/ibm; \\
    ./java/bin/jlink -G --module-path ./java/jmods --add-modules java.activation,java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.naming,java.prefs,java.rmi,java.security.jgss,java.security.sasl,java.sql,java.xml.crypto,java.xml,com.ibm.management --exclude-files=@/tmp/sfj-exclude.txt --output jre; \\
    rm -rf java/* /tmp/sfj-exclude.txt; \\
    mv jre java;"
		else
			JCMD="rm -f /tmp/ibm-java.tgz;"
		fi

	# For other Java versions, nothing to be done.
	else
		JCMD="rm -f /tmp/ibm-java.tgz;"
	fi

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

# Print the main RUN command that installs Java in the ubi-micro builder stage.
# Uses curl (available in the builder) instead of wget.
print_ubi-micro_java_install() {
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
	# Replace wget calls with curl equivalents in the generated Dockerfile
	sed -i \
		-e 's|wget -q -U UA_IBM_JAVA_Docker -O /tmp/index.yml ${BASE_URL}/${YML_FILE};|curl -sL -A "UA_IBM_JAVA_Docker" -o /tmp/index.yml "${BASE_URL}/${YML_FILE}" \&\&|g' \
		-e 's|wget -q -U UA_IBM_JAVA_Docker -O /tmp/ibm-java.tgz ${JAVA_URL};|curl -sL -A "UA_IBM_JAVA_Docker" -o /tmp/ibm-java.tgz "${JAVA_URL}" \&\&|g' \
		"$1"
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
	if [ "${os}" == "ubi-micro" ]; then
		# ubi-micro: env goes into the builder stage only; final stage is printed separately
		print_env ${file} ${srcpkg};
		print_exclude_file ${file} ${srcpkg} ${dstpkg};
		print_ubi-micro_java_install ${file} ${srcpkg} ${dstpkg};
	else
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
	fi
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

generate_ubi-micro() {
	file=$1
	mkdir -p `dirname ${file}` 2>/dev/null
	echo -n "Writing ${file}..."
	print_legal_ubi-micro ${file};
	print_ubi-micro_os ${file};
	print_ubi-micro_pkg ${file};
	generate_java ${file};
	# srcpkg for the final-stage LABEL/ENV computation
	if [ "${ver}" == "9" ]; then
		srcpkg="sdk";
	else
		srcpkg=${pack};
	fi
	print_ubi-micro_final_stage ${file} ${srcpkg};
	echo "done"
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
			if [ "${os}" == "ubuntu" ]; then
				generate_ubuntu ${file}
			elif [ "${os}" == "ubi" ]; then
				generate_ubi ${file}
			elif [ "${os}" == "ubi-min" ]; then
				generate_ubi-min ${file}
			elif [ "${os}" == "ubi-micro" ]; then
				generate_ubi-micro ${file}
			fi
		done
	done
done

