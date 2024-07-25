variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "instance_type" {
  type    = string
  default = "t2.large"
}
variable "ssh_username" {
  type    = string
  default = "ec2-user"
}
variable "source_instance_id" {
  type         = string
  default      = "ami-0c90942fd0daf9bc5" # Replace with a CentOS AMI ID
}
variable "ami_name" {
  type          = string
  default       = "hardened-centos-{{timestamp}}"
}
variable "vpc_id" {
  type    = string
  default = "vpc-0eec17d1c4f980928"
}
variable "subnet_id" {
  type = string
  default = "subnet-00825ad3385e5ec2c"
}
variable "security_group_id" {
  type = string
  default = "sg-0627d10fbc2727049"
}

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}
source "amazon-ebs" "centos" {
  region            = var.aws_region
  access_key        = ""
  secret_key        = ""
  instance_type     = var.instance_type
  source_ami        = var.source_instance_id
  ssh_username      = var.ssh_username
  ami_name          = var.ami_name
  ami_description   = "Hardened CentOS AMI"
  communicator      = "ssh"
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id
}

build {
  sources = ["source.amazon-ebs.centos"]

  provisioner "shell" {
    inline = [
      "#!/bin/sh",
      "sudo yum update -y",
      "sudo yum install -y epel-release",
      "sudo yum install -y java-11-openjdk-devel",
      "sudo yum install -y wget unzip",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo yum install -y jenkins",
      "sudo yum clean all",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",
      "sudo sysctl -w vm.max_map_count=524288",
      "sudo sysctl -w fs.file-max=131072",
      "echo 'sonarqube   -   nofile   65536' | sudo tee -a /etc/security/limits.conf",
      "echo 'sonarqube   -   nproc    4096' | sudo tee -a /etc/security/limits.conf",
      "sudo yum install -y glibc.i686 glibc.x86_64",
      "wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm",
      "sudo rpm -ivh jdk-17_linux-x64_bin.rpm",
      "sudo yum install -y java-17-openjdk",
      "echo 'export JAVA_HOME=/usr/lib/jvm/jdk-17' | sudo tee -a /etc/environment",
      "source /etc/environment",
      "sudo yum install -y postgresql-server",
      "sudo postgresql-setup initdb",
      "sudo systemctl start postgresql.service",
      "sudo systemctl enable postgresql.service",
      "echo 'postgres:sonar' | sudo chpasswd",
      "sudo -u postgres createuser sonar",
      "sudo -u postgres psql -c \"ALTER USER sonar WITH ENCRYPTED password 'sonar';\"",
      "sudo -u postgres createdb sonarqube -O sonar",
      "sonar_link=$(curl -s https://www.sonarsource.com/products/sonarqube/downloads/success-download-community-edition/ | grep -o 'https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-[0-9.]*.zip')",
      "sudo wget \"$sonar_link\" -P /tmp",
      "sudo unzip -o \"/tmp/$(basename \"$sonar_link\")\" -d /opt",
      "sudo rm -rf /opt/sonarqube",
      "sudo mv /opt/sonarqube-* /opt/sonarqube",
      "if ! getent group sonar > /dev/null 2>&1; then sudo groupadd sonar; fi",
      "if ! id -u sonar > /dev/null 2>&1; then sudo useradd -c \"user to run SonarQube\" -d /opt/sonarqube -g sonar sonar; fi",
      "sudo chown sonar:sonar /opt/sonarqube -R",
      "sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /opt/sonarqube/conf/sonar.properties",
      "sudo sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/' /opt/sonarqube/conf/sonar.properties",
      "sudo sed -i 's/#sonar.jdbc.url=jdbc:postgresql:\\/\\/localhost:5432\\/sonarqube/sonar.jdbc.url=jdbc:postgresql:\\/\\/localhost:5432\\/sonarqube/' /opt/sonarqube/conf/sonar.properties",
      "sudo sed -i 's/RUN_AS_USER=/RUN_AS_USER=sonar/' /opt/sonarqube/bin/linux-x86-64/sonar.sh",
      "sudo -u sonar /opt/sonarqube/bin/linux-x86-64/sonar.sh start",
      "URL=\"https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl\"",
      "echo \"Downloading kubectl from: $URL\"",
      "sudo curl -LO \"$URL\"",
      "sudo chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "kubectl version --client",
      "sudo curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "sudo yum install -y unzip",
      "sudo unzip awscliv2.zip",
      "sudo ./aws/install",
      "aws --version",
      "ARCH=amd64",
      "PLATFORM=$(uname -s)_$ARCH",
      "sudo curl -sLO \"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz\"",
      "sudo curl -sL \"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt\" | grep $PLATFORM | sha256sum --check",
      "sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz",
      "sudo mv /tmp/eksctl /usr/local/bin",
      "echo $JAVA_HOME"
    ]
  }
}