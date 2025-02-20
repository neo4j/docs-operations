//
// This script builds the tables of diseases and symptoms
//

// Delete previous data
MATCH (n:Symptom) DETACH DELETE n;
MATCH (n:Disease) DETACH DELETE n;

// Build new semi-random data for symptoms
WITH ['Itchy','Scratchy','Sore','Swollen','Red','Inflamed','Angry','Sad','Pale','Dizzy'] AS symptoms
UNWIND symptoms AS symptom
MERGE (s:Symptom {name:symptom})
ON CREATE SET s.description = 'Looks ' + toLower(symptom)
RETURN s.name, s.description;

// Build new semi-random data for diseases
WITH
  ['Argitis','Whatitis','Otheritis','Someitis','Placeboitis','Yellowitis'] AS diseases,
  ['Chronic','Acute'] AS severity
UNWIND diseases AS disease
UNWIND severity as sev
MERGE (d:Disease {name:sev+' '+disease})
ON CREATE SET d.description = sev + ' ' + toLower(disease)
RETURN d.name, d.description;

MATCH (s:Symptom) WITH collect(s) as symptoms
WITH symptoms, size(symptoms) / 2 as maxsym
MATCH (d:Disease)
UNWIND range(0,maxsym) as symi
WITH d, symi, symptoms, toInteger(size(symptoms) * rand()) as si, rand()/2 + 0.5 AS prob
WITH d, symptoms[si] AS s, prob
MERGE (s)-[o:OF]->(d)
ON CREATE SET o.probability = prob
RETURN d.name, o.probability, s.name;

// Ensure that the as yet non-existent types can be used

CALL db.createRelationshipType('DIAGNOSIS');
CALL db.createProperty('by');
CALL db.createProperty('date');
CALL db.createProperty('description');
CALL db.createProperty('created_at');
CALL db.createProperty('updated_at');


