#!/bin/bash
#
# (C) Copyright IBM Corporation 2016, 2018
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
tools="maven"
arches="i386 ppc64le s390 s390x x86_64"
osver="ubuntu alpine rhel"

# sha256sum for the various versions, packages and arches
# Version 8 sums [DO NO EDIT THIS LINE]
declare -A jre_8_sums=(
	[version]="1.8.0_sr5fp22"
	[i386]="7b0b974147d5301c7d4622ee4946f45407018bbadb2ca6f8cacb25aac290e63b"
	[ppc64le]="7025b86b9fafc9c4586cf07e46c02b51267b3e3cdc1b5ad2122c6d378d6b3466"
	[s390]="535d37c66db76a846422720659781c9f950fcb25c36a580abe283879eb0a252e"
	[s390x]="70a42483ef89959ace0bf168ec1795875ac98d9bee5f7a4c300c6dc03968e34e"
	[x86_64]="e8debbf6ce880c5b2792283a3e3162d5ce8bdd80f98b6f24f38e08d4774c331c"
)

declare -A sdk_8_sums=(
	[version]="1.8.0_sr5fp22"
	[i386]="da3c6dcb264508a29a505567f58c49c77594d5a6102a7e678f5b35aff79549fc"
	[ppc64le]="51d53f86d79f5d1fd16a7ed11b305f140aa1b0946221f307334f310312e9f2b6"
	[s390]="17436a485322009b9d402a977a7fef9e6d14a062665e13f7a21962a695f6c989"
	[s390x]="6635bebc3108d0210eef7c75b76b7d3944d163b2374522fcd22570288d602a13"
	[x86_64]="5be5205ef921b9269bd7f84cf93322aeac2dbcf08536fdf38b1dd2036f8911b9"
)

declare -A sfj_8_sums=(
	[version]="1.8.0_sr5fp22"
	[i386]="1025b2ac347fc0961297eed075ffac36d94bb44458b0326bcf601a3f75248da4"
	[ppc64le]="baf60399c147326270e2c68c5a533fed2148f480284f537fbf7ca9069dca0053"
	[s390]="555878d2a7a49b73a5d244770b535292d9affc38ab4e4adcc55961ce271bef33"
	[s390x]="8582f1bcce1c12edcfbbbf810c002eca12de0446803c967f4a88299f6bd49403"
	[x86_64]="e9e179ad118cebf5ca5cd98b73c72dc04d8f725c4dc7f9fd19e90b7981d32289"
)

# Version 9 sums [DO NO EDIT THIS LINE]
declare -A sdk_9_sums=(
	[version]="1.9.0_ea2"
	[i386]="5add39cc5ca56b97cf8ce71b9e1a15d19d36864aaed1e0296f50355ba3f34bd5"
	[ppc64le]="3c0dda9f449a667d12fe5f59a1ec059a90a9dc483fd35eef5ff53dd8b096cdf5"
	[s390]="8d06af57d8236839f5c403c12dcf4c89e22dd91716a4d26b85c8d92f6d1e2e8b"
	[s390x]="6e823afa1df83e364381f827f4244bfe29b0ddd58ef0203eb60df9b8c0d123af"
	[x86_64]="0fe3712b54a93695cf4948d9ae171bf5cef038c0e41b364b4e9eb7cb80a60688"
)

# Generate the common license and copyright header
print_legal() {
	cat > $1 <<-EOI
	# (C) Copyright IBM Corporation 2016, 2018
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
	FROM ubuntu:16.04

	EOI
}

# Print the supported Alpine OS
print_alpine_os() {
	cat >> $1 <<-EOI
	FROM alpine:3.7

	EOI
}

# Print the supported RHEL OS
print_rhel_os() {
	cat >> $1 <<-EOI
	FROM registry.access.redhat.com/rhel7

	EOI
}

# Print the maintainer
print_maint() {
	cat >> $1 <<-EOI
	MAINTAINER Dinakar Guniguntala <dinakar.g@in.ibm.com> (@dinogun)
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

# Select the alpine OS packages.
# Install GNU glibc as J9 needs it, install libgcc_s.so from gcc-libs.tar.xz (archlinux)
print_alpine_pkg() {
	cat >> $1 <<'EOI'

RUN apk --update add --no-cache binutils ca-certificates openssl wget xz \
    && GLIBC_VER="2.25-r0" \
    && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && wget -q -O /tmp/${GLIBC_VER}.apk ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && apk add --allow-untrusted /tmp/${GLIBC_VER}.apk \
    && wget -q -O /tmp/gcc-libs.tar.xz https://www.archlinux.org/packages/core/x86_64/gcc-libs/download \
    && mkdir /tmp/gcc \
    && tar -xf /tmp/gcc-libs.tar.xz -C /tmp/gcc \
    && mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \
    && strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* \
    && apk del binutils wget \
    && rm -rf /tmp/${GLIBC_VER}.apk /tmp/gcc /tmp/gcc-libs.tar.xz /var/cache/apk/*
EOI
}

# Select the rhel OS packages
print_rhel_pkg() {
	cat >> $1 <<'EOI'

RUN yum makecache fast \
    && yum update -y \
    && yum -y install openssl wget ca-certificates \
    && yum clean packages \
    && yum clean headers \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /var/tmp/yum-*

EOI
}

# Print the Java version that is being installed here
print_env() {
	srcpkg=$2
	shasums="${srcpkg}"_"${ver}"_sums
	jverinfo=${shasums}[version]
	eval jver=\${$jverinfo}

	cat >> $1 <<-EOI

ENV JAVA_VERSION ${jver}

EOI
}

# OS independent portion (Works for both Alpine and Ubuntu)
# For Java 9 we use jlink to derive the JRE and the SFJ images.
print_java_install() {
	cat >> $1 <<-EOI
       amd64|x86_64) \\
         ESUM='$(sarray=${shasums}[x86_64]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='${srcpkg}/linux/x86_64/index.yml'; \\
         ;; \\
       i386) \\
         ESUM='$(sarray=${shasums}[i386]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='${srcpkg}/linux/i386/index.yml'; \\
         ;; \\
       ppc64el|ppc64le) \\
         ESUM='$(sarray=${shasums}[ppc64le]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='${srcpkg}/linux/ppc64le/index.yml'; \\
         ;; \\
       s390) \\
         ESUM='$(sarray=${shasums}[s390]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='${srcpkg}/linux/s390/index.yml'; \\
         ;; \\
       s390x) \\
         ESUM='$(sarray=${shasums}[s390x]; eval esum=\${$sarray}; echo ${esum})'; \\
         YML_FILE='${srcpkg}/linux/s390x/index.yml'; \\
         ;; \\
       *) \\
         echo "Unsupported arch: \${ARCH}"; \\
         exit 1; \\
         ;; \\
    esac; \\
    BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"; \\
EOI
	cat >> $1 <<'EOI'
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
EOI

	# For Java 9 JRE, use jlink with the java.se.ee aggregator module.
	if [ "${ver}" == "9" ]; then
		if [ "${dstpkg}" == "jre" ]; then
			JCMD="rm -f /tmp/ibm-java.bin; \\
    cd /opt/ibm; \\
    ./java/bin/jlink -G --module-path ./java/jmods --add-modules java.se.ee --output jre; \\
    rm -rf java/*; \\
    mv jre java;"

		# For Java 9 SFJ, use jlink with sfj-exclude.txt.
		elif [ "${dstpkg}" == "sfj" ]; then
			JCMD="rm -f /tmp/ibm-java.bin; \\
    cd /opt/ibm; \\
    ./java/bin/jlink -G --module-path ./java/jmods --add-modules java.activation,java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.naming,java.prefs,java.rmi,java.security.jgss,java.security.sasl,java.sql,java.xml.crypto,java.xml,com.ibm.management --exclude-files=@/tmp/sfj-exclude.txt --output jre; \\
    rm -rf java/* /tmp/sfj-exclude.txt; \\
    mv jre java;"
		else
			JCMD="rm -f /tmp/ibm-java.bin;"
		fi

	# For other Java versions, nothing to be done.
	else
		JCMD="rm -f /tmp/ibm-java.bin;"
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

# Print the main RUN command that installs Java on alpine.
print_alpine_java_install() {
	srcpkg=$2
	dstpkg=$3
	shasums="${srcpkg}"_"${ver}"_sums
	cat >> $1 <<'EOI'
RUN set -eux; \
    apk --no-cache add --virtual .build-deps wget; \
    ARCH="$(apk --print-arch)"; \
    case "${ARCH}" in \
EOI
	print_java_install ${file} ${srcpkg} ${dstpkg};
	sed '$s/$/ \\\n    apk del .build-deps;/' -i "$1"
}

# Print the main RUN command that installs Java on rhel.
print_rhel_java_install() {
	srcpkg=$2
	dstpkg=$3
	shasums="${srcpkg}"_"${ver}"_sums
	cat >> $1 <<'EOI'
RUN set -eux; \
    ARCH="$(arch)"; \
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
elif [ "${os}" == "alpine" ]; then
		print_alpine_java_install ${file} ${srcpkg} ${dstpkg};
elif [ "${os}" == "rhel" ]; then
		print_rhel_java_install ${file} ${srcpkg} ${dstpkg};
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
	echo "done"
}

generate_rhel() {
	file=$1
	mkdir -p `dirname ${file}` 2>/dev/null
	echo -n "Writing ${file}..."
	print_legal ${file};
	print_rhel_os ${file};
	print_maint ${file};
	print_rhel_pkg ${file};
	generate_java ${file};
	echo "done"
}

# Print the ibmjava image version
print_java() {
	cat >> $1 <<-EOI
	FROM ibmjava:${ver}-sdk

	EOI
}

#
print_maven() {
	cat >> $1 <<'EOI'

ARG MAVEN_VERSION=3.3.9

RUN mkdir -p /usr/share/maven \
    && BASE_URL="http://apache.osuosl.org/maven/maven-3" \
    && wget -q -O /tmp/maven.tar.gz $BASE_URL/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    && tar -xzC /usr/share/maven --strip-components=1 -f /tmp/maven.tar.gz \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

CMD ["/usr/bin/mvn"]
EOI
}

generate_maven() {
	file=$1
	mkdir -p `dirname $file}` 2>/dev/null
	echo -n "Writing ${file}..."
	print_legal ${file};

	print_java ${file};
	print_maint ${file};
	print_maven ${file};
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
			# Ubuntu is supported for everything
			if [ "${os}" == "ubuntu" ]; then
				generate_ubuntu ${file}
			elif [ "${os}" == "alpine" ]; then
				generate_alpine ${file}
			elif [ "${os}" == "rhel" ]; then
				generate_rhel ${file}
			fi
		done
	done
done

# Iterate through all the build tools.
for ver in ${version}
do
	for tool in ${tools}
	do
		file=${ver}/${tool}/Dockerfile
		generate_maven ${file}
	done
done
