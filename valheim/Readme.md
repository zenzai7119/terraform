# Terrafrom Valheim multiplay server

## Usage
- init
```
# vi ~/.bashrc
export SAKURACLOUD_ACCESS_TOKEN=xxx
export SAKURACLOUD_ACCESS_TOKEN_SECRET=xxx
export TF_VAR_password=xxx
export ANSIBLE_CONFIG=$(pwd)
export VHPASSWORD=xxx
```

- create
```
# terraform init
# terraform validate
# terraform apply
```

- destroy
```
# terraform destroy
```