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

dhe_meta="https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/"
packages="jre"
arches="x86_64"

function gen_index() {
	ifile=$1
	ofile=$2
	cat $ifile | grep -e "^1." -e "uri:" | \
	awk 'BEGIN { printf "---\n" }
		 {
		   if (match($1, "uri:") != 0) {
			 printf("%s\n", $2);
		   } else {
			 printf("%s ", $1);
		   }
		 }' > $ofile
}

for pack in $packages
do
	for arch in $arches
	do
		ofile=$pack/linux/$arch/index.yml
		echo -n "Writing $ofile..."
		mkdir -p `dirname $ofile` 2>/dev/null
		wget -q -O index-tmp.yml $dhe_meta/$ofile
		gen_index index-tmp.yml $ofile
		rm -f index-tmp.yml
		echo "done"
	done
done
