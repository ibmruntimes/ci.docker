#!/bin/bash
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

meta_dir="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"
echo -n "Downloading the latest index.yml files..."
wget -q -e robots=off --cut-dirs=7 --user-agent=Mozilla/5.0 --reject="index.html*" --no-parent --recursive --relative --level=4 $meta_dir
echo "done"

# If no version provided, look for the latest entry in the x86_64 jre index.yml
if [ -z "$1" ]; then
	yml_file="public.dhe.ibm.com/meta/jre/linux/x86_64/index.yml"
	jvm_version=`awk -F":" '{ print $1 }' $yml_file | grep -v -e "uri" -e "sha256sum" -e "license" -e "---" -e "version" | sort | tail -1`
else
	jvm_version=$1
fi
export jvm_version

echo -n "Locating the shasums for version: $jvm_version..."
rm -rf $jvm_version
mkdir -p $jvm_version/version-info
mv public.dhe.ibm.com $jvm_version
pushd $jvm_version >/dev/null
find . -name "index.yml" -exec cat {} \; | 
		grep -A 2 "$jvm_version" | 
		awk '{ 
				if (match($1, "uri:") > 0) { 
					printf "%s ", $2 
				} else if (match($1, "sha256sum") > 0) { 
					printf "%s\n", $2 
				} 
		}' |
		awk -F"/" '{ print $14 }' | sort | 
		awk -F"-" 'BEGIN { jver=ENVIRON["jvm_version"] }
		    { 
			if (packages != $3) { 
				if (NR != 1) { 
					printf")\n\n" 
				} 
				packages=$3; 
				printf "declare -A %s_8_sums=(\n\t[version]=\"%s\"\n\t[%s]=\"%s\"\n", $3, jver, $6, substr($7,13)
			} else { 
				printf"\t[%s]=\"%s\"\n", $6, substr($7,13) 
			} 
		} END { printf")\n" }' > shasums-$jvm_version.txt
echo "done"

echo
echo "sha256sums for the version: $jvm_version now available in shasums-$jvm_version.txt"
echo

version="8"
package="jre sdk sfj"

machine=`uname -m`
case $machine in
x86_64)
	arches="i386 x86_64"
	;;
s390x)
	arches="s390x"
	;;
ppc64le)
	arches="ppc64le"
	;;
*)
	echo "Unsupported arch:$machine, Exiting"
	exit 1
	;;
esac

echo "INSTALLER_UI=silent" > response.properties
echo "USER_INSTALL_DIR="$PWD"/java-test" >> response.properties
echo "LICENSE_ACCEPTED=TRUE" >> response.properties

echo "Now downloading the JRE binaries for all arches to match sha256sums"
for ver in $version
do
	for package in $package
	do
		for arch in $arches
		do
			yml_file="public.dhe.ibm.com/meta/$package/linux/$arch/index.yml"
			pack_url=`grep -A 1 "$jvm_version" $yml_file | grep "uri:" | awk '{ print $2 }'`
			echo -n "Downloading $package for $arch..."
			wget -q -O ibm-java.bin $pack_url
			echo "done"
			ESUM=`grep -A 6 "$package" shasums-$jvm_version.txt | grep $arch | awk -F '"' '{ print $2 }'`
			echo "$ESUM  ibm-java.bin" | sha256sum -c -
			echo -n "Installing $package for $arch..."
			chmod +x ibm-java.bin
			./ibm-java.bin -i silent -f response.properties
			echo "done"
			echo
			if [ "$arch" == "x86_64" ]; then
				./java-test/jre/bin/java -version 2>&1 | tee version-info/$ver-$package.txt
			else
				./java-test/jre/bin/java -version 2>&1 | tee version-info/$arch-$ver-$package.txt
			fi
			echo
		done
	done
done

# clean up
rm -rf ibm-java.bin java-test public.dhe.ibm.com response.properties shasums-*.txt

popd >/dev/null
