# bank-of-anthos-app
dckr_pat_9vgiLsU4J7lDwL4gZOItHfIyns0-docker
squ_1c772336a549fc190c3e068dfa5e5fe1277b94a2-sonarube
admin chandhu-sonarqube
chandhu chandhu-jenkins
jenkins123@-authentication code
admin-Ch@ndhu123 ------argocd


def services = [
        [path: 'app/accounts/accounts-db', image: 'boa-accountsdb:v0'],
        [path: 'app/accounts/contacts', image: 'boa-contacts:v0'],
        [path: 'app/accounts/userservice', image: 'boa-userservice:v0'],
        [path: 'app/frontend', image: 'boa-frontend:v0'],
        [path: 'app/ledger/ledger-db', image: 'boa-ledgerdb:v0'],
        [path: 'app/ledger/ledgerwriter', image: 'boa-ledgerwriter:v0'],
        [path: 'app/ledger/balancereader', image: 'boa-balancereader:v0'],
        [path: 'app/ledger/transactionhistory', image: 'boa-transactionhistory:v0'],
        [path: 'app/loadgenerator', image: 'boa-loadgenerator:v0'],
]
def builtImages = []
pipeline {
    agent {
        docker {
            image 'abhishekf5/maven-abhishek-docker-agent:v1'
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    tools {
        jdk 'jdk17' // The name must match what you've defined in Global Tool Configuration
    }


    environment {
        DOCKER_FILE = credentials('docker-cred')
        SUCCESS = 'SUCCESS'
        SONAR_SCANNER = tool 'sonar-scanner'
        
     
        SONAR_AUTH_TOKEN = credentials('sonar-key')
    }
   
    parameters {
        booleanParam(name: 'FULL_BUILD', defaultValue: false, description: 'Force a full build of all Docker images')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    services.each { service ->
                        service.image = service.image.replace('v0', "v0.${BUILD_NUMBER}")
                    }
                }
                git branch: 'master',  url: 'https://github.com/chandhuDev/bank-of-anthos-app.git'
            }
        }
        stage('Cabcd') {
            steps {
                script {
                   
                    sh 'printenv'
                   
        
                    // sh '$JDK_TOOL'
                     sh '$SONAR_SCANNER'
                     sh '/var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/sonar-scanner/bin/sonar-scanner --version'

                }
            }
        }
        stage('SonarQube Check') {
            steps {
                script {
                    def SONAR_URL = 'http://3.90.223.81:9000'
                    
                    withSonarQubeEnv('sonar') {
                        services.each { service ->
                            echo "Running SonarQube analysis for ${service.path}..."
                            dir("${service.path}") {
                                if (fileExists('pom.xml')) {
                                    
                                    echo "Detected Java project in ${service.path}, running SonarQube analysis with Maven..."
                                    sh "mvn clean package && mvn sonar:sonar -Dsonar.login=${SONAR_AUTH_TOKEN} -Dsonar.host.url=${SONAR_URL}"
                                } else if (fileExists('requirements.txt')) {
                                    
                                    echo "Detected Python project in ${service.path}, running SonarQube analysis with sonar-scanner..."
                                    echo "$SONAR_SCANNER is the path "
                                    
                                    sh """
                                    /var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/sonar-scanner/bin/sonar-scanner \
                                    -Dsonar.projectKey=jenkins \
                                    -Dsonar.sources=. \
                                    """
                                } else {
                                    echo "No recognized project type in ${service.path}, skipping SonarQube analysis."
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('Build Docker images') {
            when {
                expression { currentBuild.previousStageResult == SUCCESS }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh "echo ${DOCKER_USERNAME} and ${DOCKER_PASSWORD}"
                    sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"

                    script {
                        def forceFullBuild = params.FULL_BUILD

                        services.each { item ->
                            if (forceFullBuild) {
                                echo "Full build requested, building image ${item.image}..."
                                dir("${item.path}") {
                                    sh "docker build -t chandhudev0/${item.image} ."
                                    sh "docker push chandhudev0/${item.image}"
                                }
                                builtImages.push("${item.image}")
                            } else {
                                def changes = sh(script: "git diff --name-only HEAD~1 HEAD ${item.path}", returnStdout: true).trim()
                                if (changes) {
                                    echo "Changes detected in ${item.path}, building image ${item.image}..."
                                    dir("${item.path}") {
                                        sh "docker build -t chandhudev0/${item.image} ."
                                        sh "docker push chandhudev0/${item.image}"
                                    }
                                    builtImages.push("${item.image}")
                                } else {
                                    echo "No changes detected in ${item.path}, skipping build for ${item.image}."
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('Trivy Check') {
            when {
                expression { currentBuild.previousStageResult == "${SUCCESS}" }
            }
            steps {
                script {
                    builtImages.each { image ->
                        echo "${image}"
                        echo "Running Trivy scan on image: chandhudev0/${image}"
                        sh "/usr/local/bin/trivy image --severity CRITICAL,HIGH --format template --template-output table --ignore-unfixed chandhudev0/${image}"
                    }
                }
            }
        }
    }
}
