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
arches="i386 ppc64le s390 s390x x86_64"
osver="ubuntu alpine"

# sha256sum for the various versions, packages and arches
declare -A jre_8_sums=(
	[version]="1.8.0_sr4fp1"
	[i386]="759f03c969f0feffdb2b395fa8876ea1b750db90bed0688f8d10ce97e33348df"
	[ppc64le]="1b0e5f3e0d95367836d7a0bdb30314dd6a820df06ef4eb6d160014cf57ea4b30"
	[s390]="7ba77b232149ac5188b33f81b365173d0570cf044d41b5a493eddcab92de159b"
	[s390x]="990e5472d22fff69c2d862b1ee38056cb1dd127043b2173da81a3e93e63959d0"
	[x86_64]="1f8e4b9c0d03457703c17d54d1ac939696fe8d027da57d47a347833d8cafdc90"
)

declare -A sdk_8_sums=(
	[version]="1.8.0_sr4fp1"
	[i386]="02588e0494f5d091a9e0602e054af2d733f1fd01432192b5733fb95be4c8e964"
	[ppc64le]="81ee611d981f0edd60f0ca5543aebcd93a73ef6f40aeda01a48a337661fb85e6"
	[s390]="610e7a6d5bef62f53fa0057598b441c37d2e8a023fd40d91d5698b73ff9a783b"
	[s390x]="c09151dc9111636145525267569632287ed5f4788cfda43da3a444d4fafad183"
	[x86_64]="2b4377c4a8b6934a17ee8e2ec673b4a3d3b97f0b568ef5e20a6ea2e676345bf3"
)

declare -A sfj_8_sums=(
	[version]="1.8.0_sr4fp1"
	[i386]="737b4e3dc317cfe8c45512eddf3a520c9bf30a4aef902c415e89572e74c394e0"
	[ppc64le]="d99393379775541da45f2d71f97584a146c9a3a15b8646ab03d9bed439aaa4e0"
	[s390]="b86bc776aee9d83344d6f0ca8d4df053d69383e766651f6351a276ca251f0e13"
	[s390x]="6d5ef74d4d19120ed0e88df54036d51ec5ee13e3d9fafa9c4bb818706439904e"
	[x86_64]="e37d585c7e7df77065254ed866bc8db367e74720eea4507774d891b943c6428f"
)

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
