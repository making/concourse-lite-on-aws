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
  -o <(sed 's|/instance_groups/name=web|/instance_groups/name=concourse|g' ${CONCOURSE_DEPLOYMENT}/cluster/operations/tls.yml) \
  -o <(sed 's|/instance_groups/name=web|/instance_groups/name=concourse|g' ${CONCOURSE_DEPLOYMENT}/cluster/operations/privileged-https.yml) \
  -o ${CONCOURSE_DEPLOYMENT}/cluster/operations/tls-vars.yml \
  -o <(cat <<EOF
# - type: replace
#   path: /resource_pools/0/cloud_properties/instance_type
#   value: m4.large
# - type: replace
#   path: /resource_pools/0/cloud_properties/spot_bid_price?
#   value: 0.0340
- type: replace
  path: /resource_pools/0/cloud_properties/instance_type
  value: t2.medium
- type: replace
  path: /resource_pools/0/cloud_properties/spot_bid_price?
  value: 0.0190
- type: replace
  path: /resource_pools/0/cloud_properties/spot_ondemand_fallback?
  value: true
- type: replace
  path: /resource_pools/name=vms/cloud_properties/ephemeral_disk
  value: 
    size: 30_000
    type: standard
- type: replace
  path: /disk_pools/name=disks/cloud_properties/type?
  value: standard
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
  path: /instance_groups/name=concourse/jobs/name=web/properties/external_url
  value: https://((public_ip))
- type: replace
  path: /variables/name=atc_tls/options/alternative_names/0
  value: ((public_ip))
- type: replace
  path: /variables/-
  value:
    name: admin_password
    type: password
- type: replace
  path: /instance_groups/name=concourse/jobs/name=web/properties/main_team?/auth/local/users
  value:
  - admin
- type: replace
  path: /instance_groups/name=concourse/jobs/name=web/properties/add_local_users?
  value:
  - admin:((admin_password))
- type: remove
  path: /releases/name=garden-runc
- type: replace
  path: /releases/name=bpm?
  value:
    name: bpm
    version: ((bpm_version))
    sha1: ((bpm_sha1))
    url: https://bosh.io/d/github.com/cloudfoundry-incubator/bpm-release?v=((bpm_version))
- type: replace
  path: /instance_groups/name=concourse/jobs/name=bpm?
  value:
    name: bpm
    release: bpm
    properties: {}
- type: replace
  path: /resource_pools/name=vms/stemcell
  value: 
    url: https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-xenial-go_agent?v=170.38
    sha1: c42f5de98fc6419f341af1732ff0c1e885a25227
EOF) \
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
  -v external_url="https://((public_ip))" \
  --var-file private_key=<(cat <<EOF
${PRIVATE_KEY}
EOF
) \
  -v internal_cidr=${INTERNAL_CIDR} \
  -v internal_gw=${INTERNAL_GW} \
  -v internal_ip=${INTERNALIP} \
  -v atc_basic_auth.username=admin \
  --state concourse-state.json \
  $@
  
