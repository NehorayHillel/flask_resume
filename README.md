Flask Resume Project
Overview
The Flask Resume Project is a containerized Flask application deployed on AWS. It demonstrates a modern DevOps workflow integrating Docker, Jenkins, Terraform, and Ansible to provision infrastructure and deploy the application. The project leverages AWS services (EC2 and RDS) and is set up to use Jenkins for continuous integration and deployment (CI/CD), making it an excellent reference for automated deployments using infrastructure-as-code.

Prerequisites
Before starting, ensure you have the following installed and configured:

Jenkins with Terraform and Ansible installed.
Jenkins Credentials:
AWS Secret ID
AWS Secret Key
EC2 SSH Private Key
EC2 SSH Public Key
Database Username
Database Password
Docker: For building and running container images.
Terraform: For provisioning AWS infrastructure (EC2, RDS, and security groups).
Ansible: For configuring the application on the provisioned AWS environment.
AWS CLI: For AWS interactions during the deployment process.
Python: For running the Flask application.
Folder Structure and Explanation
DB Folder
init.sql:
Contains SQL commands used to configure and initialize the database schema for local deployment. This script sets up the necessary tables and configurations required by the application.
Note: For containerized deployment, a separate Docker file for Postgres is available in another folder.
Web Folder
Dockerfile:
Builds a Docker image using a Python Slim base image. It installs the required dependencies from the requirements file.

models.py:
Defines data models for the application, including models for likes and comments.

db.py:
Configures the database connection. In this setup, the application uses AWS RDS, with connection details defined via Jenkins environment variables.

app.py:
The main Flask application file that sets up routes, integrates models, and serves the application.

Jenkins Folder
Jenkins-tera_ansi (Pipeline File):
A Jenkins pipeline that automates the deployment process. Key stages include:

Checkout:
Clones the repository (using the master branch) and lists YAML and Terraform files for debugging.

Pre-cleanup:
Deletes any existing EC2 key pair (jenkins-key) using an AWS CLI container to ensure a clean deployment environment.

Terraform Init & Plan:

Terraform Init: Initializes Terraform in the terraform folder.
Plan: Generates a Terraform plan using a Jenkins-provided public key credential and saves the output for review.
Apply / Destroy:
Depending on the selected action:

Apply: Optionally prompts for manual approval before applying the Terraform plan.
Destroy: Automatically destroys the infrastructure if selected.
Ansible Deploy:
When applying changes, this stage:

Retrieves outputs from Terraform (such as the EC2 public IP and RDS endpoint) and sets them as environment variables.
Uses Jenkins credentials to securely fetch SSH keys.
Generates an Ansible inventory file.
Runs the Ansible playbook (ansible/deploy.yml) to deploy the application with the correct RDS configurations.
Post Steps:
Cleans up sensitive files (like SSH keys) and logs the success or failure of the deployment.

Terraform Folder
Contains scripts that provision the required AWS infrastructure:

EC2 Security Group:
Creates a security group to manage network access for the EC2 instance.

RDS Instance:
Provisions an AWS RDS instance that serves as the application's database backend.

These Terraform scripts ensure consistent and repeatable infrastructure provisioning using infrastructure-as-code principles.

Ansible Folder
Includes playbooks and configuration files for finalizing the deployment:

deploy.yml (and other Ansible files):
Configures the EC2 instance by installing dependencies and setting up the Flask application. It passes critical RDS parameters (endpoint, username, password, database, port, and SSL mode) to ensure proper connectivity and configuration.
Backup Folder
Stores legacy or previous versions of configuration files and scripts. This folder acts as an archive, providing a fallback or reference in case of issues with the current deployment setup.

Getting Started
