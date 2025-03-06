variable "jenkins_public_key" {
  description = "Public key for the Jenkins key pair"
  type        = string
}

variable "jenkins_public_key" {
  description = "Public key for the Jenkins key pair"
  type        = string
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"
  public_key = var.jenkins_public_key
}
