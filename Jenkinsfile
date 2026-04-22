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
                // Explicitly checkout the repository
                checkout scm
                echo "Checked out from: ${env.GIT_URL}"
                echo "Branch: ${env.GIT_BRANCH}"
                sh 'ls -la'
                sh 'ls -la pom.xml || echo "pom.xml not found!"'
            }
        }
        
        stage('Build Application') {
            steps {
                echo '========================================='
                echo 'Stage 3: Build Application with Maven'
                echo '========================================='
                sh '''
                    echo "Working Directory: $(pwd)"
                    echo "Maven Binary: ${MAVEN_BIN}"
                    echo "Java Home: ${JAVA_HOME}"
                    echo "Liberty Version: ${LIBERTY_VERSION}"
                    echo "Listing workspace contents:"
                    ls -la
                    echo "Checking for pom.xml:"
                    ls -la pom.xml
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
                echo 'Stage 5: Package and Install All Application Artifacts'
                echo '========================================='
                sh '''
                    # Build and install ALL modules to local Maven repository
                    # This ensures all dependencies are available
                    ${MAVEN_BIN} clean install -DskipTests -Dliberty.runtime.version=${LIBERTY_VERSION}
                    
                    # Verify artifacts were installed
                    echo "Verifying artifacts in Maven repository..."
                    ls -la ~/.m2/repository/com/ibm/websphere/samples/plantsbywebsphere-ear/1.0-SNAPSHOT/ || echo "EAR not found!"
                    ls -la ~/.m2/repository/com/ibm/websphere/samples/whereami/1.0-SNAPSHOT/ || echo "WhereAmI not found!"
                '''
            }
        }
        
        stage('Create Liberty Server Package') {
            steps {
                echo '========================================='
                echo 'Stage 6: Verify Liberty Server Package Was Created'
                echo '========================================='
                sh '''
                    # The liberty server package should have been created in Stage 5
                    # Just verify it exists
                    echo "Checking for Liberty server package..."
                    ls -la liberty-server/target/*.zip
                    
                    # Show package details
                    echo "Liberty server package details:"
                    ls -lh liberty-server/target/*.zip
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
            echo 'Application deployed to Liberty Server'
            echo 'Access at: http://localhost:9080/plantsbywebsphere'
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
