
SET client_min_messages TO 'WARNING';



INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');
INSERT INTO gender (id, name) VALUES (3, 'Other');

ALTER SEQUENCE gender_id_seq RESTART 4;


