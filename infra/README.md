# Infrastructure

Terraform for the `careguide-task` stack in `ap-southeast-1`. Every resource is prefixed and tagged `careguide-task`.

## Apply

Requirements: Terraform 1.10 or later, and an AWS profile allowed to create IAM, EC2, ECR, S3 and SSM resources.

1. Create the state bucket (once per account):

```bash
cd infra/bootstrap
terraform init
terraform apply
```

2. Apply the main stack. Replace `<state_bucket>` with the `state_bucket` output from step 1.

```bash
cd ..
terraform init -backend-config="bucket=<state_bucket>"
terraform plan -out tfplan
terraform apply tfplan
```

If the account already has the GitHub OIDC provider, first put `create_github_oidc_provider = false` in a local `terraform.tfvars`. For a fork, also set `github_oidc_subject_prefix` to the output of:

```bash
gh api repos/<owner>/<repo>/actions/oidc/customization/sub --jq .sub_claim_prefix
```

3. Add these GitHub repository variables, then push to `main`:

| Variable | Value |
|---|---|
| `AWS_ROLE_ARN` | `terraform output -raw github_actions_role_arn` |
| `EC2_INSTANCE_ID` | `terraform output -raw instance_id` |
| `APP_URL` | `terraform output -raw app_url` |

Never commit `tfplan`, `*.tfstate` or `terraform.tfvars`. They contain secrets.

## Evaluator access

`careguide-task-evaluator` has read-only access in `ap-southeast-1`: EC2, ECR (view and pull), SSM run history, CloudWatch metrics and this project's IAM roles. It cannot change anything or read `APP_KEY`.

```bash
terraform output evaluator_console_url
terraform output -raw evaluator_password
terraform output -raw evaluator_access_key_id
terraform output -raw evaluator_secret_access_key
```

The password must be changed at first sign-in. Remove the user after the evaluation with `create_evaluator_user = false`.

## Tear down

```bash
terraform destroy
```
