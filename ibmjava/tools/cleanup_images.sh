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
	echo "Usage: $0 [fclean]"
	exit 1
}

args=$1
[[ "$args" == "" || "$args" == "fclean" ]] || usage

echo -n "Removing all containers that have exited..."
docker ps -q -a | xargs docker rm 2>/dev/null
echo "done"

echo -n "Removing all images that are not being used..."
docker rmi $(docker images | grep "^<none>" | awk '{ print $3 }') 2>/dev/null
echo "done"

# Remove all ibmjava images in anticipation for a full build or a pull from remote.
if [ "$args" == "fclean" ]; then
	echo -n "Removing all ibmjava images in anticipation for a full build or a pull from remote..."
	docker rmi -f $(docker images | grep "ibmjava" | awk '{ print $3 }' | uniq) 2>/dev/null
	echo "done"
fi
