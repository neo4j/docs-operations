//
// The nurse is supposed to be able to perform both doctor and receptionist actions
// But this 'broken' nurse is made by combining the two roles 'doctor' and 'receptionist'
// with undesired consequences. They keep the restrictions of the doctor!
//

// Daniel can read patient records, but not see their addresses

RETURN "Finding patients, but not addresses" AS `------------------------------------------------`;

MATCH (n:Patient)
 WHERE n.dateOfBirth < date('1972-06-12')
RETURN n.name, n.ssn, n.address, n.dateOfBirth;


