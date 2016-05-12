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

# Docker Images to be generated
version="8"
package="jre sdk sfj"
arches="i386 ppc64le s390 s390x x86_64"
osver="ubuntu alpine"

machine=`uname -m`

function timediff() {
	ssec=`date --utc --date "$1" +%s`
	esec=`date --utc --date "$2" +%s`

	diffsec=$(($esec-$ssec))
	echo $diffsec
}

function getdate() {
	date "+%Y-%m-%d %H:%M:%S"
}

function build_image() {
	echo "Building $image_name from $file..."
	# Start all the builds parallely
	(docker build --no-cache -t $image_name . 2> $logfile.err 1> $logfile.log) &
}

function check_build_status() {
	num_building=`find . -name "Dockerfile.log" | wc -l`
	num_built=`find . -name "Dockerfile.log" -exec grep "Successfully built" {} \; | wc -l`

	if [ $num_built != $num_building ]; then
		num_error=`find . -name "Dockerfile.err" -exec ls -l {} \; | awk '{ print $5 }' | grep -v "0" | wc -l`
		if [ $num_error != 0 ]; then
			echo "($num_error) build(s) failed"
		else
			echo "$num_building(t):$num_built(c), build(s) ongoing"
		fi
	else
		# We are done here, report success
		echo "$num_building(t):$num_built(c), build(s) successful"
	fi
}

# Iterate through all the Dockerfiles and build the right ones
sdate=$(getdate)
for ver in $version
do
	for pack in $package
	do
		for arch in $arches
		do
			for os in $osver
			do
				file=$ver-$pack/$arch/$os/Dockerfile
				if [ ! -f $file ]; then
					continue;
				fi
				ddir=`dirname $file`
				logfile=`basename $file`
				pushd $ddir >/dev/null
				if [ "$arch" == "x86_64" ]; then
					if [ "$os" != "ubuntu" ]; then
						image_name=ibmjava:$ver-$pack-$os
					else
						image_name=ibmjava:$ver-$pack
					fi
				else
					if [ "$os" != "ubuntu" ]; then
						image_name=$arch/ibmjava:$ver-$pack-$os
					else
						image_name=$arch/ibmjava:$ver-$pack
					fi
				fi
				# Only build images for the arch that we are currently running on
				case $machine in
				x86_64)
					if [ "$arch" == "x86_64" -o "$arch" == "i386" ]; then
						build_image;
					fi
					;;
				s390x)
					if [ "$arch" == "s390" -o "$arch" == "s390x" ]; then
						build_image;
					fi
					;;
				ppc64le)
					if [ "$arch" == "ppc64le" ]; then
						build_image;
					fi
					;;
				esac
				popd >/dev/null
			done
		done
	done
done

status=$(check_build_status)
while [[ "$status" == *"build(s) ongoing"* ]];
do
	echo "Status = $status"
	status=$(check_build_status)
	sleep 5
done
edate=$(getdate)
tdiff=$(timediff "$sdate" "$edate")
echo
echo "##########################################"
echo "Status    : $status"
echo "Time taken: $((tdiff/60)):$((tdiff%60)) mins"
echo "##########################################"
echo
