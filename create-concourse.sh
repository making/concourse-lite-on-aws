#!/bin/bash

export PUBLIC_IP=$(cat terraform.tfstate | jq -r '.modules[0].outputs.external_ip.value')
export INTERNAL_CIDR=$(cat terraform.tfstate | jq -r '.modules[0].outputs.internal_cidr.value')
export INTERNAL_GW=$(cat terraform.tfstate | jq -r '.modules[0].outputs.internal_gw.value')
export INTERNALIP=$(cat terraform.tfstate | jq -r '.modules[0].outputs.concourse_internal_ip.value')
export VNET_NAME=$(cat terraform.tfstate | jq -r '.modules[0].outputs.vnet_name.value')
export SUBNET_NAME=$(cat terraform.tfstate | jq -r '.modules[0].outputs.subnet_name.value')
export SECURITY_GROUP_NAME=$(cat terraform.tfstate | jq -r '.modules[0].outputs.concourse_security_group.value')
export STORAGE_ACCOUNT_NAME=$(cat terraform.tfstate | jq -r '.modules[0].outputs.storage_account_name.value')
export DEFAULT_SECURITY_GROUP=$(cat terraform.tfstate | jq -r '.modules[0].outputs.concourse_security_group.value')
export REGION=$(cat terraform.tfstate | jq -r '.modules[0].outputs.region.value')
export AVAILABILITY_ZONE=$(cat terraform.tfstate | jq -r '.modules[0].outputs.az.value')
export SUBNET_ID=$(cat terraform.tfstate | jq -r '.modules[0].outputs.subnet_id.value')
export VPC_ID=$(cat terraform.tfstate | jq -r '.modules[0].outputs.vpc_id.value')
export ACCESS_KEY_ID=$(cat terraform.tfstate | jq -r '.modules[0].outputs.concourse_iam_user_access_key.value')
export SECRET_ACCESS_KEY=$(cat terraform.tfstate | jq -r '.modules[0].outputs.concourse_iam_user_secret_key.value')
export DEFAULT_KEY_NAME=$(cat terraform.tfstate | jq -r '.modules[0].outputs.default_key_name.value')
export PRIVATE_KEY=$(cat terraform.tfstate | jq -r '.modules[0].outputs.private_key.value')

export CONCOURSE_DEPLOYMENT=./concourse-bosh-deployment

bosh create-env ${CONCOURSE_DEPLOYMENT}/lite/concourse.yml \
  -o ${CONCOURSE_DEPLOYMENT}/lite/infrastructures/aws.yml \
  -o ${CONCOURSE_DEPLOYMENT}/lite/jumpbox.yml \
  -o <(sed 's|name=web|name=concourse|g' ${CONCOURSE_DEPLOYMENT}/cluster/operations/tls.yml) \
  -o <(sed 's|name=web|name=concourse|g' ${CONCOURSE_DEPLOYMENT}/cluster/operations/privileged-https.yml) \
  -o <(sed 's|name=web|name=concourse|g' ${CONCOURSE_DEPLOYMENT}/cluster/operations/basic-auth.yml) \
  -o <(cat <<EOF
- type: replace
  path: /resource_pools/0/cloud_properties/instance_type
  value: t2.medium
- type: replace
  path: /networks/-
  value:
    name: public
    type: vip
- type: replace
  path: /instance_groups/name=concourse/networks/-
  value:
    name: public
    static_ips: [((public_ip))]
- type: replace
  path: /cloud_provider/ssh_tunnel/host
  value: ((public_ip))
- type: replace
  path: /instance_groups/name=concourse/jobs/name=atc/properties/external_url
  value: https://((public_ip))
- type: replace
  path: /instance_groups/name=concourse/jobs/name=atc/properties/basic_auth_password?
  value: ((admin_password))
- type: replace
  path: /variables/-
  value:
    name: admin_password
    type: password
EOF) \
  -o ${CONCOURSE_DEPLOYMENT}/cluster/operations/tls-vars.yml \
  -l ${CONCOURSE_DEPLOYMENT}/versions.yml \
  --vars-store concourse-creds.yml \
  -v public_ip=${PUBLIC_IP} \
  -v az=${AVAILABILITY_ZONE} \
  -v subnet_id=${SUBNET_ID} \
  -v access_key_id=${ACCESS_KEY_ID} \
  -v secret_access_key=${SECRET_ACCESS_KEY} \
  -v default_key_name=${DEFAULT_KEY_NAME} \
  -v default_security_groups="[${DEFAULT_SECURITY_GROUP}]" \
  -v region=${REGION} \
  --var-file private_key=<(cat <<EOF
${PRIVATE_KEY}
EOF
) \
  -v internal_cidr=${INTERNAL_CIDR} \
  -v internal_gw=${INTERNAL_GW} \
  -v internal_ip=${INTERNALIP} \
  -v atc_basic_auth.username=admin \
  --state concourse-state.json \
  
