SET client_min_messages TO 'WARNING';

INSERT INTO area_type (id, name) VALUES (1, 'Country');
INSERT INTO area (id, gid, name, sort_name, type) VALUES
  ( 13, '106e0bec-b638-3b37-b731-f53d507dc00e', 'Australia', 'Australia', 1),
  ( 81, '85752fda-13c4-31a3-bee5-0e5cb1f51dad', 'Germany', 'Germany', 1),
  (107, '2db42837-c832-3c27-b4a3-08198f75693c', 'Japan', 'Japan', 1),
  (150, 'ef1b7cc0-cd26-36f4-8ea0-04d9623786c7', 'Netherlands', 'Netherlands', 1),
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 'United Kingdom', 1),
  (222, '489ce91b-6658-3307-9877-795b68554c98', 'United States', 'United States', 1),
  (241, '89a675c2-3e37-3518-b83c-418bad59a85a', 'Europe', 'Europe', 1);
INSERT INTO country_area (area) VALUES ( 13), ( 81), (107), (150), (221), (222), (241);
INSERT INTO iso_3166_1 (area, code) VALUES ( 13, 'AU'), ( 81, 'DE'), (107, 'JP'), (150, 'NL'), (221, 'GB'), (222, 'US'), (241, 'XE');


