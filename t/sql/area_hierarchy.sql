SET client_min_messages TO 'WARNING';

INSERT INTO area_type (id, name) VALUES (2, 'Subdivision'), (3, 'City');

INSERT INTO area (id, gid, name, type) VALUES
  ( 432, '9d5dd675-3cf4-4296-9e39-67865ebee758', 'England', 2),
  (1178, 'f03d09b3-39dc-4083-afd6-159e3f0d462f', 'London', 3);

INSERT INTO link (id, link_type) VALUES (1, 356);
INSERT INTO l_area_area (link, entity0, entity1) VALUES
  (1, 221, 432),
  (1, 432, 1178);
