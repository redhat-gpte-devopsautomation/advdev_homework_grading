// This pipeline automatically tests a student's full homework
// environment for OpenShift Advanced Application Development Homework
// and then executes the pipelines to ensure that everything works.
//
// Successful completion of this pipeline means that the
// student passed the homework assignment.
// Failure of the pipeline means that the student failed
// the homework assignment.

// How to setup:
// -------------
// * Create a persistent Jenkins in a separate project (e.g. gpte-jenkins)
//
// * Add self-provisioner role to the service account jenkins
//   oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:gpte-jenkins:jenkins 
//
// * Create an Item of type Pipeline (Use name "HomeworkGrading")
// * Create Five Parameters:
//   - GUID (type String):    GUID to prefix all projects
//   - USER (type String):    OpenTLC User ID to receive admin permissions on created projects
//   - REPO (type String):    full URL to the public Homework Repo
//                            (either Gogs or Github)
//   - CLUSTER (type String): Cluster base URL. E.g. na39.openshift.opentlc.com
//   - SETUP (type Boolean):  Default: true
//                            If true will create all necessary projects.
//                            If false assumes that projects are already there and only pipelines need
//                            to be executed.
//   - DELETE (type Boolean): Default: true
//                            If true will delete all created projects
//                            after a successful run.
// * Use https://github.com/wkulhanek/advdev_homework_grading as the Git Repo
//   and 'Jenkinsfile' as the Jenkinsfile.

pipeline {
  agent {
    kubernetes {
      label "homework"
      cloud "openshift"
      inheritFrom "maven"
      containerTemplate {
        name "jnlp"
        image "registry.access.redhat.com/openshift3/jenkins-slave-maven-rhel7:v3.9"
        resourceRequestMemory "1Gi"
        resourceLimitMemory "2Gi"
        resourceRequestCpu "500m"
        resourceLimitCpu "1"
      }
    }
  }
  stages {
    stage('Get Student Homework Repo') {
      steps {
        echo "*******************************************************\n" +
             "*** Advanced OpenShift Development Homework Grading ***\n" +
             "*** GUID:         ${GUID}\n" +
             "*** USER:         ${USER}\n" +
             "*** Student Repo: *************\n" +
             "*** CLUSTER:      ${CLUSTER}\n" +
             "*** SETUP:        ${SETUP}\n" +
             "*** DELETE:       ${DELETE}\n" +
             "*******************************************************"

        echo "Cloning Infrastructure Project"
        git '${REPO}'
      }
    }
    stage("Create Projects") {
      when {
        environment name: 'SETUP', value: 'true'
      }
      steps {
        echo "Creating Projects"
        sh "./Infrastructure/bin/setup_projects.sh ${GUID} ${USER}"
      }
    }
    stage("Setup Infrastructure") {
      failFast true
      when {
        environment name: 'SETUP', value: 'true'
      }
      parallel {
        stage("Setup Nexus") {
          steps {
            echo "Setting up Nexus"
            sh "./Infrastructure/bin/setup_nexus.sh ${GUID}"
          }
        }
        stage("Setup Sonarqube") {
          steps {
            echo "Setting up Sonarqube"
            sh "./Infrastructure/bin/setup_sonar.sh ${GUID}"
          }
        }
        stage("Setup Jenkins") {
          steps {
            echo "Setting up Jenkins"
            sh "./Infrastructure/bin/setup_jenkins.sh ${GUID} ${REPO} ${CLUSTER}"
          }
        }
        stage("Setup Development Project") {
          steps {
            echo "Setting up Development Project"
            sh "./Infrastructure/bin/setup_dev.sh ${GUID}"
          }
        }
        stage("Setup Production Project") {
          steps {
            echo "Setting up Production Project"
            sh "./Infrastructure/bin/setup_prod.sh ${GUID}"
          }
        }
      }
    }
    stage("Reset Infrastructure") {
      failFast true
      when {
        environment name: 'SETUP', value: 'false'
      }
      steps {
        sh "./Infrastructure/bin/reset_prod.sh ${GUID}"
      }
    }
    stage("First Pipeline Runs (from Green to Blue)") {
      failFast true
      parallel {
        stage('First Pipeline run for Nationalparks Service') {
          steps {
            echo "Executing Initial Nationalparks Pipeline - BLUE deployment"
            sh "oc start-build --wait=true nationalparks-pipeline -n ${GUID}-jenkins"
          }
        }
        stage('First Pipeline run for MLBParks Service') {
          steps {
            echo "Executing Initial MLBParks Pipeline - BLUE deployment"
            sh "oc start-build --wait=true mlbparks-pipeline -n ${GUID}-jenkins"
          }
        }
        stage('First Pipeline run for ParksMap Service') {
          steps {
            echo "Executing Initial ParksMap Pipeline - BLUE deployment"
            sh "oc start-build --wait=true parksmap-pipeline -n ${GUID}-jenkins"
          }
        }
      }
    }
    stage('Test Parksmap in Dev') {
      steps {
        echo "Testing Parksmap Dev Application"
        script {
          // Test Dev Nationalparks
          def devNationalParksSvc = sh(returnStdout: true, script: "curl nationalparks.${GUID}-parks-dev.svc.cluster.local:8080/ws/info/").trim()
          echo "Dev National Parks Service: " + devNationalParksSvc
          // Check if the returned string contains "National Parks (Dev)"
          if (devNationalParksSvc.contains("National Parks (Dev)")) {
            echo "*** National Parks (Dev) validated successfully."
          }
          else {
            error("National Parks (Dev) returned unexpected name.")
          }

          // Test Dev MLBParks
          def devMLBParksSvc = sh(returnStdout: true, script: "curl mlbparks.${GUID}-parks-dev.svc.cluster.local:8080/ws/info/").trim()
          echo "Dev MLB Parks Service: " + devMLBParksSvc
          // Check if the returned string contains "MLB Parks (Dev)"
          if (devMLBParksSvc.contains("MLB Parks (Dev)")) {
            echo "*** MLB Parks (Dev) validated successfully."
          }
          else {
            error("MLBParks (Dev) returned unexpected name.")
          }
          // Test Dev ParksMap
          def devParksMapRoute = sh(returnStdout: true, script: "curl parksmap-${GUID}-parks-dev.apps.${CLUSTER}/ws/appname/").trim()
          echo "Dev ParksMap Route: " + devParksMapRoute
          // Check if the returned string contains "Parks Map (Dev)"
          if (devParksMapRoute.contains("ParksMap (Dev)")) {
            echo "*** Parks Map (Dev) validated successfully."
          }
          else {
            error("ParksMap (Dev) returned unexpected name.")
          }
        }
      }
    }
    stage('Test Blue Services in Prod') {
      steps {
        echo "Testing Prod Services (BLUE)"
        script {
          // Test Blue Nationalparks:
          def blueNationalParksSvc = sh(returnStdout: true, script: "curl nationalparks-blue.${GUID}-parks-prod.svc.cluster.local:8080/ws/info/").trim()
          // Check if the returned string contains "National Parks (Blue)"
          echo "Blue National Parks Service: " + blueNationalParksSvc
          if (blueNationalParksSvc.contains("National Parks (Blue)")) {
            echo "*** National Parks (Blue) validated successfully."
          }
          else {
            error("National Parks (Blue) returned unexpected name.")
          }

          // Test Blue MLBParks:
          def blueMLBParksSvc = sh(returnStdout: true, script: "curl mlbparks-blue.${GUID}-parks-prod.svc.cluster.local:8080/ws/info/").trim()
          // Check if the returned string contains "MLB Parks (Blue)"
          echo "Blue MLB Parks Service: " + blueMLBParksSvc
          if (blueMLBParksSvc.contains("MLB Parks (Blue)")) {
            echo "*** MLB Parks (Blue) validated successfully."
          }
          else {
            error("MLB Parks (Blue) returned unexpected name.")
          }

          // Test Blue ParksMap
          def parksMapRoute = sh(returnStdout: true, script: "curl parksmap-${GUID}-parks-prod.apps.${CLUSTER}/ws/appname/").trim()
          // Check if the returned string contains "Parks Map (Blue)"
          echo "ParksMap Route: " + parksMapRoute
          if (parksMapRoute.contains("ParksMap (Blue)")) {
            echo "*** ParksMap (Blue) validated successfully."
          }
          else {
            error("ParksMap (Blue) returned unexpected name.")
          }
        }
      }
    }
    stage("Second Pipeline Runs (from Blue to Green)") {
      failFast true
      parallel {
        stage('Second Pipeline run for Nationalparks Service') {
          steps {
            echo "Executing Second Nationalparks Pipeline - GREEN deployment"
            sh "oc start-build --wait=true nationalparks-pipeline -n ${GUID}-jenkins"
          }
        }
        stage('Second Pipeline run for National Parks Service') {
          steps {
            echo "Executing Second National Parks Pipeline - GREEN deployment"
            sh "oc start-build --wait=true mlbparks-pipeline -n ${GUID}-jenkins"
          }
        }
        stage('Second Pipeline run for ParksMap Service') {
          steps {
            echo "Executing Second ParksMap Pipeline - GREEN deployment"
            sh "oc start-build --wait=true parksmap-pipeline -n ${GUID}-jenkins"
          }
        }
      }
    }
    stage('Test Green Parksmap in Prod') {
      steps {
        echo "Testing Prod Parksmap Application (GREEN)"
        script {
          // Test Green Nationalparks:
          def greenNationalParksSvc = sh(returnStdout: true, script: "curl nationalparks-green.${GUID}-parks-prod.svc.cluster.local:8080/ws/info/").trim()
          // Check if the returned string contains "National Parks (Green)"
          echo "Green National Parks Service: " + greenNationalParksSvc
          if (greenNationalParksSvc.contains("National Parks (Green)")) {
            echo "*** National Parks (Green) validated successfully."
          }
          else {
            error("National Parks (Green) returned unexpected name.")
          }

          // Test Green MLBParks:
          def greenMLBParksSvc = sh(returnStdout: true, script: "curl mlbparks-green.${GUID}-parks-prod.svc.cluster.local:8080/ws/info/").trim()
          // Check if the returned string contains "MLB Parks (Blue)"
          echo "Green MLB Parks Service: " + greenMLBParksSvc
          if (greenMLBParksSvc.contains("MLB Parks (Green)")) {
            echo "*** MLB Parks (Green) validated successfully."
          }
          else {
            error("MLB Parks (Green) returned unexpected name.")
          }

          // Test ParksMap
          def parksMapRoute = sh(returnStdout: true, script: "curl parksmap-${GUID}-parks-prod.apps.${CLUSTER}/ws/appname/").trim()
          // Check if the returned string contains "Parks Map (Green)"
          echo "ParksMap Route: " + parksMapRoute
          if (parksMapRoute.contains("ParksMap (Green)")) {
            echo "*** ParksMap (Green) validated successfully."
          }
          else {
            error("ParksMap (Green) returned unexpected name.")
          }
        }
      }
    }
    stage('Cleanup') {
      when {
        environment name: 'DELETE', value: 'true'
      }
      steps {
        echo "Cleanup - deleting all projects for GUID=${GUID}"
        sh "./Infrastructure/bin/cleanup.sh ${GUID}"
      }
    }
  }
}
