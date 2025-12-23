# Web Application Infrastructure on GCP

This project contains Terraform code to provision a scalable, highly available web application infrastructure in the Cloud.

### Components

1.  **Network (VPC)**
    *   **Cloud NAT**: To allow instances in private subnets to access the internet for updates/packages without exposing them to incoming traffic.

2.  **Compute (Web Layer)**
    *   **Managed Instance Group (MIG)**: A group of Compute Engine VMs running Nginx.
    *   **Autoscaling**: Configured to automatically scale the number of instances based on CPU utilization.
    *   **High Availability**: The MIG will be regional with multiple instances.
    *   **Instance Template**: Defines the machine type, image (Debian), and startup script to install/configure Nginx.

3.  **Load Balancing**
    *   **Load Balancer**: Distributes incoming traffic across the instances in the MIG.
    *   **Health Checks**: Monitors the health of the web server instances.

4.  **Database (Data Layer)**
    *   **Cloud SQL**: PostgreSQL.

5.  **Storage**
    *   **Google Cloud Storage (GCS)**: A bucket for storing static assets, backups, or application data.

## Assumptions

*   **Cloud Provider**: Google Cloud Platform (GCP).
*   **Infrastructure as Code**: Terraform is used for all provisioning.
*   **Deployment authentication**: Terraform will run with credentials file fot the GCP project.
*   **Web app authentication**: Credentials to the databse are aviable as enviroment variables on the nginx server.
*   **Public access to Storage Bucket**: Conatins static assets for webpages. 

## Prerequisites

*   Terraform installed.
*   A GCP Project with billing enabled.
*   Variables, see `terraform.tfvars.template` for details

## Usage

1.  Initialize Terraform:
```bash
terraform init
```

2.  Review the plan:
```bash
terraform plan
```

3.  Apply the configuration:
```bash
terraform apply
```

4. Verify
```bash
# Run curl to test load balancer
curl -k "https://$(terraform output -raw load_balancer_ip)"
# Hello from web-server-k4db. DB Password is available in env db-password***  NM4RZ:co_dspf*Uu***. DB Connection Name: kube-poc-47705:us-central1:web-app-db-instance. Bucket URL: gs://web-app-assets-kube-poc-47705
```

5. Clean up
```bash
terraform destroy
```

6. Verify empty project
```bash
terraform state list
# should return no output
```
