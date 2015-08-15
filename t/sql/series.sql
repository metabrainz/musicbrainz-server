SET client_min_messages TO 'WARNING';

INSERT INTO series_alias_type (id, name) VALUES (1, 'Series name'), (2, 'Search hint');

INSERT INTO link_attribute_type (id, root, parent, child_order, gid, name, description) VALUES
    (1, 1, NULL, 0, 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a', 'number',
        'This attribute indicates the number of a work in a series.'
    );

INSERT INTO link_text_attribute_type VALUES (1);

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max) VALUES
    (740, 1, 0, 1), (743, 1, 0, 1);

INSERT INTO series (id, gid, name, comment, type, ordering_attribute, ordering_type)
    VALUES (1, 'a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', 'Test Recording Series', 'test comment 1', 3, 1, 1),
           (2, '2e8872b9-2745-4807-a84e-094d425ec267', 'Test Work Series', 'test comment 2', 4, 1, 2),
           (3, 'dbb23c50-d4e4-11e3-9c1a-0800200c9a66', 'Dumb Recording Series', '', 3, 1, 1);

INSERT INTO series_alias (id, series, name, type, sort_name) VALUES
    (1, 1, 'Test Recording Series Alias', 2, 'Test Recording Series Alias');

INSERT INTO link (id, link_type, attribute_count) VALUES
    (1, 740, 1), (2, 740, 1), (3, 740, 1), (4, 740, 1),
    (5, 743, 1), (6, 743, 1), (7, 743, 1), (8, 743, 1);

INSERT INTO link_attribute (link, attribute_type) VALUES
    (1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1), (8, 1);

INSERT INTO link_attribute_text_value (link, attribute_type, text_value) VALUES
    (1, 1, 'A1'), (2, 1, 'A11'), (3, 1, 'A10'), (4, 1, 'A100'),
    (5, 1, 'WTF 87'), (6, 1, 'WTF 21'), (7, 1, 'WTF 99'), (8, 1, 'WTF 12');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Shared Name', 1);

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '123c079d-374e-4436-9448-da92dedef3ce', 'Dancing Queen', 1, 123456),
    (2, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'King of the Mountain', 1, 293720),
    (3, '659f405b-b4ee-4033-868a-0daa27784b89', 'π', 1, 369680),
    (4, 'ae674299-2824-4500-9516-653ac1bc6f80', 'Bertie', 1, 258839);

INSERT INTO work_type (id, name) VALUES (1, 'Song');

INSERT INTO work (id, gid, name, type) VALUES
    (1, '7e0e3ea0-d674-11e3-9c1a-0800200c9a66', 'Wōrk1', 1),
    (2, 'f89a8de8-f0e3-453c-9516-5bc3edd2fd88', 'Wōrk2', 1),
    (3, '8234f641-4231-4b2f-a14f-c469b9b8de11', 'Wōrk3', 1),
    (4, 'efe72c7d-652d-4243-b01b-152997bb730e', 'Wōrk4', 1);

INSERT INTO l_recording_series (id, link, entity0, entity1, link_order) VALUES
    (1, 1, 1, 1, 1), (2, 2, 2, 1, 2), (3, 3, 3, 3, 1), (4, 4, 4, 3, 2);

INSERT INTO l_series_work (id, link, entity0, entity1, link_order) VALUES
    (1, 5, 2, 1, 1), (2, 6, 2, 2, 2), (3, 7, 2, 3, 3), (4, 8, 2, 4, 4);
