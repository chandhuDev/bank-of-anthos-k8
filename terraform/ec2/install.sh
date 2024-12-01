#!/bin/bash
sudo yum update -y
sudo yum install -y wget firewalld java-17-openjdk-devel zip unzip fontconfig git
              
sudo yum remove -y podman buildah

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin --skip-broken
              
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install -y jenkins
sudo usermod -aG docker jenkins

sudo echo "[trivy] 
name=Trivy repository 
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$releasever/\$basearch/ 
gpgcheck=0
enabled=1" | sudo tee /etc/yum.repos.d/trivy.repo > /dev/null

sudo yum -y update
sudo yum -y install trivy

sudo yum install -y --nogpgcheck https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum -qy module disable postgresql
sudo yum install -y postgresql14-server
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable --now postgresql-14
sudo echo "postgres:postgres123" | sudo chpasswd 
sudo su - postgres
createuser sonar
psql
ALTER USER sonar WITH ENCRYPTED password 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar; 
\q
exit
sudo su - 
adduser sonarqube
echo "sonarqube:sonarqube123" | sudo chpasswd 
usermod -aG wheel sonarqube
su - sonarqube 
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.6.0.92116.zip
sudo unzip sonarqube-10.6.0.92116.zip
sudo mv sonarqube-10.6.0.92116 /opt/sonarqube
sudo chmod -R 755 /opt/sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

sudo sed -i 's/^#sonar\.jdbc\.username=$/sonar.jdbc.username=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/^#sonar\.jdbc\.password=$/sonar.jdbc.password=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/^#RUN_AS_USER=$/RUN_AS_USER=sonarqube/' /opt/sonarqube/bin/linux-x86-64/sonar.sh

sudo echo "[Unit]
Description=SonarQube service 
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start 
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=131072
LimitNPROC=8192
[Install]
WantedBy=multi-user.target " | sudo tee /etc/systemd/system/sonar.service > /dev/null
              
exit
exit

sudo systemctl daemon-reload

sudo systemctl start docker
sudo systemctl enable docker

sudo systemctl enable sonar 
sudo systemctl start sonar

sudo systemctl enable jenkins
sudo systemctl start jenkins

sudo systemctl enable firewalld
sudo systemctl start firewalld
              
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=9000/tcp 
sudo firewall-cmd --reload



docker run -d --name sonar \
    -p 9000:9000 \
    -e SONAR_JDBC_URL=jdbc:postgresql://localhost/sonarqube \
    -e SONAR_JDBC_USERNAME=sonar \
    -e SONAR_JDBC_PASSWORD=sonar \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    -v sonarqube_logs:/opt/sonarqube/logs \
    sonarqube:lts-community