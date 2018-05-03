#!/bin/bash

echo "OpenShift Advanced Development Homework Grading Application"

oc create -f ./grading_bc.yaml
oc start-build appdev-homework-grading
