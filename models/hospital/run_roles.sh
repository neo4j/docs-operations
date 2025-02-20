#!/bin/bash

source healthcare_config.sh
USER_ROLES="bob.receptionist tina.itadmin charlie.researcherB charlie.researcherW alice.doctor daniel.broken daniel.nurse daniel.junior tina.userManager"

#GRANT ROLE itadmin TO tina;
#GRANT ROLE researcherB TO charlie;
#GRANT ROLE doctor TO alice;
#GRANT ROLE receptionist TO bob;
#GRANT ROLE doctor, receptionist TO daniel;

function revokeRoles
{
  u=$1
  for r in "${@:2}"
  do
    echo "REVOKE ROLE $r FROM $u;"
    echo "REVOKE ROLE $r FROM $u;" | $CYPHER_SHELL $SY_CONNECT 2>/dev/null    
  done
}

function grantRoles
{
  u=$1
  for r in "${@:2}"
  do
    echo "GRANT ROLE $r TO $u;"
    echo "GRANT ROLE $r TO $u;" | $CYPHER_SHELL $SY_CONNECT 2>/dev/null    
  done
}

function testUserRole
{
  user=$1
  role=$2
  echo -e "\nTesting '$user' as '$role'\n----------------------------------\n"
  file="healthcare_queries_${role}.cypher"
  if [ -f "$file" ] ; then
    dbname=$DB_NAME
    dbaddress=$DB_ADDRESS
    if [ $role == "userManager" ] ; then
      dbname="system"
      dbaddress="$NEO4J_ADDRESS"
    fi
    if [ $role == "broken" ] ; then
      revokeRoles $user doctor receptionist disableDiagnoses nurse
      grantRoles $user doctor receptionist
    elif [ $role == "junior" ] ; then
      revokeRoles $user doctor receptionist disableDiagnoses nurse
      grantRoles $user nurse disableDiagnoses
    elif [ $role == "nurse" ] ; then
      revokeRoles $user doctor receptionist disableDiagnoses nurse
      grantRoles $user nurse
    elif [ $role == "userManager" ] ; then
      revokeRoles $user $role itadmin
      grantRoles $user $role
    elif [ $role == "itadmin" ] ; then
      revokeRoles $user $role userManager
      grantRoles $user $role
    else
      revokeRoles $user $role
      grantRoles $user $role
    fi
    echo "SHOW POPULATED ROLES;" | $CYPHER_SHELL $SY_CONNECT
    echo "SHOW USER $user PRIVILEGES AS COMMANDS;" | $CYPHER_SHELL --format verbose $SY_CONNECT

    USER_CONNECT="-u $user -p secret -a $dbaddress"
    cat $file | sed -e "s/DATABASE healthcare/DATABASE $DB_NAME/" -e "s/GRAPH healthcare/GRAPH $DB_NAME/" | $CYPHER_SHELL --format verbose -d $dbname $USER_CONNECT
    
    echo "REVOKE ROLE $role FROM $user;" | $CYPHER_SHELL $SY_CONNECT 2>/dev/null
  else
    echo "No such file: '$file'"
  fi
  echo -e "\n"
}

for userRole in $USER_ROLES
do
  readarray -d . -t strarr <<< "${userRole}"
  user="${strarr[0]}"
  rolex="${strarr[1]}"
  role="${rolex//[$'\n']}"
  selected=""
  if [[ -z "$@" ]] ; then
    selected="all"
  elif [[ "$@" == *"$role"* ]] ; then
    echo "Selected role: $role"
    selected=$role
  fi
  if [ -n "$selected" ] ; then
    testUserRole $user $role
  fi
done
