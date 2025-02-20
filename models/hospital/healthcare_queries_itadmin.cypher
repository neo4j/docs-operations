//
// The IT-Admin can do everything except see SSN
//

// Tina can read patient records, but not see their SSN

RETURN "Finding patients, but not SSN" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.dateOfBirth < date('1972-06-12')
RETURN n.name, n.ssn, n.address, n.dateOfBirth;

// Tina can read patients and diseases but cannot create DIAGNOSIS relationships

RETURN "Finding patients and diseases, but cannot create DIAGNOSIS" AS `------------------------------------------------`;

MATCH (n:Patient), (d:Disease)
CREATE (n)-[:DIAGNOSIS]->(d);


