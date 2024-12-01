pipeline {
    agent {
        docker {
            image 'docker:latest'
        }
    }

    environment {
        AWS_ACCESS_KEY_ID  = credentials('aws_key')
        AWS_SECRET_ACCESS_KEY  = credentials('aws_secret')
        AWS_REGION = 'us-east-1'
        AWS_FILE = credentials('aws_secret_file')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',  url: 'https://github.com/chandhuDev/bank-of-anthos-k8'
            }
        }
        stage('Env file checkout') {
            steps {
                script {
                    writeFile file: 'variable.tfvars' , text : "${env.AWS_FILE}"
                }
            }
        }
        stage('terraform apply') {
            steps {
                sh(script: '''
                    cat variable.tfvars
                    sudo yum install -y yum-utils
                    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
                    sudo yum -y install terraform

                    cat terraform --version
                    find terraform -type f -name 'main.tf' -exec sed -i 's/us-east-1/us-east-2/g' {} +

                    sed -i 's/us-east-1/us-east-2/g' ${AWS_FILE} && sed -i 's/ami-0583d8c7a9c35822c/ami-085f9c64a9b75eed5/' ${AWS_FILE}
                    cd terraform
                    sed -i 's/terrform-tf.state/terrform-tf.st/g' main.tf
                    sed -i '89,97 s/^/#/' main.tf
                    sed -i '111,114 s/^/#/' main.tf
                    sed -i '75,84 s/^/#/' main.tf
                    sed -i '37,78 s/^/#/' sg/main.tf
                    terraform init
                    terraform fmt
                    terraform plan -var-file=${AWS_FILE}
                    terraform apply -var-file=${AWS_FILE} -auto-approve
               ''')
            }
        }
    }
}
