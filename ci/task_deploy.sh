#!/bin/sh

set -e
cd terraform


# move concourse parameters into files for terraform consumption
echo "${GCP_CREDENTIALS}" > credentials.json
echo "${AWS_AKI}" 
echo "${AWS_SAK}"

echo "==> Init <=="
terraform init \
    -input=false \
    -no-color \
    ./terraform

echo "==> Plan <=="
terraform plan \
    -out=main.tfplan \
    -input=false \
    -var-file=terraform/default.tfvars \
    -var "access_key_id=${AWS_AKI}" \
    -var "secret_access_key=${AWS_SAK}" \
    -no-color \
    ./terraform

echo "==> Apply <=="
terraform apply \
    -input=false \
    -no-color \
    main.tfplan
echo "==> Done <=="
