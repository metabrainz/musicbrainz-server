INSERT INTO script (id, iso_code, iso_number, name)
    VALUES (112, 'Zsym', '996', 'Symbols');

INSERT INTO area (id, gid, name, type)
    VALUES (107, '2db42837-c832-3c27-b4a3-08198f75693c', 'Japan', 1);

INSERT INTO country_area (area) VALUES (107);

INSERT INTO iso_3166_1 (area, code) VALUES (107, 'JP');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (39282, '0798d15b-64e2-499f-9969-70167b1d8617', 'Boredoms', 'Boredoms'),
           (66666, '1e6092a0-73d3-465a-b06a-99c81f7bec37', 'a fake artist', 'a fake artist');

INSERT INTO url (id, gid, url)
    VALUES (2, 'de409476-4ad8-4ce8-af2f-d47bee0edf97', 'http://en.wikipedia.org/wiki/Boredoms');
