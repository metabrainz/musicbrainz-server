
SET client_min_messages TO 'WARNING';



INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');

ALTER SEQUENCE gender_id_seq RESTART 3;


