INSERT INTO label (id, name, gid)
    VALUES (1, 'A', '9b335b20-5f88-11e0-80e3-0800200c9a66'),
           (2, 'B', 'a2b31070-5f88-11e0-80e3-0800200c9a66'),
           (3, 'C', 'a9de8b40-5f88-11e0-80e3-0800200c9a66');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', 'Artist 1', 'Artist 1'),
           (2, '2fed031c-0e89-406e-b9f0-3d192637907a', 'Artist 2', 'Artist 2'),
           (3, '4444031c-0e89-406e-b9f0-3d192637907a', 'Artist 3', 'Artist 3');

INSERT INTO link (id, link_type) VALUES (1, 200);
INSERT INTO link (id, link_type, begin_date_year) VALUES (2, 200, 1995);
INSERT INTO link (id, link_type, attribute_count) VALUES (3, 148, 1),
                                                         (4, 148, 2),
                                                         (5, 116, 0);

INSERT INTO link_attribute (link, attribute_type) VALUES (3, 229),
                                                         (4, 1),
                                                         (4, 302);
