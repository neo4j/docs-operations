//
// This script builds the tables of patients
//


// Delete previous data
MATCH (n:Patient) DETACH DELETE n;

// Build new semi-random data for patients
WITH
  ['Jack','Mary','Sally','Mark','Joe','Jane','Bob','Ally'] AS firstnames,
  ['Anderson','Jackson','Svensson','Smith','Stone'] AS surnames,
  ['mymail.com','example.com','other.org','net.net'] AS domains
UNWIND range(0,100) AS uid
WITH 1234567+uid AS ssn,
  firstnames[uid%size(firstnames)] AS firstname,
  surnames[uid%size(surnames)] AS surname,
  domains[uid%size(domains)] AS domain
WITH ssn, firstname, surname,
  tolower(firstname + '.' + surname + '@' + domain) AS email,
  toInteger(1500000000000 * rand()) AS ts
MERGE (p:Patient {ssn:ssn})
ON CREATE SET p.name = firstname + ' ' + surname,
  p.email = email,
  p.address = '1 secret way, downtown',
  p.dateOfBirth = date(datetime({epochmillis:ts}))
RETURN count(p);

// Build new semi-random data for patients' symptoms
MATCH (s:Symptom) WITH collect(s) as symptoms
WITH symptoms, size(symptoms) / 2 as maxsym, 1500000000000 AS base, 75477004177 AS diff
MATCH (p:Patient)
UNWIND range(0,maxsym) as symi
WITH p, symi, symptoms, toInteger(size(symptoms) * rand()) as si, rand()/2 + 0.5 AS prob, base + toInteger(diff * rand()) AS ts
WITH p, symptoms[si] AS s, prob, ts
MERGE (p)-[h:HAS]->(s)
ON CREATE SET h.date = date(datetime({epochmillis:ts}))
RETURN p.name, p.dateOfBirth, h.date, s.name;

