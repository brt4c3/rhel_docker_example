pipeline {
    agent any

    environment {
        IIM_ZIP = "MW/iim_installer.zip"
        WLP_ZIP = "MW/wlp-webProfile-java8-linux.zip"
        REPO_URL = "https://github.com/brt4c3/rhel_docker_example.git"
        REPO_DIR = "rhel_docker_example"
    }

    stages {
        stage('Check Prerequisites') {
            steps {
                script {
                    if (!fileExists(env.IIM_ZIP)) {
                        error "Missing IIM installer zip at ${env.IIM_ZIP}"
                    }
                    if (!fileExists(env.WLP_ZIP)) {
                        error "Missing WLP Web Profile zip at ${env.WLP_ZIP}"
                    }
                }
            }
        }

        stage('Clone Git Repository') {
            steps {
                sh """
                rm -rf ${env.REPO_DIR}
                git clone ${env.REPO_URL} ${env.REPO_DIR}
                """
            }
        }

        stage('Start Docker Compose') {
            steps {
                dir("${env.REPO_DIR}") {
                    sh 'docker-compose up -d --build'
                }
            }
        }

        stage('Run Full Ansible Stack') {
            steps {
                sh 'ansible-playbook -i ansible/inventory ansible/main.yml'
            }
        }

    }

    post {
        always {
            dir("${env.REPO_DIR}") {
                sh 'docker-compose down || true'
            }
        }
    }
}
