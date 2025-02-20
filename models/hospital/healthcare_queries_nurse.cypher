//
// The nurse is supposed to be able to perform both doctor and receptionist actions.
// This is basically the doctor without restrictions.
//

// Daniel can read patient records, and see their addresses

RETURN "Finding patients, and see addresses" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.dateOfBirth < date('1972-06-12')
RETURN n.name, n.ssn, n.address, n.dateOfBirth;

// Daniel can save diagnoses just like Alice

RETURN "Save diagnosis" AS `------------------------------------------------`;

WITH date(datetime({epochmillis:timestamp()})) AS today
MATCH (p:Patient)
  WHERE p.ssn = 1234657
MATCH (d:Disease)
  WHERE d.name = "Chronic Placeboitis"
MERGE (p)-[i:DIAGNOSIS {by: 'Daniel'}]->(d)
  ON CREATE SET i.date = today
RETURN p.name, d.name, i.by, i.date;


