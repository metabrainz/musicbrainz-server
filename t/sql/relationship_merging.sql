INSERT INTO label_name (id, name) VALUES (1, 'A'), (2, 'B'), (3, 'C');
INSERT INTO label (id, name, sort_name, gid)
    VALUES (1, 1, 1, '9b335b20-5f88-11e0-80e3-0800200c9a66'),
           (2, 2, 2, 'a2b31070-5f88-11e0-80e3-0800200c9a66'),
           (3, 3, 3, 'a9de8b40-5f88-11e0-80e3-0800200c9a66');

INSERT INTO artist_name (id, name) VALUES (1, 'Artist 1'), (2, 'Artist 2'), (3, 'Artist 3');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', 1, 1),
           (2, '2fed031c-0e89-406e-b9f0-3d192637907a', 2, 2),
           (3, '4444031c-0e89-406e-b9f0-3d192637907a', 3, 3);

INSERT INTO link_attribute_type (id, root, gid, name)
    VALUES (1, 1, '36990974-4f29-4ea1-b562-3838fa9b8832', 'Additional'),
           (2, 2, '108d76bd-95eb-4099-aed6-447e4ec78553', 'instrument');

INSERT INTO link_attribute_type (id, parent, root, gid, name)
    VALUES (3, 2, 2, '4f7bb10f-396c-466a-8221-8e93f5e454f9', 'string instruments'),
           (4, 3, 2, 'c3273296-91ba-453d-94e4-2fb6e958568e', 'guitar');

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase, description)
    VALUES (1, 'ff68bcc0-5f88-11e0-80e3-0800200c9a66', 'label', 'label', 'label AR', 'phrase', 'reverse', 'short', 'label ar desc'),
           (2, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'artist', 'instrument',
            'performed {additional} {instrument} on',
            'has {additional} {instrument} performed by',
            'performer', 'performed desc'),
           (3, '8610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'artist', 'liked',
            'liked',
            'is liked by',
            'liked', 'liked desc'),
           (4, '9610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'artist', 'liked',
            'liked grouper',
            'is liked by',
            'liked', '');

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max)
    VALUES (2, 1, 0, 1),
           (2, 2, 1, NULL);

INSERT INTO link (id, link_type) VALUES (1, 1);
INSERT INTO link (id, link_type, begin_date_year) VALUES (2, 1, 1995);
INSERT INTO link (id, link_type, attribute_count) VALUES (3, 2, 1),
                                                         (4, 2, 2);

INSERT INTO link_attribute (link, attribute_type) VALUES (3, 4),
                                                         (4, 1),
                                                         (4, 3);
