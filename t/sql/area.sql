SET client_min_messages TO 'WARNING';

INSERT INTO area (id, gid, name, type) VALUES
  ( 13, '106e0bec-b638-3b37-b731-f53d507dc00e', 'Australia', 1),
  ( 81, '85752fda-13c4-31a3-bee5-0e5cb1f51dad', 'Germany', 1),
  (107, '2db42837-c832-3c27-b4a3-08198f75693c', 'Japan', 1),
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1),
  (222, '489ce91b-6658-3307-9877-795b68554c98', 'United States', 1),
  (241, '89a675c2-3e37-3518-b83c-418bad59a85a', 'Europe', 1),
  (5126, '3f179da4-83c6-4a28-a627-e46b4a8ff1ed', 'Sydney', 3);
INSERT INTO country_area (area) VALUES ( 13), ( 81), (107), (221), (222), (241);
INSERT INTO iso_3166_1 (area, code) VALUES ( 13, 'AU'), ( 81, 'DE'), (107, 'JP'), (221, 'GB'), (222, 'US'), (241, 'XE');

INSERT INTO area_alias (id, name, sort_name, type, area, edits_pending)
    VALUES (1, 'オーストラリア', 'オーストラリア', 1, 13, 0);

INSERT INTO link VALUES (118734, 356, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2013-05-17 20:05:50.534145+00', FALSE);
INSERT INTO l_area_area VALUES (4892, 118734, 13, 5126, 0, '2013-05-24 20:32:44.702487+00', 0, '', '');
