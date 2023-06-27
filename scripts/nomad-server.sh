#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
USER_NAME="${1}"
NAME="nomadserver"
LOGPATH="/var/log/${NAME}"
PIDPATH="/var/run/${NAME}"
PIDFILE="${PIDPATH}/${NAME}.pid"

cd "/opt/nomad-server/nomad/terraform"
#################################################################
#                   TERRAFORM COMMANDS                          #
################################################################
echo "Creating starup jobs on nomad"
terraform init -reconfigure -upgrade 
terraform apply -auto-approve