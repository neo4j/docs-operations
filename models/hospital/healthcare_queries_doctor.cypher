//
// The doctor should not be able to see some patient data, but can perform diagnoses
//

// Reading the whole database should only show patients, symptoms and diseases

RETURN "Counting all labels" AS `------------------------------------------------`;

MATCH (n) WITH labels(n) AS labels
RETURN labels, count(*);

// Alice can read patient records, but not see their addresses

RETURN "Finding patients, but not addresses" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.dateOfBirth < date('1972-06-12')
RETURN n.name, n.ssn, n.address, n.dateOfBirth;

// Alice can perform a diagnoses, by searching the symptoms and finding likely diseases

RETURN "Find likely diseases" AS `------------------------------------------------`;

MATCH (x:Patient) WHERE NOT (x)-[:DIAGNOSIS]->() WITH x.ssn as ssn SKIP 10 LIMIT 1
MATCH (n:Patient)-[:HAS]->(s:Symptom)-[:OF]->(d:Disease)
 WHERE n.ssn = ssn
RETURN n.ssn, n.name, d.name, count(s) AS score ORDER BY score DESC;

RETURN "Save diagnosis" AS `------------------------------------------------`;

WITH datetime({epochmillis:timestamp()}) AS now
WITH now, date(now) as today
MATCH (p:Patient)
  WHERE p.ssn = 1234657
MATCH (d:Disease)
  WHERE d.name = "Chronic Placeboitis"
MERGE (p)-[i:DIAGNOSIS {by: 'Alice'}]->(d)
  ON CREATE SET i.created_at = now, i.updated_at = now, i.date = today
  ON MATCH SET i.updated_at = now
RETURN p.name, d.name, i.by, i.date, duration.between(i.created_at, i.updated_at) AS updated;


