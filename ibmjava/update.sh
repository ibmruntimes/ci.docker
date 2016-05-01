#!/bin/sh
#
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
set -eo pipefail

# Dockerfiles to be generated
version="8"
package="jre sdk"
arches="i386 ppc64le s390 s390x x86_64"
osver="ubuntu alpine"

# sha256sum for the various versions, packages and arches
declare -A jre_8_sums=( 
                     [version]="1.8.0_sr3"
                     [i386]="18d42c79df9515e014955fe291829113b2b07d5051a1a0165a8bd05fbea2245c"
                     [ppc64le]="4fabb9490b47686a49d8a55005df6cc5f9c67bb42b98d689eba6289b394b2ba9"
                     [s390]="5ccb5512e6815858f3a86feac6dfb76ec394524f49126a9cd8cc5ade11335af9"
                     [s390x]="3681b30faf63a1bc4f58b3d578342e542c323d226a6123c6b10937945960534d"
                     [x86_64]="b34f89078048ba0ac650bf56c06331028a71d505c65743383623d94ca29f2c4e"
                   )

declare -A sdk_8_sums=( 
                     [version]="1.8.0_sr3"
                     [i386]="bbfea245c371bdeee18564214e7468f15d372cc9e38f1c8189350a81c3386b19"
                     [ppc64le]="a45f1b8fbfabb0f5942bd33f136a0a9e8db5cff61302cf62dd58820298eb2dbf"
                     [s390]="a9de0f2fbb92f79be0f068936ed8f2d8e5140e47b6146cdd9941c63f39a80ee7"
                     [s390x]="9fe2d86935254de2d2fd2411e2e31232fa8245628674f45b068fa83200f029ec"
                     [x86_64]="8f2f3cada3809fe4f9d0d6da14bd089739cd5d0e419c8051e2b483c653f73b6b"
                   )

# Generate the common license and copyright header
print_legal() {
	cat > $1 <<-EOI
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

	EOI
}

# Print the supported Ubuntu OS
print_ubuntu_os() {
	case $arch in
	i386|x86_64)
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
	FROM $osrepo:14.04

	EOI
}

# Print the supported Alpine OS
print_alpine_os() {
	cat >> $1 <<-EOI
	FROM alpine:3.3

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
		cat >> $1 <<'EOI'

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
       lib32z1 lib32ncurses5 lib32bz2-1.0 lib32gcc1 \
    && rm -rf /var/lib/apt/lists/*
EOI

	fi
}

alpine_glibc_repo="https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/"

# Select the alpine OS packages
print_alpine_pkg() {
	cat >> $1 <<-EOI

RUN apk --update add curl wget ca-certificates tar \\
    && ln -s /lib /lib64 \\
    && curl -Ls $alpine_glibc_repo/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk \\
    && apk add --allow-untrusted /tmp/glibc-2.21-r2.apk \\
    && apk --update add xz \\
    && curl -Ls https://www.archlinux.org/packages/core/x86_64/gcc-libs/download > /tmp/gcc-libs.tar.gz \\
    && tar -xvf /tmp/gcc-libs.tar.gz -C /
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
    && echo "$ESUM /tmp/ibm-java.bin" | sha256sum -c - \
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
    && echo "INSTALLER_UI=silent" > /tmp/response.properties \
    && echo "USER_INSTALL_DIR=/opt/ibm/java" >> /tmp/response.properties \
    && echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties \
    && mkdir -p /opt/ibm \
    && chmod +x /tmp/ibm-java.bin \
    && /tmp/ibm-java.bin -i silent -f /tmp/response.properties \
    && rm -f /tmp/response.properties \
    && rm -f /tmp/index.yml \
    && rm -f /tmp/ibm-java.bin \
    && rm -f /tmp/gcc-libs.tar.gz \
    && rm -f /tmp/glibc-2.21-r2.apk
EOI
}

print_java_env() {
	cat >> $1 <<'EOI'

ENV JAVA_HOME=/opt/ibm/java/jre \
    PATH=/opt/ibm/java/jre/bin:$PATH
EOI
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
				# Ubuntu is supported for everything
				if [ "$os" == "ubuntu" ]; then 
					echo -n "Writing $file..."
					print_legal $file;
					print_ubuntu_os $file;
					print_maint $file;
					print_ubuntu_pkg $file;
					print_env $file;
					print_ubuntu_main_run $file;
					print_java_env $file;
					echo "done"
				fi
				# Alpine is supported for x86_64 and JRE package only
				if [ "$os" == "alpine" -a "$arch" == "x86_64" ]; then
					if [ "$pack" == "jre" ]; then 
						echo -n "Writing $file..."
						print_legal $file;
						print_alpine_os $file;
						print_maint $file;
						print_alpine_pkg $file;
						print_env $file;
						print_alpine_main_run $file;
						print_java_env $file;
						echo "done"
					fi
				fi
			done
		done
	done
done
