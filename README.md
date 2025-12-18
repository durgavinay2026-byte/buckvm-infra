Terraform infra for `buckvm`.

Secrets required in GitHub:
- GCP_CREDENTIALS (service account JSON)
- GCP_PROJECT = buckvm
- GCP_TF_BUCKET = buckvm-tfstate-statebucket

Workflow: plans on PR; run manual apply via Actions -> Run workflow.