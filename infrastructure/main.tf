### Cloud Run enabling
resource "google_project_service" "run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = true
}

# Enable VPC connector
resource "google_project_service" "vpcaccess-api" {
  project = var.gcp_project_id
  service = "vpcaccess.googleapis.com"
}

# Create the Cloud Run service
resource "google_cloud_run_service" "test-app" {
  name     = "test-app"
  location = var.gcp_region

  template {
    metadata {
      annotations = {
        # Limit scale up to prevent any cost blow outs!
        "autoscaling.knative.dev/maxScale" = "2"
        # Use the VPC Connector
        "run.googleapis.com/vpc-access-connector" = "central-serverless"
        # all egress from the service should go through the VPC Connector
        "run.googleapis.com/vpc-access-egress" = "all-traffic"
      }
    }
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/inbound-descent-382406/devops-challenge/test-app:1.0"
        # Environment variables to define Database details
        env {
          name  = "POSTGRESQL_HOST"
          value = google_sql_database_instance.gcp_sql_postgres.private_ip_address
        }
        env {
          name  = "POSTGRESQL_USER"
          value = google_sql_user.user.name
        }
        env {
          name  = "POSTGRESQL_PASSWORD"
          value = google_sql_user.user.password
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API, Postgres Instance and VPC Connector to be enabled
  depends_on = [google_project_service.run_api, google_sql_database_instance.gcp_sql_postgres, module.serverless-connector]
}


resource "google_compute_network" "private_network" {
  provider = google-beta
  name     = "private-network"
  project  = var.gcp_project_id
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  project       = var.gcp_project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_subnetwork" "vpc-subnet" {
  name          = "devops-challenge-subnet"
  ip_cidr_range = "10.2.0.0/28"
  region        = var.gcp_region
  network       = google_compute_network.private_network.id
}

module "serverless-connector" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version    = "~> 6.0"
  project_id = var.gcp_project_id
  vpc_connectors = [{
    name          = "central-serverless"
    region        = var.gcp_region
    subnet_name   = google_compute_subnetwork.vpc-subnet.name
    machine_type  = "e2-micro"
    min_instances = 2
    max_instances = 3
    }
  ]
  depends_on = [google_project_service.vpcaccess-api]
}


resource "google_sql_database_instance" "gcp_sql_postgres" {
  provider            = google-beta
  project             = var.gcp_project_id
  name                = "postgres-db-test-app"
  region              = var.gcp_region
  database_version    = var.gcp_pg_database_version
  deletion_protection = "false"
  depends_on          = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.gcp_pg_tier
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.private_network.id
      enable_private_path_for_google_cloud_services = true
    }
  }
}

resource "google_sql_user" "user" {
  name     = "db-test-app-user"
  instance = google_sql_database_instance.gcp_sql_postgres.name
  password = "devopschallenge-01042023"
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.test-app.name
  location = google_cloud_run_service.test-app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}