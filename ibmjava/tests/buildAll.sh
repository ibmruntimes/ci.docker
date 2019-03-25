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
#####################################################################################
#                                                                                   #
#  Script to build docker image and test all images                                 #
#                                                                                   #
#                                                                                   #
#  Usage : buildAll.sh input.txt                                                    #
#                                                                                   #
#####################################################################################

filename="$1"
while read -r line
do
    image=`echo $line | cut -d " " -f1`
    location=`echo $line  | cut -d " " -f2`
    ./build.sh $image $location && ./verify.sh $image

    if [ $? != 0 ]
    then
        echo " No point in continuing, exiting ........"
        exit 1
    fi

done < "$filename"
