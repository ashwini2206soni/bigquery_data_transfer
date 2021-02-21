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
    -no-color \
    

echo "==> Plan <=="
terraform plan \
    -out=main.tfplan \
    -input=false \
    -var "access_key_id=${AWS_AKI}" \
    -var "secret_access_key=${AWS_SAK}" \
    -no-color 
    

echo "==> Apply <=="
terraform apply \
    -input=false \
    -no-color \
    -var-file=default.tfvars \ 
    main.tfplan
echo "==> Done <=="
