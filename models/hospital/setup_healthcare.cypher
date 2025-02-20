DROP USER charlie IF EXISTS;
DROP USER alice IF EXISTS;
DROP USER daniel IF EXISTS;
DROP USER bob IF EXISTS;
DROP USER tina IF EXISTS;
CREATE USER charlie IF NOT EXISTS SET PASSWORD 'secretpass1' CHANGE NOT REQUIRED;
CREATE USER alice IF NOT EXISTS SET PASSWORD 'secretpass2' CHANGE NOT REQUIRED;
CREATE USER daniel IF NOT EXISTS SET PASSWORD 'secretpass3' CHANGE NOT REQUIRED;
CREATE USER bob IF NOT EXISTS SET PASSWORD 'secretpass4' CHANGE NOT REQUIRED;
CREATE USER tina IF NOT EXISTS SET PASSWORD 'secretpass5' CHANGE NOT REQUIRED;
SHOW DATABASES;
GRANT ROLE reader TO charlie;
GRANT ROLE editor TO alice;
GRANT ROLE editor TO daniel;
GRANT ROLE editor TO bob;
GRANT ROLE admin TO tina;
SHOW USERS;

