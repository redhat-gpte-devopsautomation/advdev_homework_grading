// This pipeline automatically creates a full homework
// environment for OpenShift Advanced Application Development Homework
// and then executes the pipelines to ensure that everything works
//
// Successful completion of this pipeline means that the
// student passed the homework assignment
// Failure of the pipeline means that the student failed
// the homework assignment

def GUID = "wk"
node {
  stage('Setup Environment') {
    echo "Cloning Infrastructure Project"
    git credentialsId: '3f928345-6d30-48ff-84f4-a75f26313c19', url: "http://gogs-$GUID-gogs.apps.na37.openshift.opentlc.com/AppDevHomework/Parks.git"
  }
  stage('Setup Infrastructure') {
    echo "Setting up Nexus."
    sh "./Infrastructure/bin/setup_nexus.sh $GUID"

    echo "Setting up Sonarqube"
    sh "./Infrastructure/bin/setup_sonar.sh $GUID"

    echo "Setting up Jenkins"
    sh "./Infrastructure/bin/setup_jenkins.sh $GUID"

    echo "Creating Development Project"
    sh "./Infrastructure/bin/setup_dev.sh $GUID"

    echo "Creating Production Project"
    sh "./Infrastructure/bin/setup_prod.sh $GUID"
  }
  stage('First (Blue) Pipeline run for MLB Parks Service') {
    echo "Executing Initial MLB Parks Pipeline - BLUE deployment"
    // "oc start build --follow nationalparks -n $GUID-jenkins"
  }
  stage('First (Blue) Pipeline run for National Parks Service') {
    echo "Executing Initial National Parks Pipeline - BLUE deployment"
    // "oc start build --follow mlbparks -n $GUID-jenkins"
  }
  stage('First (Blue) Pipeline run for ParksMap Service') {
    echo "Executing Initial ParksMap Pipeline - BLUE deployment"
    // "oc start build --follow parksmap -n $GUID-jenkins"
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
    // "oc start build --follow nationalparks -n $GUID-jenkins"
  }
  stage('Second (Green) Pipeline run for National Parks Service') {
    echo "Executing Initial National Parks Pipeline - BLUE deployment"
    // "oc start build --follow mlbparks -n $GUID-jenkins"
  }
  stage('Second (Green) Pipeline run for ParksMap Service') {
    echo "Executing Initial ParksMap Pipeline - BLUE deployment"
    // "oc start build --follow parksmap -n $GUID-jenkins"
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
    echo "Cleanup - deleting all projects for GUID=$GUID"

    sleep 120
    sh "./Infrastructure/bin/cleanup.sh $GUID"
  }
}