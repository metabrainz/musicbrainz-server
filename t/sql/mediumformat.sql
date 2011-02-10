
SET client_min_messages TO 'WARNING';



INSERT INTO medium_format (id, name, year) VALUES (1, 'CD', 1982);
INSERT INTO medium_format (id, name) VALUES (2, 'Vinyl');

INSERT INTO medium_format (id, name, year, child_order, parent) VALUES
    (3, '7"', NULL, 0, 2),
    (4, '12"', NULL, 1, 2);


