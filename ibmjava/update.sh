#!/bin/bash
#
# (C) Copyright IBM Corporation 2016, 2017
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
version="8 9"
package="jre sdk sfj"
tools="maven"
arches="i386 ppc64le s390 s390x x86_64"
osver="ubuntu alpine"

# sha256sum for the various versions, packages and arches
# Version 8 sums [DO NO EDIT THIS LINE]
declare -A jre_8_sums=(
	[version]="1.8.0_sr4fp11"
	[i386]="da06a3df4c7ac7e29d9c92f8217e3dc1446c3b76194a99ab3dfb57dd3bcc55cf"
	[ppc64le]="28b3d31b7b9c13dfbd852b11ea06e6a7bf001baa18a68d0869788234dab3dc44"
	[s390]="8e817b4b1950415636b77c00b14795ec9b87d5c225c4897e05c378f6e45615a1"
	[s390x]="a14607e866f08ea19f8a5b571464968a12907369dc68f283c8e0bf1771ffb6ff"
	[x86_64]="b8205bd5700813ef17141a0a7b476846842d86f2b0a7a5fd5176c1edd5dcbe1c"
)

declare -A sdk_8_sums=(
	[version]="1.8.0_sr4fp11"
	[i386]="fc3180000ee745ba11fbcb8c0eda837ccf34830de652c3747682174980c0a466"
	[ppc64le]="bf39ce59310f477d8864134b5d1e8c090ea41a5421c17b6b0eaf5350fdc097bf"
	[s390]="7056455a52d8f753e435d3994ca87c22c496d19d4a06634ba57e4ffc50d0c722"
	[s390x]="89dc14c0bb8199463396f3f71a168e43d61550c7821acee50ec8c3f6ed60a83f"
	[x86_64]="0550e9e44b50ec77cd8774f99051b910816daf3cf275c05438994314ff61d7ee"
)

declare -A sfj_8_sums=(
	[version]="1.8.0_sr4fp11"
	[i386]="d0ff0812eba0dfee8639f11403cf56d9dd16a977a137ecdb7c057459ea943eb2"
	[ppc64le]="f876c556da07575891af0eeb9dc2dc31c718a1614fbdd45aa2e5338f3202f991"
	[s390]="6eb97bc4f807252699b7f3fd578290d6c693e0f8a0e1ea76be898d2929567d21"
	[s390x]="2c729648d8a2b3021d30ee2343d70bd3aa855df2a07e6b0e081ff25ed280b010"
	[x86_64]="4fcd64915fb9dec9e60d5aaaf07958db583312fc86eb95ae3336b5c22cf73a4d"
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
	# (C) Copyright IBM Corporation 2016, 2017
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
	case $arch in
	i386)
		osrepo="i386/ubuntu"
		;;
	x86_64)
		osrepo="ubuntu"
		;;
	s390|s390x)
		osrepo="s390x/ubuntu"
		;;
	ppc64le)
		osrepo="ppc64le/ubuntu"
		;;
	default)
		osrepo="ubuntu"
		;;
	esac
	cat >> $1 <<-EOI
	FROM $osrepo:16.04

	EOI
}

# Print the supported Alpine OS
print_alpine_os() {
	cat >> $1 <<-EOI
	FROM alpine:3.6

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
	if [ "$arch" != "i386" ]; then
		cat >> $1 <<'EOI'

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*
EOI

	else
# For 32bit compatibility on 64bit OS add the following packages
#       lib32z1 lib32ncurses5 lib32bz2 lib32gcc1 \
		cat >> $1 <<'EOI'

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*
EOI

	fi
}

# Select the alpine OS packages.
# Install GNU glibc as J9 needs it, install libgcc_s.so from gcc-libs.tar.xz (archlinux)
print_alpine_pkg() {
	cat >> $1 <<'EOI'

RUN apk --update add --no-cache ca-certificates curl openssl xz \
    && GLIBC_VER="2.25-r0" \
    && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && curl -Ls $ALPINE_GLIBC_REPO/$GLIBC_VER/glibc-$GLIBC_VER.apk > /tmp/$GLIBC_VER.apk \
    && apk add --allow-untrusted /tmp/$GLIBC_VER.apk \
    && curl -Ls https://www.archlinux.org/packages/core/x86_64/gcc-libs/download > /tmp/gcc-libs.tar.xz \
    && mkdir /tmp/gcc \
    && tar -xf /tmp/gcc-libs.tar.xz -C /tmp/gcc \
EOI

	if [ "$ver" == "9" ]; then
		GLIBC_PKGS="&& mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \\"
	else
		GLIBC_PKGS="&& mv /tmp/gcc/usr/lib/libgcc* /usr/glibc-compat/lib \\"
	fi

	cat >> $1 <<-EOI
    $GLIBC_PKGS
    && apk del curl \\
    && rm -rf /tmp/\$GLIBC_VER.apk /tmp/gcc /tmp/gcc-libs.tar.xz /var/cache/apk/*
EOI
}

# Print the Java version that is being installed here
print_env() {
	spkg=$2
	shasums="$spkg"_"$ver"_sums
	jverinfo=${shasums}[version]
	eval JVER=\${$jverinfo}

	cat >> $1 <<-EOI

ENV JAVA_VERSION $JVER

EOI
}

# Print the main RUN command that installs Java.
# For Java 9 we use jlink to derive the JRE and the SFJ images.
print_java_install() {
	spkg=$2
	dpkg=$3
	shasums="$spkg"_"$ver"_sums
	archsum=${shasums}[$arch]
	eval ASUM=\${$archsum}
	cat >> $1 <<-EOI
RUN ESUM="$ASUM" \\
    && BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/" \\
    && YML_FILE="$spkg/linux/$arch/index.yml" \\
EOI
	cat >> $1 <<'EOI'
    && wget -q -U UA_IBM_JAVA_Docker -O /tmp/index.yml $BASE_URL/$YML_FILE \
    && JAVA_URL=$(cat /tmp/index.yml | sed -n '/'$JAVA_VERSION'/{n;p}' | sed -n 's/\s*uri:\s//p' | tr -d '\r') \
    && wget -q -U UA_IBM_JAVA_Docker -O /tmp/ibm-java.bin $JAVA_URL \
    && echo "$ESUM  /tmp/ibm-java.bin" | sha256sum -c - \
    && echo "INSTALLER_UI=silent" > /tmp/response.properties \
    && echo "USER_INSTALL_DIR=/opt/ibm/java" >> /tmp/response.properties \
    && echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties \
    && mkdir -p /opt/ibm \
    && chmod +x /tmp/ibm-java.bin \
    && /tmp/ibm-java.bin -i silent -f /tmp/response.properties \
    && rm -f /tmp/response.properties \
    && rm -f /tmp/index.yml \
EOI

	# For Java 9 JRE, use jlink with the java.se.ee aggregator module.
	if [ "$ver" == "9" ]; then
		if [ "$dpkg" == "jre" ]; then
			JCMD="&& rm -f /tmp/ibm-java.bin \\
    && cd /opt/ibm \\
    && ./java/bin/jlink -G --module-path ./java/jmods --add-modules java.se.ee --output jre \\
    && rm -rf java/* \\
    && mv jre java"

		# For Java 9 SFJ, use jlink with sfj-exclude.txt.
		elif [ "$dpkg" == "sfj" ]; then
			JCMD="&& rm -f /tmp/ibm-java.bin \\
    && cd /opt/ibm \\
    && ./java/bin/jlink -G --module-path ./java/jmods --add-modules java.activation,java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.naming,java.prefs,java.rmi,java.security.jgss,java.security.sasl,java.sql,java.xml.crypto,java.xml,com.ibm.management --exclude-files=@/tmp/sfj-exclude.txt --output jre \\
    && rm -rf java/* /tmp/sfj-exclude.txt \\
    && mv jre java"
		else
			JCMD="&& rm -f /tmp/ibm-java.bin"
		fi

	# For other Java versions, nothing to be done.
	else
		JCMD="&& rm -f /tmp/ibm-java.bin"
	fi

	cat >> $1 <<EOI
    $JCMD
EOI
}

print_java_env() {
	if [ "$pack" == "sdk" ]; then
		if [ "$ver" == "8" ]; then
			JHOME="/opt/ibm/java/jre"
			JPATH="/opt/ibm/java/bin"
		elif [ "$ver" == "9" ]; then
			JHOME="/opt/ibm/java"
			JPATH="/opt/ibm/java/bin"
		fi
	else
		JHOME="/opt/ibm/java/jre"
		JPATH="/opt/ibm/java/jre/bin"
	fi
	TPATH="PATH=$JPATH:\$PATH"

	cat >> $1 <<-EOI

ENV JAVA_HOME=$JHOME \\
    $TPATH
EOI
}

print_exclude_file() {
	spkg=$2
	dpkg=$3
	if [ "$ver" == "9" -a "$dpkg" == "sfj" ]; then
		cp sfj-exclude.txt `dirname $file`
		cat >> $1 <<-EOI
COPY sfj-exclude.txt /tmp

EOI
	fi
}

generate_java() {
	if [ "$ver" == "9" ]; then
		spkg="sdk";
	else
		spkg=$pack;
	fi
	dpkg=$pack;
	print_env $file $spkg;
	print_exclude_file $file $spkg $dpkg;
	print_java_install $file $spkg $dpkg;
	print_java_env $file;
}

generate_ubuntu() {
	file=$1
	mkdir -p `dirname $file` 2>/dev/null
	echo -n "Writing $file..."
	print_legal $file;
	print_ubuntu_os $file;
	print_maint $file;
	print_ubuntu_pkg $file;
	generate_java $file;
	echo "done"
}

generate_alpine() {
	file=$1
	mkdir -p `dirname $file` 2>/dev/null
	echo -n "Writing $file..."
	print_legal $file;
	print_alpine_os $file;
	print_maint $file;
	print_alpine_pkg $file;
	generate_java $file;
	echo "done"
}

# Print the ibmjava image version
print_java() {
	cat >> $1 <<-EOI
	FROM ibmjava:$ver-sdk

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
	mkdir -p `dirname $file` 2>/dev/null
	echo -n "Writing $file..."
	print_legal $file;

	print_java $file;
	print_maint $file;
	print_maven $file;
	echo "done"
}

# Iterate through all the Java versions for each of the supported packages,
# architectures and supported Operating Systems.
for ver in $version
do
	for pack in $package
	do
		for arch in $arches
		do
			for os in $osver
			do
				file=$ver/$pack/$arch/$os/Dockerfile
				# Ubuntu is supported for everything
				if [ "$os" == "ubuntu" ]; then
					generate_ubuntu $file
				elif [ "$os" == "alpine" ]; then
					# Alpine is supported for x86_64 arch only
					if [ "$arch" == "x86_64" ]; then
						generate_alpine $file
					fi
				fi
			done
		done
	done
done

# Iterate through all the build tools.
for ver in $version
do
	for tool in $tools
	do
		file=$ver/$tool/Dockerfile
		generate_maven $file
	done
done
