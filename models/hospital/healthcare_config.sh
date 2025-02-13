#!/bin/bash

INDEXES_LABELS="Patient Symptom Disease"
DB_NAME="healthcare"
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=my-secret
NEO4J_BOLT_PORT=7688
NEO4J_ADDRESS=neo4j://localhost:$NEO4J_BOLT_PORT
NEO4J_CONNECT="-u $NEO4J_USERNAME -p $NEO4J_PASSWORD -a $NEO4J_ADDRESS"
DB_CONNECT="-d $DB_NAME $NEO4J_CONNECT"
SY_CONNECT="-d system $NEO4J_CONNECT"
ENABLE_CLUSTERING=true

# If these scripts are copied into the root of a neo4j intallation use bin/cypher-shell
# Otherwise use an absolute path like: CYPHER_SHELL=/home/path/to/neo4j-enterprise-5.26.2/bin/cypher-shell
CYPHER_SHELL=bin/cypher-shell

# to have a custom config that should not be checked into git, create a file called healthcare_local.sh
# and fill it with overriding settings. For example one cluster config we tested on AWS used the following:
#NEO4J_ADDRESS=bolt://ec2-52-214-104-194.eu-west-1.compute.amazonaws.com:10000
#NEO4J_CONNECT="-u $NEO4J_USERNAME -p $NEO4J_PASSWORD -a $NEO4J_ADDRESS"
#DB_CONNECT="-d $DB_NAME $NEO4J_CONNECT"
#SY_CONNECT="-d system $NEO4J_CONNECT"
#CYPHER_SHELL=/home/path/to/neo4j-enterprise-5.26.2/bin/cypher-shell

if [ -f ./healthcare_local.sh ] ; then
  source ./healthcare_local.sh
fi

if [ -f ./healthcare_detected.sh ] ; then
  source ./healthcare_detected.sh
fi
