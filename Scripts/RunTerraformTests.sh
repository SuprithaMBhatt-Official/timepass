#!/bin/bash

#Lets's change dir
cd ../dev/
terraform init
terraform apply -input=false -auto-approve
