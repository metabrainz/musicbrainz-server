
SET client_min_messages TO 'WARNING';





INSERT INTO editor (id, name, password) VALUES
    (1, 'editor1', 'pass'),
    (2, 'editor2', 'pass'),
    (3, 'editor3', 'pass'),
    (4, 'editor4', 'pass');

SELECT setval('label_id_seq', 99);
SELECT setval('label_name_id_seq', 99);


