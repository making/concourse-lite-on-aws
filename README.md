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

> how to interpolate
> ```
> eval "$(cat create-concourse.sh | grep -v state.json | sed 's/create-env/interpolate/g')"
> ```

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
cat <<'EOF' > hello.yml
jobs:
- name: hello-world
  plan:
  - task: say-hello
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: ubuntu
      params:
        MY_SECRET: ((my-secret))
      run:
        path: bash
        args:
        - -c
        - |
          set -e
          echo "MY_SECRET=${MY_SECRET}"
EOF
```

```
fly -t lite sp -p hello -c hello.yml
fly -t lite up -p hello
```

```
credhub login -s $CONCOURSE_URL:8844 -u admin -p $ADMIN_PASSWORD --skip-tls-validation
credhub set -t value -v pa33w0rd  -n /concourse/main/my-secret
```

```
fly -t lite tj -j hello/hello-world -w
```

```
cat <<EOF > ssh-concourse.sh
bosh int concourse-creds.yml --path /jumpbox_ssh/private_key > concourse.pem
chmod 600 concourse.pem

ssh -o "StrictHostKeyChecking=no" jumpbox@$(cat terraform.tfstate | jq -r '.modules[0].outputs.external_ip.value') -i $(pwd)/concourse.pem
EOF
chmod +x ssh-concourse.sh
```

> how to destroy
> ```
> eval "$(cat ./create-concourse.sh | sed 's/create-env/delete-env/g')"
> ```
