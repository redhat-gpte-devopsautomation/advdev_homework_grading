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
        image "docker-registry.default.svc:5000/gpte-jenkins/jenkins-agent-appdev:latest"
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
             "*** Student Repo: ${REPO}\n" +
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
      stage('First Pipeline run for Tasks') {
        steps {
          echo "Executing Initial Tasks Pipeline - BLUE deployment"
          sh "oc start-build --wait=true tasks-pipeline -n ${GUID}-jenkins"
        }
      }
    }
    stage('Test Tasks in Dev') {
      steps {
        echo "Testing Tasks Dev Application"
        script {
          // Test Dev Tasks
          // def devTasksRoute = sh(returnStdout: true, script: "curl tasks-${GUID}-tasks-dev.apps.${CLUSTER}/ws/appname/").trim()
          // echo "Dev Tasks Route: " + devTasksRoute
          // Check if the returned string contains "Tasks (Dev)"
          // if (devTasksRoute.contains("Tasks (Dev)")) {
          //   echo "*** Tasks (Dev) validated successfully."
          // }
          // else {
          //   error("Tasks (Dev) returned unexpected name.")
          // }
        }
      }
    }
    stage('Test Blue Services in Prod') {
      steps {
        echo "Testing Prod Services (BLUE)"
        script {
          // Test Blue Tasks
          // def tasksRoute = sh(returnStdout: true, script: "curl tasks-${GUID}-tasks-prod.apps.${CLUSTER}/ws/appname/").trim()
          // // Check if the returned string contains "Tasks (Blue)"
          // echo "Tasks Route: " + tasksRoute
          // if (tasksRoute.contains("ParksMap (Blue)")) {
          //   echo "*** Tasks (Blue) validated successfully."
          // }
          // else {
          //   error("Tasks (Blue) returned unexpected name.")
          // }
        }
      }
    }
    stage("Second Pipeline Runs (from Blue to Green)") {
      stage('Second Pipeline run for Task Service') {
        steps {
          echo "Executing Second Tasks Pipeline - GREEN deployment"
          sh "oc start-build --wait=true tasks-pipeline -n ${GUID}-jenkins"
        }
      }   
    }
    stage('Test Green Parksmap in Prod') {
      steps {
        echo "Testing Prod Parksmap Application (GREEN)"
        script {
          // Test Blue Tasks
          // def tasksRoute = sh(returnStdout: true, script: "curl tasks-${GUID}-tasks-prod.apps.${CLUSTER}/ws/appname/").trim()
          // // Check if the returned string contains "Tasks (Green)"
          // echo "Tasks Route: " + tasksRoute
          // if (tasksRoute.contains("ParksMap (Green)")) {
          //   echo "*** Tasks (Green) validated successfully."
          // }
          // else {
          //   error("Tasks (Green) returned unexpected name.")
          // }
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
