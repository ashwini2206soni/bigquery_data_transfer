#!/bin/sh

set -e



# move concourse parameters into files for terraform consumption
echo "${GCP_CREDENTIALS}" > credentials.json
echo "${AWS_AKI}" 
echo "${AWS_SAK}"
export TF_VAR_access_key_id=$AWS_AKI
export TF_VAR_secret_access_key=$AWS_SAK


echo "==> Init <=="
terraform init \
    -input=false \
    -no-color \
    ./terraform
    
echo `ls `
echo "==> Plan <=="
terraform plan \
    -var-file="terraform/default.tfvars" \
    -input=false \
    -no-color \
    -detailed-exitcode \
    ./terraform
    
echo "==> Apply <=="
terraform apply \
    -var-file=terraform/default.tfvars \
    -input=false \
    -no-color \
    ./terraform
echo "==> Done <=="
