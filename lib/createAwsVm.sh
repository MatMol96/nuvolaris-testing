#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TYPE=${1:?type}
TYPE="$(echo $TYPE | awk -F- '{print $1}')"

STACK=nuvolaris-testing-$TYPE
CONF=$TYPE.cf

aws cloudformation create-stack --stack-name  $STACK --template-body file://conf/$CONF
echo waiting the creation is complete
aws cloudformation wait stack-create-complete --stack-name $STACK

aws ec2 describe-instances  --output json \
    --filters Name=tag:Name,Values=$STACK Name=instance-state-name,Values=running \
    >instance.json

IP=$(cat instance.json | jq -r '.Reservations[].Instances[].PublicIpAddress')
echo $IP >ip.txt

