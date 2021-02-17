pipeline {
    agent any
    tools {
        terraform 'terraform'
        }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'test', credentialsId: 'git', url: 'https://github.com/gauravk29/terraform_ansible_jenkins.git'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                withCredentials([
			[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'],
			sshUserPrivateKey(credentialsId: 'ssh_pem_key', keyFileVariable: '', passphraseVariable: '', usernameVariable: 'ubuntu')])
                {
                sh 'terraform plan'
                }
            }
            }
        stage('Terraform Apply') {
            steps {
                withCredentials([
			[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'],
			sshUserPrivateKey(credentialsId: 'ssh_pem_key', keyFileVariable: '', passphraseVariable: '', usernameVariable: 'ubuntu')])
                {
                
                sh 'terraform apply --auto-approve'
                }
            }
            
        }
        stage('Terraform Destroy') {
            steps {
                withCredentials([
			[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'],
			sshUserPrivateKey(credentialsId: 'ssh_pem_key', keyFileVariable: '', passphraseVariable: '', usernameVariable: 'ubuntu')])
                {
                
                sh 'terraform destroy --auto-approve'
                }
            }
        }
    }
}
