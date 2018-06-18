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
// Create an Item of type Pipeline (Use name "HomeworkGrading")
// Create two Parameters:
// - GUID (type String): GUID to prefix all projects
// - REPO (type String): full URL to the Homework Repo (either Gogs or Github)
//                       This needs to be a public Repo
// Use https://github.com/wkulhanek/advdev_homework_grading as the Git Repo
//     and 'Jenkinsfile' as the Jenkinsfile.

node {
  stage('Setup Environment') {
    echo "Cloning Infrastructure Project"
    git '${REPO}'
  }
  stage('Setup Infrastructure') {
    echo "Setting up Nexus."
    sh "./Infrastructure/bin/setup_nexus.sh ${GUID}"

    echo "Setting up Sonarqube"
    sh "./Infrastructure/bin/setup_sonar.sh ${GUID}"

    echo "Setting up Jenkins"
    sh "./Infrastructure/bin/setup_jenkins.sh ${GUID} ${REPO}"

    echo "Creating Development Project"
    sh "./Infrastructure/bin/setup_dev.sh ${GUID}"

    echo "Creating Production Project"
    sh "./Infrastructure/bin/setup_prod.sh ${GUID}"
  }
  stage('First (Blue) Pipeline run for MLB Parks Service') {
    echo "Executing Initial MLB Parks Pipeline - BLUE deployment"
    // "oc start build --follow nationalparks -n ${GUID}-jenkins"
  }
  stage('First (Blue) Pipeline run for National Parks Service') {
    echo "Executing Initial National Parks Pipeline - BLUE deployment"
    // "oc start build --follow mlbparks -n ${GUID}-jenkins"
  }
  stage('First (Blue) Pipeline run for ParksMap Service') {
    echo "Executing Initial ParksMap Pipeline - BLUE deployment"
    // "oc start build --follow parksmap -n ${GUID}-jenkins"
  }
  stage('Test Parksmap in Dev') {
    echo "Testing Dev Parksmap Application"
    // TBD
  }
  stage('Test Blue Parksmap in Prod') {
    echo "Testing Blue Prod Parksmap Application"
    // TBD
  }
  stage('Second (Green) Pipeline run for MLB Parks Service') {
    echo "Executing Initial MLB Parks Pipeline - BLUE deployment"
    // "oc start build --follow nationalparks -n ${GUID}-jenkins"
  }
  stage('Second (Green) Pipeline run for National Parks Service') {
    echo "Executing Initial National Parks Pipeline - BLUE deployment"
    // "oc start build --follow mlbparks -n ${GUID}-jenkins"
  }
  stage('Second (Green) Pipeline run for ParksMap Service') {
    echo "Executing Initial ParksMap Pipeline - BLUE deployment"
    // "oc start build --follow parksmap -n ${GUID}-jenkins"
  }
  stage('Test Green Parksmap in Dev') {
    echo "Testing Dev Parksmap Application"
    // TBD
  }
  stage('Test Green Parksmap in Prod') {
    echo "Testing Green Prod Parksmap Application"
    // TBD
  }
  stage('Cleanup') {
    echo "Cleanup - deleting all projects for GUID=${GUID}"

    sleep 120
    sh "./Infrastructure/bin/cleanup.sh ${GUID}"
  }
}