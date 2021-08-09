# Observ platform - terraform deploy

## Prerequisite

- Either one of
    - Azure Cloud Shell
    - Bash with
        - Helm
        - Terraform
- Azure account with permissions

## How to use

```bash
git clone https://github.com/goatwu1993/observ-terraform.git

cd observ-terraform/setups/observ-compose

terraform init

terraform plan -var="image_tag=1.6.0" -out=out.tfplan

... (input some information)

terraform apply "out.tfplan"
```

- Please choose an unique suffix to avoid conflict. Accept lowercase char only.
- Web FCM API is optional

## Developing

### Resource

- Place resources under `main.tf` if not too much.
- If a resource describe it self or only one within module, name it `this`.
- Name is always singular noun
- `count` at start
- `tags` at the 3rd last. Include tags argument, if supported by resource.
- `depends_on` at the 2nd last
- `lifecycle` at the 1st last

### Datas
- Place datas in `main.tf` if not too much. Else place it under `datas.tf`

### Version

- Place versions in `versions.tf`

### Provider
- No `providers.tf` under modules
- Place providers in `providers.tf`

### Variable

- Place variables under `variables.tf`
- Write descriptions.
- No sensitive default value in default.
