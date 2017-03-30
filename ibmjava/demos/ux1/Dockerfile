#!/bin/bash
#
# (C) Copyright IBM Corporation 2017, 2017
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
FROM ibmcom/ibmjava:8-sfj-alpine

ARG app_name=SampleApp

ADD $app_name /opt/app

WORKDIR /opt/app

# Set IBM Java specific options to ensure the best Bluemix experience
ENV JAVA_OPTS="-Xtune:virtualized"

CMD ["sh","target/bin/webapp"]
