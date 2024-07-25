
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
  default = "ubuntu"
}

variable "source_instance_id" {
  type         = string
  default      = "ami-0ad21ae1d0696ad58"
}

variable "ami_name" {
  type          = string
  default       = "hardened-ubuntu-{{timestamp}}"
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

source "amazon-ebs" "ubuntu" {
  region            = var.aws_region
  #access_key        = ""
  #secret_key        = ""
  instance_type     = var.instance_type
  source_ami        = var.source_instance_id
  ssh_username      = var.ssh_username
  ami_name          = var.ami_name
  ami_description   = "Hardened Ubuntu 20.04 AMI"
  communicator      = "ssh"
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

provisioner "shell" {
  inline = [
    "#!/bin/sh",
    "sudo apt update",
    "sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
    "sudo apt install -y openjdk-11-jdk",
    "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg",
    "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
    "sudo apt update",
    "sudo apt install -y jenkins",
    "sudo systemctl start jenkins",
    "sudo systemctl enable jenkins",
    "sudo sysctl -w vm.max_map_count=524288",
    "sudo sysctl -w fs.file-max=131072",
    "echo 'sonarqube   -   nofile   65536' | sudo tee -a /etc/security/limits.conf",
    "echo 'sonarqube   -   nproc    4096' | sudo tee -a /etc/security/limits.conf",
    "sudo apt update",
    "sudo apt install -y libc6-x32 libc6-i386",
    "wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.deb",
    "sudo dpkg -i jdk-17_linux-x64_bin.deb",
    "sudo apt-get update",
    "sudo apt-get clean",
    "sudo apt-get autoremove",
    "sudo apt --fix-broken install",
    "sudo dpkg -i jdk-17_linux-x64_bin.deb",
    "sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-17.0.12-oracle-x64/bin/java 1",
    "sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-17.0.12-oracle-x64/bin/javac 1",
    "echo 'SONAR_JAVA_PATH=/usr/lib/jvm/jdk-17.0.12-oracle-x64/bin/java' | sudo tee /etc/profile.d/sonar_java.sh",
    "echo 'JAVA_HOME=/usr/lib/jvm/jdk-17.0.12-oracle-x64' | sudo tee -a /etc/environment",
    "sudo apt install -y openjdk-17-jre-headless",
    "sudo sh -c 'echo \"deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main\" >> /etc/apt/sources.list.d/pgdg.list'",
    "wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -",
    "sudo apt-get update",
    "sudo apt-get -y install postgresql postgresql-contrib unzip",
    "sudo systemctl start postgresql",
    "sudo systemctl enable postgresql",
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
    "sudo apt install unzip",
    "sudo unzip awscliv2.zip",
    "sudo ./aws/install",
    "aws --version",
    "ARCH=amd64",
    "PLATFORM=$(uname -s)_$ARCH",
    "sudo curl -sLO \"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz\"",
    "sudo curl -sL \"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt\" | grep $PLATFORM | sha256sum --check",
    "sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz",
    "sudo mv /tmp/eksctl /usr/local/bin",
    "echo $JAVA_HOME",
    "echo $SONAR_JAVA_PATH"
    // "bash -c 'source /etc/profile.d/sonar_java.sh && source /etc/environment && echo $JAVA_HOME && echo $SONAR_JAVA_PATH'"
  ]
}
}
