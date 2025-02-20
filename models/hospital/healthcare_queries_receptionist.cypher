//
// The receptionist should only read/write patient data
//

// Reading the whole database should only show patients

RETURN "Counting all labels" AS `------------------------------------------------`;

MATCH (n) WITH labels(n) AS labels
RETURN labels, count(*);

// However, Bob is able to see all fields of the Patient records:

RETURN "Finding patients" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.dateOfBirth < date('1972-06-12')
RETURN n.name, n.ssn, n.address, n.dateOfBirth;

// Bob cannot remove a patient that has been diagnosed, because he cannot see the diagnosis

RETURN "Find a specific patient to try delete" AS `------------------------------------------------`;

MATCH (x:Patient) WITH x.ssn as ssn SKIP 10 LIMIT 1
MATCH (n:Patient)
 WHERE n.ssn = ssn
RETURN n.ssn;

// Uncomment the next section to test
//RETURN "Unable to delete a patient that is diagnosed" AS `------------------------------------------------`;

//MATCH (x:Patient) WITH x.ssn as ssn SKIP 10 LIMIT 1
//MATCH (n:Patient)
// WHERE n.ssn = ssn
//DETACH DELETE n;

RETURN "Patient should still be there after attempt to delete it" AS `------------------------------------------------`;

MATCH (x:Patient) WITH x.ssn as ssn SKIP 10 LIMIT 1
MATCH (n:Patient)
 WHERE n.ssn = ssn
RETURN n.ssn;

// Bob can create new patients, and modify and delete them, as long as they are not yet connected (diagnosed)

RETURN "Can create a new patient" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.ssn = 87654321
DETACH DELETE n;

CREATE (n:Patient {
  ssn:87654321,
  name: 'Another Patient',
  email: 'another@example.com',
  address: '1 secret way, downtown',
  dateOfBirth: date('2001-01-20')
})
RETURN n.name, n.dateOfBirth;

RETURN "Can modify a patient" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.ssn = 87654321
SET n.address = '2 streets down, uptown'
RETURN n.name, n.dateOfBirth, n.address;

RETURN "Able to delete a patient that is un-diagnosed" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.ssn = 87654321
DETACH DELETE n;

RETURN "Should not find deleted patient" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.ssn = 87654321
RETURN n.name, n.dateOfBirth, n.address;


