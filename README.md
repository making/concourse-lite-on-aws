# Deploy Concourse-Lite on Aws

```
cp terraform.tfvars.sample terraform.tfvars
```

Configure your aws environment in `terraform.tfvars`.


```
terraform init
terraform plan -out plan
terraform apply plan
```

```
./create-concourse.sh
```

```
CONCOURSE_URL=https://$(terraform output --json | jq -r .external_ip.value)
ADMIN_PASSWORD=$(bosh int concourse-creds.yml --path /admin_password)

cat <<EOF
url: $CONCOURSE_URL
username: admin
password: $ADMIN_PASSWORD
EOF
```

```
fly -t lite login -k -c $CONCOURSE_URL -u admin -p $ADMIN_PASSWORD
```

```
cat <<EOF > ssh-concourse.sh
bosh int concourse-creds.yml --path /jumpbox_ssh/private_key > concourse.pem
chmod 600 concourse.pem

ssh -o "StrictHostKeyChecking=no" jumpbox@$(cat terraform.tfstate | jq -r '.modules[0].outputs.external_ip.value') -i $(pwd)/concourse.pem
EOF
chmod +x ssh-concourse.sh
```
