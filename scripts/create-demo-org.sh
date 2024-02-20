#!/bin/bash

set -e

# Scratch org alias should not be empty
if [ -z "$1" ]
then
    echo "You should pass demo org alias as the first param"
    exit 0
fi

ORG_ALIAS=$1

# Create a new scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias "$ORG_ALIAS"

# Framework source code deployment
sf project deploy start --ignore-conflicts --target-org "$ORG_ALIAS"

# Install demo metadata
sf project deploy start --source-dir demo --target-org "$ORG_ALIAS"

# Granting the SF Admin the necessary permissions
sf org assign permset --name Sfinx_App --target-org "$ORG_ALIAS"
sf org assign permset --name Logs_Administration --target-org "$ORG_ALIAS"

# Open scratch org
sf org open --target-org "$ORG_ALIAS"
