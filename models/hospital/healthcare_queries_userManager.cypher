//
// The user manager can create and assign users to roles
//

DROP USER sally IF EXISTS;

CREATE USER sally SET PASSWORD 'secret' CHANGE REQUIRED;
GRANT ROLE receptionist TO sally;
SHOW USER sally PRIVILEGES AS COMMANDS;



