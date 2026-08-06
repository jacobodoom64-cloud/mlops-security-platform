# MLOps Security Platform

A CI/CD pipeline on AWS that deploys a containerised inference endpoint, with a hard separation between the stage that can read infrastructure and the stage that can change it.

Region: `eu-north-1`. Status: pipeline working end to end, live endpoint responding. Model is currently a placeholder.

## What this does

Push to `main` → the pipeline runs `terraform plan` plus two security scanners under a read-only role → a human reviews the plan and scan output → a separately-scoped role builds a container image, pushes it to a scanned registry, and applies the exact plan that was reviewed.

The result is an HTTP endpoint backed by a Lambda function running from a container image tagged with the git commit that produced it.

```bash
curl -X POST https://<api-id>.execute-api.eu-north-1.amazonaws.com/predict \
  -H "Content-Type: application/json" \
  -d '{"text": "hello"}'

{"status": "ok", "message": "Placeholder handler - no model loaded yet", "received_text": "hello"}
```

## Why it's built this way

Most CI/CD pipelines give the build job whatever permissions it needs to finish the job, which usually means broad write access. If that job is ever compromised — a bad dependency, a malicious pull request, a script bug — the blast radius is the whole account.

This pipeline splits into a read-only stage and a write-access stage with a human checkpoint between them. The read-only stage can compute what would change and flag misconfigurations. Every write API call it could make returns `AccessDenied`, because the role has no write verbs at all. Only the stage behind the approval gate can modify anything, and it applies the saved plan binary rather than re-planning, so what deploys is exactly what was reviewed.

## Architecture

```
GitHub push (main)
      │
      ▼
┌─────────────┐
│   Source    │  CodeStar GitHub App connection
└─────────────┘
      │
      ▼
┌─────────────┐
│    Scan     │  read-only IAM role
│             │  terraform plan → tfplan.binary
│             │  tfsec, checkov
└─────────────┘
      │
      ▼
┌─────────────┐
│  Approval   │  human reviews plan + scan output
└─────────────┘
      │
      ▼
┌─────────────┐
│   Deploy    │  write-access IAM role
│             │  docker build → push to ECR
│             │  terraform apply tfplan.binary
└─────────────┘
      │
      ▼
API Gateway → Lambda (container image) → response
```

### Repository layout

The pipeline does not manage its own infrastructure. That separation is enforced by two independent Terraform state files:

`bootstrap/` writes to `project1/bootstrap.tfstate`. `workload/` writes to `project1/workload.tfstate`. The pipeline only ever touches the second one, so it structurally cannot modify the CodeBuild projects, IAM roles, or artifacts bucket it depends on.

## IAM role separation

**`mlops-codebuild_role`** — the scan stage. CloudWatch logging, read/write on the artifacts bucket and state file, and `Get`/`List`/`Describe` verbs across the resource types in state. No create, modify, or delete permission on any AWS resource.

**`mlops-codebuild-deploy-role`** — the deploy stage. Scoped by name prefix: S3 buckets matching `mlops-security-platform-*`, IAM roles matching `mlops-*`, ECR repositories and Lambda functions matching `mlops-*`.

**`mlops-lambda-inference-role`** — the Lambda execution role. Its only permission is writing to log groups under `/aws/lambda/mlops-*`.

Where a policy uses `Resource = "*"`, it is because AWS does not support resource-level restrictions for that action — `ec2:Describe*`, `logs:DescribeLogGroups`, `ecr:GetAuthorizationToken`, and the log delivery actions.

## Security controls in place

- Read-only scan stage enforced by IAM, not by convention
- Manual approval gate between plan and apply
- Saved plan applied, not re-planned
- tfsec and checkov run on every push
- ECR image scanning on push, configured at the registry level
- Images tagged by commit SHA
- API Gateway access logging with source IP, status, and request ID
- Log retention set explicitly (14 days)
- State file encrypted and versioned, with native S3 locking
- ECR lifecycle policy keeping only the five most recent images

## Lessons learned

### The pipeline was managing its own infrastructure

The artifacts bucket, the CodeBuild projects, the pipeline itself, and the IAM roles were all defined in the same Terraform configuration the pipeline applied. When state drifted, a deploy run planned to replace the artifacts bucket. It destroyed the bucket's versioning, encryption, and public access block, then failed on a 409 conflict trying to recreate a bucket that still existed — leaving the destroy half applied.

The fix was structural: split into `bootstrap/` and `workload/` with separate state files.

### A failed apply still writes partial state

`terraform apply` is not atomic. When it fails partway through, whatever succeeded is written to state and becomes current. S3 versioning on the state bucket made the forensics possible — listing object versions with timestamps and sizes showed exactly when resources disappeared and which run caused it.

### Terraform version mismatch between local and CI

The buildspec installed Terraform 1.9.0 while my machine ran 1.15.7. Backend arguments were rejected as unsupported, and plan binaries could not be read locally because they are version-locked. Both are now pinned to the same version, which is what makes reviewing a pipeline-generated plan possible.

### A security control that looked enabled and wasn't

The ECR repository was created with `scan_on_push = true`. Terraform applied it without error and `describe-repositories` confirmed it. No scan ever ran — AWS moved scanning control to a registry-level configuration where the rules array was empty.

Verify a security control produces output, not just that the setting is set.

### CodeBuild working directory does not persist between phases

Every command is now anchored to `$CODEBUILD_SRC_DIR` explicitly.

### Multi-artifact CodeBuild actions need an explicit primary source

`PrimarySource` must be set in the action configuration to say which artifact CodeBuild extracts to `$CODEBUILD_SRC_DIR` and reads the buildspec from.

### IAM permission discovery is iterative

Adding a remote state backend meant `terraform plan` began refreshing against real AWS, requiring read permissions across every resource type in state. These surfaced one denial at a time. There is no complete list anywhere of what permissions a given resource needs.

## Cost

Nothing in this project runs continuously. CodePipeline is roughly $1/month per active pipeline; CodeBuild bills per build-minute; Lambda and API Gateway bill per request; ECR storage is capped by a lifecycle policy. A NAT Gateway was built early, tested, and destroyed.

## Not done yet

- The handler returns a fixed response. No Hugging Face model is loaded.
- SBOM generation (syft) and artifact signing (cosign) were removed while debugging and need adding back.
- The API endpoint is public with no authentication.
- No CloudWatch alarms or dashboards.
- Lambda has no reserved concurrency limit.
- Hardening backlog: secrets rotation runbook, image verification before deploy, drift detection between Git and deployed state, IAM least-privilege audit.

## Running it yourself

```bash
# One-time: create the state bucket and lock table
cd terraform-backend-setup && terraform init && terraform apply

# One-time: create the pipeline infrastructure
cd ../bootstrap && terraform init && terraform apply

# Then authorize the GitHub connection manually in
# AWS Console → Developer Tools → Settings → Connections

# From then on, the pipeline deploys workload/ on every push to main
```
