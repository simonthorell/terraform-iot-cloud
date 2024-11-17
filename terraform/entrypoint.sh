#!/bin/bash
terraform init
terraform apply -auto-approve
tail -f /dev/null