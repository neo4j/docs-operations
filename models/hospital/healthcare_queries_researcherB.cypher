//
// The researcher is read-only and in addition cannot see any patient data
//

// Charlie can read patient records but see very little

RETURN "Finding patients, but not named, ssn or addresses" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.dateOfBirth < date('1972-06-12')
RETURN n.name, n.ssn, n.address, n.dateOfBirth;

// Charlie can perform statistical analysis

RETURN "Finding diseases scored" AS `------------------------------------------------`;

WITH datetime() - duration({years:25}) AS timeLimit
MATCH (n:Patient)
WHERE n.dateOfBirth > date(timeLimit)
MATCH (n)-[h:HAS]->(s:Symptom)-[o:OF]->(d:Disease)
WITH d.name AS disease, o.probability AS prob
RETURN disease, sum(prob) AS score ORDER BY score DESC LIMIT 10;
