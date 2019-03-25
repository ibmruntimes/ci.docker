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
#  Script to verify a IBM® SDK, Java™ Technology Edition                            #
#                                                                                   #
#                                                                                   #
#  Usage : verify.sh <Image name>                                                   #
#                                                                                   #
#####################################################################################

image=$1
arch=`echo $image | cut -d "/" -f1`

if [ "$arch" == "i386" ]; then
	tag=$arch-`echo $image | cut -d ":" -f2`
else
	tag=`echo $image | cut -d ":" -f2`
fi

testJavaVersion()
{
   docker run --rm $image java -version 2>testvers.log
   comparison=$(diff -u testvers.log "$PWD/version-info/$tag.txt")

   if [ $? != 0 ]
   then
      rm -f testvers.log
      echo "Incorrect version, exiting"
      echo "$comparison"
      exit 1
   fi
   rm -f testvers.log
}

testHelloWorld()
{
   helloOutput=$(docker run --rm -v $PWD/hw:/opt/app $image java -jar /opt/app/hello.jar)
   comparison=$(diff -u <(echo "$helloOutput") "$PWD/hw/hello.txt")

   if [ $? != 0 ]
   then
      echo "Incorrect output, exiting"
      echo "$comparison"
      exit 1
   fi
}

tests=$(declare -F | cut -d" " -f3 | grep "test")
for name in $tests
do
   echo "*** $name - Executing"
   eval $name
   echo "*** $name - Completed successfully"
done
