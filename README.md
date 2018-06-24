# Deploy Concourse-Lite on Aws

```
cp terraform.tfvars.sample terraform.tfvars
```

Configure your azure environment in `terraform.tfvars`.


```
terraform init
terraform plan -out plan
terraform apply plan
```

```
./create-concourse.sh
```

```
echo "Go to https://$(cat terraform.tfstate | jq -r '.modules[0].outputs.external_ip.value')"
```
