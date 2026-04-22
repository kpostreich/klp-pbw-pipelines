pipeline {
    agent any
    
    environment {
        LIBERTY_VERSION = '26.0.0.1'
        LIBERTY_HOME = '/opt/liberty/wlp'
        SERVER_NAME = 'pbwServerX'
        MAVEN_BIN = '/home/techzone/Documents/apache-maven-3.9.5-bin/apache-maven-3.9.5/bin/mvn'
        JAVA_HOME = '/usr/lib/jvm/ibm-semeru-open-17-jdk'
    }
    
    stages {
        stage('Cleanup Workspace') {
            steps {
                echo '========================================='
                echo 'Stage 1: Cleanup Workspace'
                echo '========================================='
                cleanWs()
            }
        }
        
        stage('Checkout Source') {
            steps {
                echo '========================================='
                echo 'Stage 2: Checkout Source Code'
                echo '========================================='
                // Jenkins SCM automatically checks out the repository
                // No explicit git command needed
                echo "Checked out from SCM: ${env.GIT_URL}"
                echo "Branch: ${env.GIT_BRANCH}"
            }
        }
        
        stage('Build Application') {
            steps {
                echo '========================================='
                echo 'Stage 3: Build Application with Maven'
                echo '========================================='
                sh '''
                    echo "Maven Binary: ${MAVEN_BIN}"
                    echo "Java Home: ${JAVA_HOME}"
                    echo "Liberty Version: ${LIBERTY_VERSION}"
                    ${MAVEN_BIN} clean compile -Dliberty.runtime.version=${LIBERTY_VERSION}
                '''
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                echo '========================================='
                echo 'Stage 4: Run Unit Tests'
                echo '========================================='
                sh '''
                    ${MAVEN_BIN} test -Dliberty.runtime.version=${LIBERTY_VERSION}
                '''
            }
        }
        
        stage('Package Application') {
            steps {
                echo '========================================='
                echo 'Stage 5: Package Application'
                echo '========================================='
                sh '''
                    ${MAVEN_BIN} package -DskipTests -Dliberty.runtime.version=${LIBERTY_VERSION}
                '''
            }
        }
        
        stage('Create Liberty Server Package') {
            steps {
                echo '========================================='
                echo 'Stage 6: Create Liberty Server Package'
                echo '========================================='
                sh '''
                    cd liberty-server
                    ${MAVEN_BIN} liberty:create liberty:install-feature liberty:deploy liberty:package -Dliberty.runtime.version=${LIBERTY_VERSION}
                '''
            }
        }
        
        stage('Deploy to Liberty') {
            steps {
                echo '========================================='
                echo 'Stage 7: Deploy to Liberty Server'
                echo '========================================='
                sh '''
                    chmod +x ${WORKSPACE}/scripts/deploy-liberty.sh
                    ${WORKSPACE}/scripts/deploy-liberty.sh
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '========================================='
                echo 'Stage 8: Verify Deployment'
                echo '========================================='
                sh '''
                    chmod +x ${WORKSPACE}/scripts/verify-deployment.sh
                    ${WORKSPACE}/scripts/verify-deployment.sh
                '''
            }
        }
    }
    
    post {
        always {
            echo '========================================='
            echo 'Pipeline execution completed'
            echo 'Build Number: ' + env.BUILD_NUMBER
            echo 'Build URL: ' + env.BUILD_URL
            echo '========================================='
        }
        success {
            echo '========================================='
            echo 'Pipeline completed successfully!'
            echo '========================================='
        }
        failure {
            echo '========================================='
            echo 'Pipeline failed!'
            echo '========================================='
            echo 'Check the console output for errors'
        }
    }
}
