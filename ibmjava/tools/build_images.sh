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

# Docker Images to be generated
version="8 9"
package="jre sdk sfj"
tools="maven"
osver="ubuntu alpine"

build_failed=0

dver=`docker version 2>/dev/null`
if [ $? != 0 ]; then
	echo "ERROR: Docker command is running in unprivileged mode."
	echo "       Run Docker with sudo privileges or make sure the userid is part of the docker group."
	exit 1
fi

# Supported JRE arches for the machine that we are currently building on
machine=`uname -m`
case $machine in
x86_64)
	# No need for i386 builds for now
	# arches="i386 x86_64"
	arches="x86_64"
	;;
s390x)
	# No support for s390 Docker Images for now, only s390x.
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

baseimage="j9"
rootdir=".."

function timediff() {
	ssec=`date --utc --date "$1" +%s`
	esec=`date --utc --date "$2" +%s`

	diffsec=$(($esec-$ssec))
	echo $diffsec
}

function getdate() {
	date "+%Y-%m-%d %H:%M:%S"
}

function cleanup_logs() {
	echo -n "Removing old log files..."
	find .. -name "*.out" -exec rm -f {} \;
	find .. -name "*.err" -exec rm -f {} \;
	echo "done"
}

function build_image() {
	image_name=$1
	logfile=$2

	echo "Building $image_name from $file..."
	# Start all the builds parallely
	(docker build --no-cache -t $image_name . 2> $logfile.err 1> $logfile.out) &
}

function check_build_status() {
	num_building=`find $rootdir -name "*.out" | wc -l`
	num_built=`find $rootdir -name "*.out" -exec grep "Successfully built" {} \; | wc -l`
	num_running=$(($num_building-$num_built))
	builds_running=`ps -ef | grep "docker" | grep "build" | grep -v grep | wc -l`

	if [ $num_built -ne $num_building ]; then
		num_error=`find $rootdir -name "*.err" -exec ls -l {} \; | \
				awk '{ print $5 }' | grep -v "0" | wc -l`
		if [ $num_running -ne $builds_running ] || [ $num_error -ne 0 ]; then
			printf "(%02d) build(s) failed, Some builds may still be running\n" "$num_error"
		else
			printf "%02d(t):%02d(c), build(s) ongoing\n" "$num_building" "$num_built"
		fi
	else
		# We are done here, report success
		printf "%02d(t):%02d(c), build(s) successful\n" "$num_building" "$num_built"
	fi
}

function wait_for_build_complete() {
	echo
	sleep 2
	status=$(check_build_status)
	while [[ "$status" == *"build(s) ongoing"* ]];
	do
		echo "Status = $status"
		sleep 10
		status=$(check_build_status)
	done
	edate=$(getdate)
	tdiff=$(timediff "$sdate" "$edate")
	if [[ "$status" == *"build(s) failed"* ]]; then
		build_failed=1
	fi
	echo
	echo "############################################"
	echo "Status    : $status"
	printf "Time taken: %02d:%02d mins\n" "$((tdiff/60))" "$((tdiff%60))"
	echo "############################################"
	echo
}

cleanup_logs

echo
echo "Starting ibmjava docker image builds in parallel..."
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
				file="$rootdir/$ver/$pack/$arch/$os/Dockerfile"
				if [ ! -f $file ]; then
					continue;
				fi
				ddir=`dirname $file`
				logfile=`basename $file`
				pushd $ddir >/dev/null
				if [ "$os" != "ubuntu" ]; then
					ostag=$pack-$os
				else
					ostag=$pack
				fi
				if [ "$arch" == "x86_64" ]; then
					image_name=$baseimage:$ver-$ostag
				elif [ "$arch" == "i386" ]; then
					image_name=$arch/$baseimage:$ver-$ostag
				else
					image_name=$machine/$baseimage:$ver-$ostag
				fi
				build_image $image_name $logfile
				popd >/dev/null
			done
		done
	done
done

wait_for_build_complete

if [ $build_failed -eq 1 ]; then
	echo
	echo "Not building tool images as earlier builds failed"
	exit -1;
fi

echo
echo "Starting maven docker image builds in parallel..."
sdate=$(getdate)
for ver in $version
do
	for tool in $tools
	do
		if [ "$arch" == "x86_64" ]; then
			file="$rootdir/$ver/$tool/Dockerfile"
			if [ ! -f $file ]; then
				continue;
			fi
			ddir=`dirname $file`
			logfile=`basename $file`
			pushd $ddir >/dev/null
			image_name=$baseimage:$ver-$tool
			build_image $image_name $logfile
			popd >/dev/null
		fi
	done
done

wait_for_build_complete
