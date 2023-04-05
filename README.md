# Purpose

Source code repository to store the code for DevOps Challenge

# Pre-requisites to build and deploy the project (test-app)

- Google Cloud PLatform (GCP):
  - An account with proper permissions
  - A Google Cloud Storage (GCS) bucket to store the Terraform state (backend)
- To install on your local machine:
  - gcloud cli
  - Docker
  - Terraform
  - git
- The project is ready to be built and deployed (CI/CD) with GitHub Actions. Requirements:
  - Github Account
  - Github Actions Secrets configured:
    - GOOGLE_CREDENTIALS: your GCP credential json file content
    - TF_API_TOKEN: Terraform Cloud API token to be able to run Terraform from GitHub Actions Workflows
    - WIF_PROVIDER: Workload Identity Provider name. Required to authenticate Provided as an output once the bootstrap resources have been created.
    - WIF_SERVICE_ACCOUNT: GCP Service Account linked to the WIF PROVIDER

# How-to run the app manually (no automations)

- Export the enviroment variable GOOGLE_CREDENTIALS with the path to your credentials.json file. Example: `export GOOGLE_CREDENTIALS=/home/user/.config/gcloud/gcp_credentials.json`
- Configure your GCS bucket in `bootstrap/backend.tf` and `infrastructure/backend.tf` to store the terraform state.
- Go to the project directory.
- Run Terraform commands:
  - `terraform -chdir=bootstrap init`
  - `terraform -chdir=bootstrap validate`
  - `terraform -chdir=bootstrap plan`
  - `terraform -chdir=bootstrap apply`
- Once the bootstrap resources have been successfully created. Build and push the docker image to the Google Artifact Registry (GAR):
  - Login into your GAR with your preferred method: <https://cloud.google.com/artifact-registry/docs/docker/authentication>. The GAR address is an output from the previous step (`terraform apply`).
  - Build and Push your test-app image. Keep in mind the image name will be used by CloudRun resource to run the app in a container.`infrastructure/main.tf#91`
- Once the image have been successfully built and pushed, run Terraform commands for infrastructure folder:
  - `terraform -chdir=infrastructure init`
  - `terraform -chdir=infrastructure validate`
  - `terraform -chdir=infrastructure plan`
  - `terraform -chdir=infrastructure apply`
- Once the Terraform infrastructre have been successfully created, the test-app will be up and running. The test-app URL will be an output from the previous step (`terraform apply`)

# How-to run the app in CI/CD mode

- Configure your google credential as an Action Secret called `GOOGLE_CREDENTIALS`.
- Configure your Terraform Cloud API Token as an Action Secret called `TF_API_TOKEN`.
- Commit and Push any modification on `bootstrap/` directory to trigger the workflow (github actions) `bootstrap_infrastructure.yml`.
- Once the Workflow have been successfully executed. Save the outputs: `provider_name` and `sa_email`.
- Configure the Workload Identity Provider id as an Action Secret called: `WIF_PROVIDER`
- Configure the Workload Identity Service Account email as an Action Secret called: `WIF_SERVICE_ACCOUNT`
- Update the environment variables values if needed.
- Commit and Push any modification on `infrastructure/` directory to trigger the workflow (github actions) `build-push-plan-apply.yml`.
- Once the Terraform infrastructre have been successfully created, the test-app will be up and running. The test-app URL will be an output from the previous step (`terraform apply`)

# Architecture diagram

<https://lucid.app/lucidchart/217ae8d6-437a-4a32-bd7a-81e62da7dd44/edit?viewport_loc=-32%2C-60%2C2219%2C1101%2C0_0&invitationId=inv_812e4acf-25ff-46f5-8953-98aef5eb8f20>

# High Availability, Disaster Recovery and Autoscaling

## Autoscaling

In order to keep the app up and running during high load periods, the test-app has been deployed in CloudRun with autoscaling: `"autoscaling.knative.dev/maxScale" = "2"`. The current value has been configure to avoid costs increase but can be increased if needed.
Additionally, the database has been deployed with a read replica to offload read requests or analytics traffic from the primary instance. The read replica number of instance can be increased as well.

## High Availability and Disaster Recovery

Both tiers (app and database) have been deployed as REGIONAL resources. So, if a zone expereinced an outage, the resources should be available from another zone within the Region.
Additonal databases master instances could added to have a failover_target.

# Using Revisions and Traffic management to deploy with 0 downtime

CloudRun provide a set of features which allow us to deploy a new revision of our apps and distribute a percentage of the traffic to the new Revision and the rest to the current Ready Revision.

- Further details can be found here: <https://cloud.google.com/run/docs/managing/revisions>

# Monitoring and Alerting

(asuming GCP as our provider)
In order to deploy/configure a good Observability stack, I will deploy a Grafana instance and configure Google Cloud Monitoring (metrics and logs) as a datasource to be able to display all the relevan information in panel and dashboard and configure alerts for the required events or thresholds.

# Security

In terms of security, I would apply the following improvements:

- Avoid to use admin/owner account/credentials
- Use dedicated Service Accounts/ Workload Identity Providers/ Tokens and restrict the roles assigned as much as possible using IAM
- Require authentication/authorization for all internet exposed services
- Use secrets when possible instead of plain-text password. A very bad practive can be found here: `infrastructure/main.tf#170` (only used due time restriction and simplicity)

# Improvements - WIP

- To use Terraform workspaces to be able to separate different environments, such as: dev, test, prod.
- To use the CloudRun V2 terraform resource
- To avoid to use user and password for the database credentials
- 
