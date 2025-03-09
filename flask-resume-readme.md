# Flask Resume Project

## Overview

The Flask Resume Project is a containerized Flask application deployed on AWS. It demonstrates a modern DevOps workflow integrating Docker, Jenkins, Terraform, and Ansible to provision infrastructure and deploy the application. The project leverages AWS services (EC2 and RDS) and uses Jenkins for continuous integration and deployment (CI/CD), making it an excellent reference for automated deployments using infrastructure-as-code principles.

![DevOps Workflow](https://via.placeholder.com/800x400.png?text=DevOps+Workflow+Diagram)

## Prerequisites

Before starting, ensure you have the following installed and configured:

- **Jenkins** with Terraform and Ansible plugins installed
- **Jenkins Credentials**:
  - AWS Secret ID
  - AWS Secret Key
  - EC2 SSH Private Key
  - EC2 SSH Public Key
  - Database Username
  - Database Password
- **Docker**: For building and running container images
- **Terraform**: For provisioning AWS infrastructure (EC2, RDS, and security groups)
- **Ansible**: For configuring the application on the provisioned AWS environment
- **AWS CLI**: For AWS interactions during the deployment process
- **Python**: For running the Flask application locally

## Project Structure

### DB Folder
- `init.sql`: 
  - Contains SQL commands used to configure and initialize the database schema for local deployment
  - Sets up necessary tables and configurations required by the application
  - Note: For containerized deployment, a separate Docker file for Postgres is available in another folder

### Web Folder
- `Dockerfile`:
  - Builds a Docker image using a Python Slim base image
  - Installs the required dependencies from the requirements file
  
- `models.py`:
  - Defines data models for the application
  - Includes models for likes and comments
  
- `db.py`:
  - Configures the database connection
  - In this setup, the application uses AWS RDS
  - Connection details are defined via Jenkins environment variables
  
- `app.py`:
  - The main Flask application file
  - Sets up routes, integrates models, and serves the application

### Jenkins Folder
- `Jenkins-tera_ansi` (Pipeline File):
  - A Jenkins pipeline that automates the deployment process with the following stages:

  #### Pipeline Stages:
  1. **Checkout**:
     - Clones the repository (using the master branch)
     - Lists YAML and Terraform files for debugging

  2. **Pre-cleanup**:
     - Deletes any existing EC2 key pair (jenkins-key) using an AWS CLI container
     - Ensures a clean deployment environment

  3. **Terraform Init & Plan**:
     - **Terraform Init**: Initializes Terraform in the terraform folder
     - **Plan**: Generates a Terraform plan using a Jenkins-provided public key credential
     - Saves the output for review

  4. **Apply / Destroy**:
     - Depending on the selected action:
       - **Apply**: Optionally prompts for manual approval before applying the Terraform plan
       - **Destroy**: Automatically destroys the infrastructure if selected

  5. **Ansible Deploy**:
     - When applying changes, this stage:
       - Retrieves outputs from Terraform (such as the EC2 public IP and RDS endpoint)
       - Sets them as environment variables
       - Uses Jenkins credentials to securely fetch SSH keys
       - Generates an Ansible inventory file
       - Runs the Ansible playbook (ansible/deploy.yml) to deploy the application with the correct RDS configurations

  6. **Post Steps**:
     - Cleans up sensitive files (like SSH keys)
     - Logs the success or failure of the deployment

### Terraform Folder
- Contains scripts that provision the required AWS infrastructure:
  - **EC2 Security Group**:
    - Creates a security group to manage network access for the EC2 instance
  - **RDS Instance**:
    - Provisions an AWS RDS instance that serves as the application's database backend
  - These Terraform scripts ensure consistent and repeatable infrastructure provisioning using infrastructure-as-code principles

### Ansible Folder
- Includes playbooks and configuration files for finalizing the deployment:
  - **deploy.yml** (and other Ansible files):
    - Configures the EC2 instance by installing dependencies and setting up the Flask application
    - Passes critical RDS parameters (endpoint, username, password, database, port, and SSL mode) to ensure proper connectivity and configuration

### Backup Folder
- Stores legacy or previous versions of configuration files and scripts
- Acts as an archive, providing a fallback or reference in case of issues with the current deployment setup

## Deployment Process

### Local Development
1. Clone the repository:
   ```
   git clone https://github.com/NehorayHillel/flask_resume.git
   cd flask_resume
   ```

2. Set up a local database using the `init.sql` script in the DB folder

3. Run the Flask application:
   ```
   cd web
   python app.py
   ```

### AWS Deployment with Jenkins
1. Configure Jenkins with the required credentials and plugins
2. Create a new Jenkins pipeline using the `Jenkins-tera_ansi` file
3. Run the pipeline and monitor the deployment stages
4. Once complete, access the application via the EC2 public IP address

## Architecture Diagram

```
┌────────────┐     ┌────────────┐     ┌────────────────┐
│            │     │            │     │                │
│   Jenkins  │────▶│  Terraform │────▶│  AWS EC2       │
│   Server   │     │  Scripts   │     │  (Flask App)   │
│            │     │            │     │                │
└────────────┘     └────────────┘     └────────┬───────┘
                                               │
                        ┌────────────────────┐ │
                        │                    │ │
                        │  AWS RDS           │◀┘
                        │  (PostgreSQL)      │
                        │                    │
                        └────────────────────┘
```

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Nehoray Hillel - [your-email@example.com](mailto:your-email@example.com)

Project Link: [https://github.com/NehorayHillel/flask_resume](https://github.com/NehorayHillel/flask_resume)
