INSERT INTO series (id, gid, name, comment, type, ordering_type, edits_pending, last_updated)
    VALUES (25, 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582', 'Bach-Werke-Verzeichnis', '', 5, 1, 0, '2014-05-14 18:28:59.030601+00');

INSERT INTO work (id, gid, name, type, comment, edits_pending, last_updated)
    VALUES (10465539, '9deecf21-8d3f-3bbd-8f36-6331c9fd6d35', '9 kleine Präludien: Präludium D-Dur, BWV 925', NULL, '', 0, '2014-01-08 21:17:20.377241+00'),
           (12894254, '02bfb89e-8877-47c0-a19d-b574bae78198', 'Concerto and Fugue in C minor, BWV 909', NULL, '', 0, '2015-11-20 10:27:40.150479+00');

INSERT INTO work_language (work, language)
    VALUES (10465539, 486),
           (12894254, 486);

INSERT INTO link (id, link_type, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, attribute_count, created, ended)
    VALUES (170801, 743, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2014-05-21 06:35:59.318332+00', 'f');

INSERT INTO link_attribute_text_value (link, attribute_type, text_value)
    VALUES (170801, 788, 'BWV 925');

INSERT INTO l_series_work (id, link, entity0, entity1, edits_pending, last_updated, link_order, entity0_credit, entity1_credit)
    VALUES (15120, 170801, 25, 10465539, 0, '2015-11-11 16:23:07.850893+00', 0, '', ''),
           (2025, 170801, 25, 10465539, 1, '2014-05-21 06:35:59.318332+00', 749, '', '');
