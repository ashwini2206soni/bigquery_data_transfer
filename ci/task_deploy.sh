#!/bin/sh

set -e
cd terraform


# move concourse parameters into files for terraform consumption
echo "${GCP_CREDENTIALS}" > credentials.json
# echo "${AWS_AKI}" 
# echo "${AWS_SAK}"

echo "==> Init <=="
terraform init \
    -input=false \
    -no-color 
    
echo `ls `
echo "==> Plan <=="
terraform plan \
    -var-file=./default.tfvars \
    -input=false \
    -var "access_key_id=${AWS_AKI}" \
    -var "secret_access_key=${AWS_SAK}" \ 
    -no-color \
    -detailed-exitcode
    

echo "==> Apply <=="
terraform apply \
    -var-file=default.tfvars \
    -var "access_key_id=${AWS_AKI}" \
    -var "secret_access_key=${AWS_SAK}" \ 
    -input=false \
    -no-color
echo "==> Done <=="
