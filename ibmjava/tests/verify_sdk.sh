#!/bin/bash
#
# (C) Copyright IBM Corporation 2016, 2019
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

function usage() {
	echo
	echo "Usage: $0 [-h] [-v <'8'|9>] [-u <Y|n>]"
	echo " h = help. "
	echo " u = update y/n? "
	echo " v = version of binaries to push. "
	echo
	exit 1
}

export version="8"
package="jre sdk sfj"
update="y"

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

while getopts hv: opts
do
	case $opts in
	v)
		# Update only provided version
		major_ver="$OPTARG"
		((major_ver == 8 || major_ver == 9)) || usage
		export version="$major_ver"
		;;
	u)
		update="$OPTARG"
		;;
	*)
		usage
	esac
done
shift $(($OPTIND-1))

function get_full_version_from_meta_info() {
	meta_dir="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"
	echo -n "Downloading the latest index.yml files..."
	wget -q -e robots=off --cut-dirs=7 --user-agent=Mozilla/5.0 --reject="index.html*" --no-parent --recursive --relative --level=5 $meta_dir
	echo "done"
	# Look for the latest entry in the x86_64 sdk index.yml for the major version provided
	yml_file="public.dhe.ibm.com/meta/8.0/sdk/linux/x86_64/index.yml"
	export full_version=`awk -F":" '{ print $1 }' $yml_file | grep -e "^$version" | sort -V | tail -1`
	echo "Latest full version for major version $version is: $full_version"
}

function get_shasums() {
	echo -n "Locating the shasums for version: $full_version..."
	find . -type f -path '*/8.0/*' -name "index.yml" -exec cat {} \; | 
			grep -A 2 "$full_version" | 
			awk '{ 
					if (match($1, "uri:") > 0) { 
						printf "%s ", $2 
					} else if (match($1, "sha256sum") > 0) { 
						printf "%s\n", $2 
					} 
			}' |
			awk -F"/" '{ print $11,$13,$14 }' |
			awk '{ printf"%s %s %s %s\n", substr($3, 10, 3), $1, $2, $4 }' | sort |
			awk 'BEGIN { fver=ENVIRON["full_version"]; mver=ENVIRON["version"]; }
				{ 
				if (packages != $1) { 
					if (NR != 1) { 
						printf")\n\n" 
					} 
					packages=$1; 
					printf "declare -A %s_%s_sums=(\n\t[version]=\"%s\"\n\t[%s]=\"%s\"\n", $1, mver, fver, $3, $4
				} else { 
					printf"\t[%s]=\"%s\"\n", $3, $4 
				} 
			} END { printf")\n" }' > $sumsfile
	echo "done"

	echo
	echo "sha256sums for the version: $full_version now available in $sumsfile"
	echo
}

function match_shasums() {
	echo "INSTALLER_UI=silent" > response.properties
	echo "USER_INSTALL_DIR="$PWD"/java-test" >> response.properties
	echo "LICENSE_ACCEPTED=TRUE" >> response.properties

	echo "Now downloading the JRE binaries for all arches to match sha256sums"
	for pkg in $package
	do
		for arch in $arches
		do
			yml_file="public.dhe.ibm.com/meta/8.0/$pkg/linux/$arch/index.yml"
			pack_url=`grep -A 1 "$full_version" $yml_file | grep "uri:" | awk '{ print $2 }'`
			rm -f ibm-java.bin
			echo -n "Downloading $pkg for $arch..."
			wget -q -O ibm-java.bin $pack_url
			echo "done"
			ESUM=`grep -A 6 "$pkg" shasums-$full_version.txt | grep $arch | awk -F '"' '{ print $2 }'`
			echo "$ESUM  ibm-java.bin" | sha256sum -c -
			echo -n "Installing $pkg for $arch..."
			chmod +x ibm-java.bin
			./ibm-java.bin -i silent -f response.properties
			echo "done"
			echo
			if [ "$arch" == "x86_64" ]; then
				./java-test/jre/bin/java -version 2>&1 | tee version-info/$version-$pkg.txt
				# Alpine version will be the same as the ubuntu one.
				cp version-info/$version-$pkg.txt version-info/$version-$pkg-alpine.txt
			else
				./java-test/jre/bin/java -version 2>&1 | tee version-info/$arch-$version-$pkg.txt
			fi
			echo
		done
	done
	echo "Verfication done."
}

function update_sums() {
	echo -n "Updating..."
	sed -e '/'"$version"'_sums=/,/)/ d' -i $update_file
	sed -e '/# Version '"$version"' sums / {' -e 'r '"$sumsfile"'' -e '}' -i $update_file
	sed 'N;/^\n$/d;P;D' -i $update_file
	cp version-info/* $verinfodir
	echo "done"
}

function update_yml() {
	pushd $metadir >/dev/null
	./gen-index.sh
	popd >/dev/null
}

rootdir="$PWD/../"
update_file=$rootdir/update.sh
verinfodir="$rootdir/tests/version-info/"
metadir="$rootdir/meta"

echo "Getting latest shasum info for major version: $version"
get_full_version_from_meta_info
rm -rf $full_version
mkdir -p $full_version/version-info
mv public.dhe.ibm.com $full_version
sumsfile=shasums-$full_version.txt

pushd $full_version >/dev/null
get_shasums
match_shasums
var_bump=`echo $update | awk '{ print toupper($1) }'`
if [ "$var_bump" == "Y" ]; then
	update_sums
	update_yml
fi
# clean up
rm -rf ibm-java.bin java-test public.dhe.ibm.com response.properties
popd >/dev/null
