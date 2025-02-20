//
// The nurse is supposed to be able to perform both doctor and receptionist actions.
// This is basically the doctor without restrictions.
//

// Daniel can read patient records, and see their addresses

RETURN "Finding patients, and see addresses" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.dateOfBirth < date('1972-06-12')
RETURN n.name, n.ssn, n.address, n.dateOfBirth;

// Daniel can perform a diagnoses, by searching the symptoms and finding likely diseases

RETURN "Find likely diseases" AS `------------------------------------------------`;

MATCH (x:Patient) WHERE NOT (x)-[:DIAGNOSIS]->() WITH x.ssn as ssn SKIP 10 LIMIT 1
MATCH (n:Patient)-[:HAS]->(s:Symptom)-[:OF]->(d:Disease)
 WHERE n.ssn = ssn
RETURN n.ssn, n.name, d.name, count(s) AS score ORDER BY score DESC;

// Daniel can NOT save diagnoses when he is a JUNIOR nurse

RETURN "Save diagnosis" AS `------------------------------------------------`;

WITH date(datetime({epochmillis:timestamp()})) AS today
MATCH (p:Patient)
  WHERE p.ssn = 1234650
MATCH (d:Disease)
  WHERE d.name = "Chronic Placeboitis"
MERGE (p)-[i:DIAGNOSIS {by: 'Daniel'}]->(d)
  ON CREATE SET i.date = today
RETURN p.name, d.name, i.by, i.date;

