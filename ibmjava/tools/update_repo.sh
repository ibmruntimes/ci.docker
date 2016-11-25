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
set -o pipefail

function usage() {
	echo
	echo "Usage: $0 [-h] [-l] [-n] [-v <8>] [-s source_repo] [-t <ibmcom|ppc64le|s390x>]"
	echo " l = use local source, n = no push to remote. "
	exit 1
}

dver=`docker version 2>/dev/null`
if [ $? != 0 ]; then
	echo "ERROR: Docker command is running in unprivileged mode."
	echo "       Run Docker with sudo privileges or make sure the userid is part of the docker group."
	exit 1
fi

machine=`uname -m`
version="8"
packages="sfj jre sdk"
push_repo="ibmjava"

nopush=0

# Setup defaults for source and target repos based on the current machine arch.
case $machine in
x86_64)
	source_repo="j9"
	tprefix="ibmcom"
	remote=0
	;;
s390x)
	source_repo="s390x/j9"
	tprefix="s390x"
	# No remote repos to pull from for s390x
	remote=0
	;;
ppc64le)
	source_repo="ppc64le/j9"
	tprefix="ppc64le"
	# No remote repos to pull from for ppc64le
	remote=0
	;;
default)
	echo "Unsupported arch:$machine. Exiting"
	exit
	;;
esac

while getopts hlns:t:v: opts
do
	case $opts in
	l)
		# Use local repo instead of pulling from remote source.
		remote=0
		;;
	n)
		# Do not push to remote.
		nopush=1
		;;
	s)
		# Use provided source repo to pull from.
		source_repo="$OPTARG"
		;;
	t)
		# Push to given target PREFIX
		tprefix="$OPTARG"
		[[ tprefix == "ibmcom" || tprefix == "ppc64le" || tprefix == "s390x" ]] || usage
		;;
	v)
		# Update only provided version
		version="$OPTARG"
		((version == 8)) || usage
		;;
	*)
		usage
	esac
done
shift $(($OPTIND-1))

logfile=sync-$tprefix-$$.log
target_repo=$tprefix/$push_repo

function log {
	echo -e $@ 2>&1 | tee -a $logfile
}

log
if [ $remote -eq 1 ]; then
	log "####[I]: Push Java $version docker images from $source_repo to $target_repo"
else
	log "####[I]: Push Java $version docker images from local to $target_repo"
fi
log

function checkFail() {
	if [ $? != 0 ]; then
		log $@
		exit 1
	fi
}

function retag() {
	stag=$1
	ttag=$2

	# Check if the target images are existing locally and if so, remove them.
	image=`docker images | grep "$target_repo" | awk '{ print $2 }' | grep "^$ttag$"`
	if [ "$image" != "" ]; then
		log -n "####[I]: [$target_repo:$ttag]: Deleting old image with tag [$ttag]..."
		docker rmi $target_repo:$ttag >> $logfile 2>&1
		log "done"
	fi
	# Create the target image locally with the appropriate tag from the source.
	log -n "####[I]: [$source_repo:$stag]: Tagging image as [$target_repo:$ttag]..."
	docker tag $source_repo:$stag $target_repo:$ttag >> $logfile 2>&1
	log "done"
}

function push_target() {
	ttag=$1

	if [ $nopush -eq 0 ]; then
		log
		# Push the target images to the remote
		log "####[I]: [$target_repo:$ttag]: Pushing image to hub.docker..."
		docker push $target_repo:$ttag >> $logfile 2>&1
		checkFail "####[E]: [$target_repo:$ttag]: Image push failed, check the target repository provided.\n" \
				  "####[E]: Are you logged-in,  does your userid have push authorization?"
		log "####[I]: [$target_repo:$ttag]: Image pushed successfully."
		log
	fi
}

function get_source_image() {
	repo=$1
	stag=$2

	# If source is remote, pull images from remote, else check if image is available locally.
	if [ $remote -eq 1 ]; then
		log -n "####[I]: [$repo:$stag]: Pulling image..."
		docker pull $repo:$stag >> $logfile 2>&1
		checkFail "\n####[E]: [$repo:$stag]: Pulling image failed, exiting..."
		log "done"
	else
		log -n "####[I]: [$repo:$stag]: Checking for image locally..."
		image=`docker images | grep "$repo" | awk '{ print $2 }' | grep "^$stag$"`
		if [ "$image" == "" ]; then
			log "\n####[E]: [$repo:$stag]: Image not found locally, exiting..."
			exit 1
		fi
		log "found"
	fi
}

function update_target() {
	version=$1
	package=$2
	tag=$1-$2
	
	# Download the source image with the given tag locally. 
	get_source_image $source_repo $tag

	# Create target images locally with the tags, $tag and $package for all (JRE, SDK & SFJ).
	retag $tag $tag
	retag $tag $package

	# Push it to the remote repo.
	push_target $tag
	push_target $package

	# For JRE alone push images with $version and latest tags.
	if [ $package == "jre" ]; then
		retag $tag $version
		retag $tag latest

		push_target $version
		push_target latest
	fi

	# Pull, create and push Alpine images on x86_64 for both JRE and SFJ.
	if [ $machine == "x86_64" ]; then
		if [ $package == "jre" -o $package == "sfj" ]; then
			get_source_image $source_repo $tag-alpine

			retag $tag-alpine $tag-alpine
			retag $tag-alpine $package-alpine

			push_target $tag-alpine
			push_target $package-alpine
		fi
	fi
}

# Update remote target repo for all packages.
for pack in $packages
do
	update_target $version $pack
done

log
log "See $logfile for more details"
