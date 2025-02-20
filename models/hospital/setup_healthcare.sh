#!/bin/bash

source healthcare_config.sh

#bin/neo4j-admin dbms set-initial-password $NEO4J_PASSWORD
#bin/neo4j start
#sleep 60

# Create the database

echo -e "\nCreating the database $INDEXES_LABELS\n"
dbfile=/tmp/healthcare_database.txt
if [ "$DB_NAME" != "neo4j" ] ; then
  echo "CREATE DATABASE $DB_NAME IF NOT EXISTS;" | $CYPHER_SHELL $SY_CONNECT
  sleep 2
fi
echo "SHOW DATABASES WHERE name = '$DB_NAME';" | $CYPHER_SHELL $SY_CONNECT > $dbfile

function makeDetectedFile
{
  DB_ADDRESS=$1
  DB_CONNECT="-d $DB_NAME -u $NEO4J_USERNAME -p $NEO4J_PASSWORD -a $DB_ADDRESS"
  echo "#!/bin/bash" > healthcare_detected.sh
  echo "DB_ADDRESS=\"$DB_ADDRESS\"" >> healthcare_detected.sh
  echo "DB_CONNECT=\"$DB_CONNECT\"" >> healthcare_detected.sh
}

rm -f healthcare_detected.sh
if [ -n "$ENABLE_CLUSTERING" ] ; then
  echo "Configuration uses clustering - searching for cluster leader for write commands"
  cat $dbfile | grep leader >/dev/null
  if [ "$?" = "0" ] ; then
    echo "Found a leader for $DB_NAME"
    DB_ADDRESS=`cat $dbfile | grep leader | awk -F'"' '{printf "bolt://%s\n",$4}'`
    DB_CONNECT="-d $DB_NAME -u $NEO4J_USERNAME -p $NEO4J_PASSWORD -a $DB_ADDRESS"
    makeDetectedFile $DB_ADDRESS
  else
    echo "Did not find a leader for $DB_NAME"
    cat $dbfile
  fi
else
  makeDetectedFile $NEO4J_ADDRESS
fi
echo "Connecting to 'system' using: $SY_CONNECT"
echo "Connecting to '$DB_NAME' using: $DB_CONNECT"

# Reconfigure indexes

echo -e "\nCreating indexes for $INDEXES_LABELS\n"
for label in $INDEXES_LABELS
do
  property="name"
  index_name="${DB_NAME}_${label,,}_${property}"
  new_index_definition="FOR (n:${label}) ON (n.${property})"
  echo "Recreating index $index_name"
  echo "DROP INDEX $index_name;" | $CYPHER_SHELL $DB_CONNECT 2>/dev/null
  echo "CREATE INDEX $index_name $new_index_definition;" | $CYPHER_SHELL $DB_CONNECT
done
echo "SHOW INDEXES" | $CYPHER_SHELL $DB_CONNECT

# Model with only built-in roles

echo -e "\nCreating data with privileges based on built-in roles\n"

cat setup_healthcare.cypher | $CYPHER_SHELL $SY_CONNECT
cat make_healthcare_meta.cypher | $CYPHER_SHELL $DB_CONNECT
cat make_healthcare.cypher | $CYPHER_SHELL $DB_CONNECT

# Enhance model with fine-grained security

echo -e "\nEnhancing security model with fine-grained privileges\n"

cat setup_healthcare_privileges.cypher | sed -e "s/DATABASE healthcare/DATABASE $DB_NAME/" -e "s/GRAPH healthcare/GRAPH $DB_NAME/" | $CYPHER_SHELL --format verbose $SY_CONNECT
