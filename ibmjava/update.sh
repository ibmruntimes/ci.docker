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
declare -A sdk_9_sums=(
        [version]="1.9.0_ea2"
        [i386]="5add39cc5ca56b97cf8ce71b9e1a15d19d36864aaed1e0296f50355ba3f34bd5"
        [ppc64le]="3c0dda9f449a667d12fe5f59a1ec059a90a9dc483fd35eef5ff53dd8b096cdf5"
        [s390]="8d06af57d8236839f5c403c12dcf4c89e22dd91716a4d26b85c8d92f6d1e2e8b"
        [s390x]="6e823afa1df83e364381f827f4244bfe29b0ddd58ef0203eb60df9b8c0d123af"
        [x86_64]="0fe3712b54a93695cf4948d9ae171bf5cef038c0e41b364b4e9eb7cb80a60688"
)

declare -A jre_8_sums=(
	[version]="1.8.0_sr4fp6"
	[i386]="211990d9b1ae697f31a8efed75fe55a6cc8fa4a60b067da68a772358e9aed31b"
	[ppc64le]="ec4183a09fd1e2b83463cf0795f7e85bc45dbddff08ed40f355fa3803e4f29da"
	[s390]="fff9c2871e19664217c736eb3bc92d98b9ff3d6084980080947562b4025d5e40"
	[s390x]="93260c4b8aacce25f3fbcf4f0a020102ea1c91053be75129d9f6876cd81ce633"
	[x86_64]="1d60fb97c4c30c7209b4792d22d0d4a9a6239db97adc647413bad722cada535c"
)

declare -A sdk_8_sums=(
	[version]="1.8.0_sr4fp6"
	[i386]="bb5e117294b6394a6f87822c6a6e4cc71b3313bf847207dc3ebbf6a9dade711a"
	[ppc64le]="8e9d8220f6ed0bf525436ee6bb263cc27928f2795742198442c479ae71cff9d3"
	[s390]="7a373740218f3a8e37672967efce2f07cdd668c89267b8b5cf2d92e2bd1d33fc"
	[s390x]="23682613bc09c3ab48c724e2c9fda3554007f670b6b495129b1a603d6604957c"
	[x86_64]="d5b1f62eb8db7ce1ccf80165cd27c3c4e21d3ccf5c86dbd6b1df81b2b7947371"
)

declare -A sfj_8_sums=(
	[version]="1.8.0_sr4fp6"
	[i386]="2e77fb857fc407416ed69ed7ebc3fb5744d677236370b529f00e25dd0abb9596"
	[ppc64le]="c80f0a8d0d5ccca66f860cab5159920a32a157d4aba43ada20d3f4c36a5a3157"
	[s390]="34c41506d8b836abcce27a54a7eb3ab1d4c71da211d9e22ab9bd200b281de8ff"
	[s390x]="02ab3de0fd033f49b10b6fc1cf2046ef92fcbc6d548d65824121d51498148ac7"
	[x86_64]="67a5d790e414c230382d534b7df251d9341d2a4996b39a5081e6333d22ef38e4"
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
	FROM alpine:3.4

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

RUN apk --update add --no-cache openssl ca-certificates \
    && GLIBC_VER="2.23-r3" \
    && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && wget -q -O /tmp/$GLIBC_VER.apk $ALPINE_GLIBC_REPO/$GLIBC_VER/glibc-$GLIBC_VER.apk \
    && apk add --allow-untrusted /tmp/$GLIBC_VER.apk \
    && apk --update add xz \
    && wget -q -O /tmp/gcc-libs.tar.xz https://www.archlinux.org/packages/core/x86_64/gcc-libs/download \
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
					# Alpine is supported for x86_64 arch and JRE and SFJ packages only
					if [ "$arch" == "x86_64" ] && [ "$pack" == "jre" -o "$pack" == "sfj" ]; then
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
