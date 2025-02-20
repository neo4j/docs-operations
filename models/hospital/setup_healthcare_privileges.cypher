// Remove previous coarse-grain roles

REVOKE ROLE reader FROM charlie;
REVOKE ROLE editor FROM alice;
REVOKE ROLE editor FROM daniel;
REVOKE ROLE editor FROM bob;
REVOKE ROLE admin FROM tina;
SHOW USERS;

// Create new roles for fine grained privileges

DROP ROLE doctor IF EXISTS;
DROP ROLE nurse IF EXISTS;
DROP ROLE receptionist IF EXISTS;
DROP ROLE researcher IF EXISTS;
DROP ROLE researcherB IF EXISTS;
DROP ROLE researcherW IF EXISTS;
DROP ROLE disableDiagnoses IF EXISTS;
DROP ROLE itadmin IF EXISTS;
DROP ROLE userManager IF EXISTS;

CREATE ROLE doctor IF NOT EXISTS;
CREATE ROLE nurse IF NOT EXISTS;
CREATE ROLE receptionist IF NOT EXISTS;
CREATE ROLE researcherB IF NOT EXISTS;
CREATE ROLE researcherW IF NOT EXISTS;
CREATE ROLE disableDiagnoses IF NOT EXISTS;
CREATE ROLE itadmin IF NOT EXISTS AS COPY OF admin;
CREATE ROLE userManager IF NOT EXISTS;
SHOW ROLES;
SHOW ROLE doctor PRIVILEGES AS COMMANDS;
SHOW ROLE nurse PRIVILEGES AS COMMANDS;
SHOW ROLE receptionist PRIVILEGES AS COMMANDS;
SHOW ROLE researcherB PRIVILEGES AS COMMANDS;
SHOW ROLE researcherW PRIVILEGES AS COMMANDS;
SHOW ROLE disableDiagnoses PRIVILEGES AS COMMANDS;
SHOW ROLE itadmin PRIVILEGES AS COMMANDS;
SHOW ROLE userManager PRIVILEGES AS COMMANDS;

// Allow all users to access the new database

GRANT ACCESS ON DATABASE healthcare TO PUBLIC;

// Assign fine-grained privileges

// Setup `itadmin` by blacklisting on top of copy of `admin`

DENY READ {ssn} ON GRAPH healthcare NODES Patient TO itadmin;
DENY CREATE ON GRAPH healthcare RELATIONSHIPS DIAGNOSIS TO itadmin;

// Assign researcher using denylisting

// First grant read access to everything
GRANT MATCH {*}
    ON GRAPH healthcare
    TO researcherB;
// Then deny read on specific node properties
DENY READ {name, address, ssn}
    ON GRAPH healthcare
    NODES Patient
    TO researcherB;
// And deny traversal of the doctors diagnosis
DENY TRAVERSE
    ON GRAPH healthcare
    RELATIONSHIPS DIAGNOSIS
    TO researcherB;

// Assign researcher using allowlisting

// We allow the researcher to find all nodes
GRANT TRAVERSE
    ON GRAPH healthcare
    NODES *
    TO researcherW;
// Now only allow the researcher to traverse specific relationships
GRANT TRAVERSE
    ON GRAPH healthcare
    RELATIONSHIPS HAS, OF
    TO researcherW;
// Allow reading of all properties of medical metadata
GRANT READ {*}
    ON GRAPH healthcare
    NODES Symptom, Disease
    TO researcherW;
// Allow reading of all properties of the disease-symptom relationship
GRANT READ {*}
    ON GRAPH healthcare
    RELATIONSHIPS OF
    TO researcherW;
// Only allow reading dateOfBirth for research purposes
GRANT READ {dateOfBirth}
    ON GRAPH healthcare
    NODES Patient
    TO researcherW;

// Setup doctor

GRANT TRAVERSE ON GRAPH healthcare TO doctor;
GRANT READ {*} ON GRAPH healthcare TO doctor;
GRANT WRITE ON GRAPH healthcare TO doctor;
DENY READ {address} ON GRAPH healthcare NODES Patient TO doctor;
DENY SET PROPERTY {address} ON GRAPH healthcare NODES Patient TO doctor;

// Now the receptionist

GRANT MATCH {*} ON GRAPH healthcare NODES Patient TO receptionist;
GRANT CREATE ON GRAPH healthcare NODES Patient TO receptionist;
GRANT DELETE ON GRAPH healthcare NODES Patient TO receptionist;
GRANT SET PROPERTY {*} ON GRAPH healthcare NODES Patient TO receptionist;
// set label is not required for creating nodes with that label
//GRANT SET LABEL Patient ON GRAPH healthcare TO receptionist;

// Setup nurse

GRANT TRAVERSE ON GRAPH healthcare TO nurse;
GRANT READ {*} ON GRAPH healthcare TO nurse;
GRANT WRITE ON GRAPH healthcare TO nurse;

// Setup `disableDiagnoses` by blacklisting creation of the DIAGNOSIS relationship

DENY CREATE ON GRAPH healthcare RELATIONSHIPS DIAGNOSIS TO disableDiagnoses;

// Setup `userManager` with user and role management

GRANT USER MANAGEMENT ON DBMS TO userManager;
GRANT ROLE MANAGEMENT ON DBMS TO userManager;
GRANT SHOW PRIVILEGE ON DBMS TO userManager;

// Let's see the results

SHOW ROLES;
SHOW ROLE doctor PRIVILEGES AS COMMANDS;
SHOW ROLE nurse PRIVILEGES AS COMMANDS;
SHOW ROLE receptionist PRIVILEGES AS COMMANDS;
SHOW ROLE researcherB PRIVILEGES AS COMMANDS;
SHOW ROLE researcherW PRIVILEGES AS COMMANDS;
SHOW ROLE itadmin PRIVILEGES AS COMMANDS;
SHOW ROLE userManager PRIVILEGES AS COMMANDS;

