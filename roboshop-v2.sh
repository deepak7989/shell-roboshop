#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z06143913AWT2Y6NPPAQL" # Replace with ur zone id
DOMAIN_NAME="deep90s.online" # Replace with ur domain name
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

### Validation ###
if [ $# -lt 2 ]; then
    echo -e "$R ERROR:: Atleast 2 arguments required $N"
    echo "USAGE: $0 [create/delete] [instance1] [instance2...]"
    exit 1
fi

ACTION=$1
shift # First argument will be removed

if [ $ACTION -ne "create" ] && [ $ACTION -ne "delete" ]; then
    echo -e "$R ERROR:: First argument must be either create or delete"
    echo "USAGE: $0 [create/delete] [instance1] [instance2...]"
    exit 1
fi