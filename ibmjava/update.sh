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
	[version]="1.8.0_sr3fp22"
	[i386]="b3e0d6d3e12cd642d791a711fcd6e125127d7bf0733515d4707f03e4033f84de"
	[ppc64le]="3e975dc5610358f5843b890867a2cd0be6d6f714be19865fb1a701d8739d770b"
	[s390]="eb075cec66cdd94f5a606ade5eee48396d805ebf9417952eeeb2864c45d81181"
	[s390x]="aed93cc1776c10f6ca721d93224ce5feb05f9efdf5eec539a5cdde0f858ee379"
	[x86_64]="ec96d978612fd3981bae382a745669544280cdd7eaaa55fadfbd7a26aa447b25"
)

declare -A sdk_8_sums=(
	[version]="1.8.0_sr3fp22"
	[i386]="090efbea7fc8324c434eaecdc680079ffece7cf69d90980708c73368bd6d31f7"
	[ppc64le]="2eb37f5392f8dd4df4fd5ca874a81ce06cab93c7ff7000b537476accd8e5b727"
	[s390]="9c3bb9c2d9858b960434784949e1d8190c9ca8d9f9da17a612bc1412de71813c"
	[s390x]="766a8bbe482861bfdcbeeeb47de84616fba36efa5012fea5130300e00d52f6cd"
	[x86_64]="7ea96e282eebb31c32b9b42a017a80f49ea2a0eb5f0f40b96ea3c8ee89b2ea60"
)

declare -A sfj_8_sums=(
	[version]="1.8.0_sr3fp22"
	[i386]="cafcac4c96ae4e185ea6b94b765ba87a6dfe6284f57bd0df723f449155bb0fc9"
	[ppc64le]="70691e0c7982fdbbd60fd39d45f48e5839867878bba133c546ffac93773747e4"
	[s390]="d718b1fb9b17fbc5c817bb287bf190d420fc3ad97238d65ac08703bdb989cf93"
	[s390x]="c5fa236a11f1a770bd3e6b109b1ac32bdfadb2452d3de68dd88929caacbe1181"
	[x86_64]="6b63ed16b0f0cdc71da6d478a383e1896c132725a7c5a959310985c3549f6c75"
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
    && ln -s /lib /lib64 \
    && GLIBC_VER="2.23-r3" \
    && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && wget -q -O /tmp/$GLIBC_VER.apk $ALPINE_GLIBC_REPO/$GLIBC_VER/glibc-$GLIBC_VER.apk \
    && apk add --allow-untrusted /tmp/$GLIBC_VER.apk \
    && apk --update add xz \
    && wget -q -O /tmp/gcc-libs.tar.xz https://www.archlinux.org/packages/core/x86_64/gcc-libs/download \
    && tar -xvJf /tmp/gcc-libs.tar.xz -C /tmp usr/lib/libgcc_s.so.1 usr/lib/libgcc_s.so \
    && mv /tmp/usr/lib/libgcc* /usr/glibc-compat/lib \
    && rm -rf /tmp/$GLIBC_VER.apk /tmp/usr /tmp/gcc-libs.tar.xz /var/cache/apk/*
EOI
}

# Print the Java version that is being installed here
print_env() {
	shasums="$pack"_"$ver"_sums
	jverinfo=${shasums}[version]
	eval JVER=\${$jverinfo}

	cat >> $1 <<-EOI

ENV JAVA_VERSION $JVER

EOI
}

# Print
print_ubuntu_main_run() {
	shasums="$pack"_"$ver"_sums
	archsum=${shasums}[$arch]
	eval ASUM=\${$archsum}
	cat >> $1 <<-EOI
RUN ESUM="$ASUM" \\
    && BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/" \\
    && YML_FILE="$pack/linux/$arch/index.yml" \\
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
    && rm -f /tmp/ibm-java.bin
EOI
}

print_alpine_main_run() {
	shasums="$pack"_"$ver"_sums
	archsum=${shasums}[$arch]
	eval ASUM=\${$archsum}
	cat >> $1 <<-EOI
RUN ESUM="$ASUM" \\
    && BASE_URL="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/" \\
    && YML_FILE="$pack/linux/$arch/index.yml" \\
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
    && rm -f /tmp/ibm-java.bin
EOI
}

print_java_env() {
if [ "$pack" == "sdk" ]; then
	if [ "$ver" == "8" ]; then
		cat >> $1 <<'EOI'

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/bin:$PATH
EOI
	elif [ "$ver" == "9" ]; then
		cat >> $1 <<'EOI'

ENV JAVA_HOME=/opt/ibm/java \
    PATH=/opt/ibm/java/bin:$PATH
EOI
	fi
else
	cat >> $1 <<'EOI'

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH
EOI
fi
}

generate_ubuntu() {
	file=$1
	mkdir -p `dirname $file` 2>/dev/null
	echo -n "Writing $file..."
	print_legal $file;
	print_ubuntu_os $file;
	print_maint $file;
	print_ubuntu_pkg $file;
	print_env $file;
	print_ubuntu_main_run $file;
	print_java_env $file;
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
	print_env $file;
	print_alpine_main_run $file;
	print_java_env $file;
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
				file=$ver-$pack/$arch/$os/Dockerfile
				if [ "$ver" == "8" ]; then
					# Ubuntu is supported for everything
					if [ "$os" == "ubuntu" ]; then
						generate_ubuntu $file
					elif [ "$os" == "alpine" ]; then
						# Alpine is supported for x86_64 arch and JRE and SFJ packages only
						if [ "$arch" == "x86_64" ] && [ "$pack" == "jre" -o "$pack" == "sfj" ]; then
							generate_alpine $file
						fi
					fi
				elif [ "$ver" == "9" ]; then
					# For now Java 9 betas images are only available for SDK
					if [ "$os" == "ubuntu" -a "$pack" == "sdk" ]; then
						generate_ubuntu $file
					fi
				fi
			done
		done
	done
done
