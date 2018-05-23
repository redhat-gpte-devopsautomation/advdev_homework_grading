// This pipeline automatically creates a full homework
// environment for OpenShift Advanced Application Development Homework
// and then executes the pipelines to ensure that everything works
//
// Successful completion of this pipeline means that the student passed the
// homework assignment
// Failure of the pipeline means that the student failed the homework assignment

def GUID = 'xyz'
node {
  stage('Setup Environment') {
    echo "Cloning Infrastructure Project"
    git "http://parks:r3dh4t1!@gogs-$GUID-gogs.apps.na37.openshift.opentlc.com/AppDevHomework/Infrastructure"
  }
  stage('Setup Infrastructure') {
    echo "Setting up Nexus."
    shell "./bin/setup_nexus.sh $GUID"

    echo "Setting up Sonarqube"
    shell "./bin/setup_sonar.sh $GUID"

    echo "Setting up Jenkins"
    shell "./bin/setup_jenkins.sh $GUID"

    echo "Creating Development Project"
    shell "./bin/setup_dev.sh $GUID"

    echo "Creating Production Project"
    shell "./bin/setup_prod.sh $GUID"
  }
  stage('Initial (Blue) build for Nationalparks') {
    "oc start build --follow nationalparks -n $GUID-jenkins"
  }
  stage('Initial (Blue) build for MLBParks') {
    "oc start build --follow mlbparks -n $GUID-jenkins"
  }
  stage('Initial (Blue) build for Parksmap') {
    "oc start build --follow parksmap -n $GUID-jenkins"
  }
  stage('Test Parksmap in Dev') {
    echo "Testing Dev Parksmap Application"
    // TBD
  }
  stage('Test Blue Parksmap in Prod') {
    echo "Testing Blue Prod Parksmap Application"
    // TBD
  }
  stage('Second (Green) build for Nationalparks') {
    "oc start build --follow nationalparks -n $GUID-jenkins"
  }
  stage('Second (Green) build for MLBParks') {
    "oc start build --follow mlbparks -n $GUID-jenkins"
  }
  stage('Second (Green) build for Parksmap') {
    "oc start build --follow parksmap -n $GUID-jenkins"
  }
  stage('Test Parksmap in Dev') {
    echo "Testing Dev Parksmap Application"
    // TBD
  }
  stage('Test Green Parksmap in Prod') {
    echo "Testing Green Prod Parksmap Application"
    // TBD
  }
}