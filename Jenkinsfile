// This pipeline automatically creates a full homework
// environment for OpenShift Advanced Application Development Homework
// and then executes the pipelines to ensure that everything works
//
// Successful completion of this pipeline means that the
// student passed the homework assignment
// Failure of the pipeline means that the student failed
// the homework assignment

// How to setup:
// Create a persistent Jenkins in a separate project (e.g. gpte-jenkins)
// Add self-provisioner role to the service account jenkins
//     oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:gpte-jenkins:jenkins 
// Create an Item of type Pipeline (Use name "HomeworkGrading")
// Create two Parameters:
// - GUID (type String):    GUID to prefix all projects
// - REPO (type String):    full URL to the public Homework Repo
//                          (either Gogs or Github)
// - DELETE (type Boolean): Default: true
//                          If true will delete all created projects
//                          after a successful run.
// Use https://github.com/wkulhanek/advdev_homework_grading as the Git Repo
//     and 'Jenkinsfile' as the Jenkinsfile.

pipeline {
  agent any
  stages {
    stage('Get Student Homework Repo') {
      steps {
        echo "*******************************************************"
        echo "*** Advanced OpenShift Development Homework Grading ***"
        echo "*** GUID:         ${GUID}"
        echo "*** Student Repo: ${REPO}"
        echo "*** DELETE:       ${DELETE}"
        echo "*******************************************************"

        echo "Cloning Infrastructure Project"
        git '${REPO}'
      }
    }
    stage("Setup Infrastructure") {
      failFast true
      parallel {
        stage("Setup Nexus") {
          steps {
            echo "Setting up Nexus."
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
            sh "./Infrastructure/bin/setup_jenkins.sh ${GUID} ${REPO}"
          }
        }
        stage("Setup Development Project") {
          steps {
            echo "Creating Development Project"
            sh "./Infrastructure/bin/setup_dev.sh ${GUID}"
          }
        }
        stage("Setup Production Project") {
          steps {
            echo "Creating Production Project"
            sh "./Infrastructure/bin/setup_prod.sh ${GUID}"
          }
        }
      }
    }
    stage('First (Blue) Pipeline run for MLB Parks Service') {
      steps {
        echo "Executing Initial MLB Parks Pipeline - BLUE deployment"
        // "oc start build --follow nationalparks-pipeline -n ${GUID}-jenkins"
      }
    }
    stage('First (Blue) Pipeline run for National Parks Service') {
      steps {
        echo "Executing Initial National Parks Pipeline - BLUE deployment"
        // "oc start build --follow mlbparks-pipeline -n ${GUID}-jenkins"
      }
    }
    stage('First (Blue) Pipeline run for ParksMap Service') {
      steps {
        echo "Executing Initial ParksMap Pipeline - BLUE deployment"
        // "oc start build --follow parksmap-pipeline -n ${GUID}-jenkins"
      }
    }
    stage('Test Blue Parksmap in Prod') {
      steps {
        echo "Testing Blue Prod Parksmap Application"
        // TBD
      }
    }
    stage('Second (Green) Pipeline run for MLB Parks Service') {
      steps {
        echo "Executing Initial MLB Parks Pipeline - BLUE deployment"
        // "oc start build --follow nationalparks-pipeline -n ${GUID}-jenkins"
      }
    }
    stage('Second (Green) Pipeline run for National Parks Service') {
      steps {
        echo "Executing Initial National Parks Pipeline - BLUE deployment"
        // "oc start build --follow mlbparks-pipeline -n ${GUID}-jenkins"
      }
    }
    stage('Second (Green) Pipeline run for ParksMap Service') {
      steps {
        echo "Executing Initial ParksMap Pipeline - BLUE deployment"
        // "oc start build --follow parksmap-pipeline -n ${GUID}-jenkins"
      }
    }
    stage('Test Parksmap in Dev') {
      steps {
        echo "Testing Dev Parksmap Application"
        // TBD
      }
    }
    stage('Test Green Parksmap in Prod') {
      steps {
        echo "Testing Green Prod Parksmap Application"
        // TBD
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