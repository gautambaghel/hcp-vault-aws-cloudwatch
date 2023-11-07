# hcp-vault-aws-cloudwatch
Configure HCP Vault audit logs streaming to AWS CloudWatch

HCP Vault log streaming can be sent many places, but AWS CloudWatch is an
easy one to set up. Follow [this tutorial](https://developer.hashicorp.com/vault/tutorials/cloud-monitoring/vault-audit-log-cloudwatch) to learn more

## Prerequisites
- You will need an [HCP Vault cluster](https://developer.hashicorp.com/vault/tutorials/cloud/get-started-vault), on Standard Tier or above.
- You will need an [AWS account](https://aws.amazon.com/resources/create-account/) with access to create AWS CloudWatch resources.

## Setup Steps

1. Authenticate with AWS

Authenticate with AWS from the command line:

```bash

```

1. Clone this repository

```bash
git clone https://github.com/gautambaghel/hcp-vault-aws-cloudwatch.git
```

1. Set appropriate Terraform variables

Use the `example.tfvars` file to create a `terraform.tfvars`, and add the relevant email address, HCP org ID & HCP project ID.

1. Run Terraform

```bash
terraform init
terraform apply
```

1. Retrieve AWS access keys

```bash
terraform output id
terraform output -raw secret
```

Once the access keys are created, follow the instructions [here](https://developer.hashicorp.com/vault/tutorials/cloud-monitoring/vault-audit-log-cloudwatch#enable-audit-logs-streaming)
