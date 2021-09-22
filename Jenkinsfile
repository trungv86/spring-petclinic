def checkContainer = "docker container ls  -fname=SpringProject -q"
pipeline {
    agent any
    tools {
        maven 'Maven 3.8.2'
        jdk 'JDK 8'
    }
    environment {
        currentDATE = sh(returnStdout: true, script:'date +%Y%m%d').trim()
        newVersion = "$currentDATE-$BUILD_NUMBER"
        oldVersion = "$currentDATE-$currentBuild.previousBuild.number"
        stableVersion = "stable-$currentDATE"
        stableImage = "nexus.trungvh6.com:9001/spring:stable$currentDATE"
        imageName = "nexus.trungvh6.com:9001/spring:$newVersion"
        oldImage= "nexus.trungvh6.com:9001/spring:$oldVersion"
        currentImage = ''
        dockerImage = ''
        containerName = "SpringProject"
        checkContainer = "docker container ls  -fname=${SpringProject} -q"
    }



    stages {
        stage('Cleanup & Checkout code from GitHub') {
            steps {
                cleanWs()
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/trungv86/spring-petclinic.git']]])
            }
        }
        
        stage('Build Maven Project') {
            steps {
                sh 'echo $previousNumber'
                sh "mvn clean install -Dv='$newVersion'"
            }
        }
            
        stage('Push Maven Artifact to Nexus Repo') {
            steps {
                    script {
                            def jarVersion = "$currentDATE-$BUILD_NUMBER"
                            nexusArtifactUploader artifacts: [
                                [
                                        artifactId: 'spring-petclinic', 
                                        classifier: '', 
                                        file: 'target/spring-petclinic-Build-'+ jarVersion +'.jar', 
                                        type: 'jar'
                                ]
                            ], credentialsId: 'nexus.trungvh6.com', groupId: 'org.springframework.samples', nexusUrl: '192.168.169.129', nexusVersion: 'nexus3', protocol: 'http', repository: 'http://192.168.169.129:8081/repository/MavenHosted/', version: 'Build-'+ jarVersion
                    }                              
            }
        }         
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build imageName
                }
            }
        }
         stage('Upload image to Nexus Repo') {
            steps {
                script {
                   withDockerRegistry(credentialsId: 'nexus.trungvh6.com', toolName: 'Docker on Host', url: 'https://nexus.trungvh6.com:9001/dockerhosted') {
                       dockerImage.push()
                       
                   }
                }
            }
        }
        
        stage('Backup Stable Image - Release Server') {
            steps {
                
                withCredentials([usernamePassword(credentialsId: 'Release-Server', passwordVariable: 'releasePass', usernameVariable: 'releaseUser')]) {
                    
                    sh 'sshpass -p $releasePass ssh $releaseUser@release "rm -rf /root/stable-image/*" '
					sh '''
						sshpass -p $releasePass ssh $releaseUser@release "
						    
							docker container inspect --format={{.State.Status}} SpringProject |\
							xargs -iaa bash -c 'if [ "aa" == "running" ] ; \
							then echo "Container is Running" \
							&& docker container ls -a -fname=$containerName -q --format={{.Image}} | xargs -I{} -r docker tag {} $stableImage \
							&& docker save -o /root/stable-image/$stableVersion.tar $stableImage \
							&& echo "Finished Backup Stable Image"; \
							else echo "Container is not running"; \
							fi '
							"
					'''     
                }   

            }
        }
        
        
        stage('Stop Container - Release server') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Release-Server', passwordVariable: 'releasePass', usernameVariable: 'releaseUser')]) {
                    
                    sh '''
						sshpass -p $releasePass ssh $releaseUser@release "
							docker container ls -a -fname=$containerName -q | xargs -r docker container stop
							docker container ls -a -fname=$containerName -q | xargs -r docker container rm
							docker images $oldImage -q | xargs -r docker image rm -f "
					'''
                }   

            }
        }
        
        stage('Pull Image - Release server') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Release-Server', passwordVariable: 'releasePass', usernameVariable: 'releaseUser')]) {
                    sh 'sshpass -p $releasePass ssh $releaseUser@release "docker pull $imageName"'
                }
            }
        }
        
        
        stage('Run New Container - Release server') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Release-Server', passwordVariable: 'releasePass', usernameVariable: 'releaseUser')]) {
                    sh 'sshpass -p $releasePass ssh $releaseUser@release "docker run -d --name $containerName -p 8080:8080 $imageName"'
                    sh 'sleep 30'
                    sh '''
                        sshpass -p $releasePass ssh $releaseUser@release "
                            if [ $(curl -Is release.trungvh6.com:8080 | head -n 1 | cut -d' ' -f2) -eq 200 ] ; \
                            then echo "Build Successful"; \
                            else echo "Build Failed" \
                            && docker container ls -a -fname=$containerName -q | xargs -r docker container stop \
                            && docker container ls -a -fname=$containerName -q | xargs -r docker container rm \
                            && docker load -i /root/stable-image/$stableVersion.tar \
                            && docker run -d --name $containerName -p 8080:8080 $stableImage  ; fi "
                    
                    '''
                }
                
            }
        }
        
    }
}
