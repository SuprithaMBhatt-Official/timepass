#!/bin/bash

cd ../dev/
terraform init
terraform apply -input=false -auto-approve