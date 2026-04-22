pipeline {
    agent any
    
    environment {
        // Liberty configuration
        LIBERTY_VERSION = '26.0.0.1'
        LIBERTY_HOME = '/opt/liberty/wlp'
        SERVER_NAME = 'pbwServerX'
        
        // Build configuration
        MAVEN_HOME = '/usr/share/maven'
        JAVA_HOME = '/usr/lib/jvm/java-8-openjdk-amd64'
        
        // Workspace paths
        BUILD_OUTPUT = "${WORKSPACE}/liberty-server/target"
        SERVER_PACKAGE = "${BUILD_OUTPUT}/${LIBERTY_VERSION}-${SERVER_NAME}.zip"
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
                //git branch: 'main',
                //    url: 'https://github.com/IBMTechSales/liberty_admin_pot_src.git'
                
                //sh 'ls -la'
                //sh 'echo "Source code checked out successfully"'

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
                sh """
                    echo "Maven Home: ${MAVEN_HOME}"
                    echo "Java Home: ${JAVA_HOME}"
                    echo "Liberty Version: ${LIBERTY_VERSION}"
                    
                    mvn clean compile -Dliberty.runtime.version=${LIBERTY_VERSION}
                """
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                echo '========================================='
                echo 'Stage 4: Run Unit Tests'
                echo '========================================='
                sh 'mvn test -Dliberty.runtime.version=${LIBERTY_VERSION}'
            }
            post {
                always {
                    // Archive test results
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package Application') {
            steps {
                echo '========================================='
                echo 'Stage 5: Package Application'
                echo '========================================='
                sh """
                    mvn package -DskipTests -Dliberty.runtime.version=${LIBERTY_VERSION}
                    
                    echo "Listing build artifacts:"
                    ls -lh plantsbywebsphere-util/target/*.jar || true
                    ls -lh plantsbywebsphere-war/target/*.war || true
                    ls -lh plantsbywebsphere-ear/target/*.ear || true
                    ls -lh whereami/target/*.war || true
                """
            }
        }
        
        stage('Create Liberty Server Package') {
            steps {
                echo '========================================='
                echo 'Stage 6: Create Liberty Server Package'
                echo '========================================='
                sh """
                    mvn install -DskipTests -Dliberty.runtime.version=${LIBERTY_VERSION}
                    
                    echo "Server package created:"
                    ls -lh ${SERVER_PACKAGE}
                """
            }
        }
        
        stage('Deploy to Liberty') {
            steps {
                echo '========================================='
                echo 'Stage 7: Deploy to Liberty Server'
                echo '========================================='
                script {
                    // Call deployment script
                    sh """
                        chmod +x ${WORKSPACE}/scripts/deploy-liberty.sh
                        ${WORKSPACE}/scripts/deploy-liberty.sh \
                            ${LIBERTY_HOME} \
                            ${SERVER_NAME} \
                            ${SERVER_PACKAGE}
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '========================================='
                echo 'Stage 8: Verify Deployment'
                echo '========================================='
                script {
                    // Wait for server to start and verify
                    sh """
                        chmod +x ${WORKSPACE}/scripts/verify-deployment.sh
                        ${WORKSPACE}/scripts/verify-deployment.sh \
                            ${LIBERTY_HOME} \
                            ${SERVER_NAME}
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo '========================================='
            echo 'Pipeline completed successfully!'
            echo '========================================='
            echo "Application deployed to Liberty ${LIBERTY_VERSION}"
            echo "Server: ${SERVER_NAME}"
            echo "Liberty Home: ${LIBERTY_HOME}"
            
            // Archive artifacts
            archiveArtifacts artifacts: '**/target/*.war,**/target/*.ear,**/target/*.zip', 
                             fingerprint: true,
                             allowEmptyArchive: true
        }
        
        failure {
            echo '========================================='
            echo 'Pipeline failed!'
            echo '========================================='
            echo 'Check the console output for errors'
        }
        
        always {
            echo '========================================='
            echo 'Pipeline execution completed'
            echo "Build Number: ${env.BUILD_NUMBER}"
            echo "Build URL: ${env.BUILD_URL}"
            echo '========================================='
        }
    }
}
