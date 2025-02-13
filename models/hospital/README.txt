Hospital Database With Security
===============================

This model is for an example hospital database with fine-grained sub-graph
security used to control access to parts of the data based on roles and
privileges.

This forms the background data model for the documentation found at
https://neo4j.com/docs/operations-manual/5/authentication-authorization/

Cypher Scripts
--------------

There are two main types of scripts, those running against `system` used to
setup the users, roles and security privileges, and those running against
the `healthcare` database for setting up the data model itself. These
scripts do not include the queries used by the different users to query the
database. See the docs at
https://neo4j.com/docs/operations-manual/current/authentication-authorization/
for example queries.

Run as `neo4j` against the `system` database:

* setup_healthcare.cypher
* setup_healthcare_privileges.cypher

Run as `neo4j` against the `healthcare` database:

* make_healthcare.cypher
* make_healthcare_meta.cypher

The easiest way to run all scripts is to run the two shell scripts:

* ./setup_healthcare.sh
* ./run_roles.sh

The first will run all the setup and make scripts on the system and
healthcare database to create a complete working model with users, roles and
privileges in the system database, and patients, diseases and symptoms in
the healthcare database.

The second script will run through a set of roles, and for each use a
pre-defined user, grant it the role, find a file named
healthcare_queries_$role.cypher and as that user it will run all commands in
that file against the healthcare database. This allows you to test
everything required in the above mentioned chapter and copy and paste all
query results directly into the chapter contents.

Setting up Neo4j
----------------

Note that the above script assume that the Neo4j server has been configured
to run on non startard ports so that it does not conflict with the documentation build itself.
In particular the bolt port is 7688.
See the contents of the file healthcare_config.sh for the settings, and change any
that you feel are more appropriate to your server configuration (or change your server to match
this configurations).

