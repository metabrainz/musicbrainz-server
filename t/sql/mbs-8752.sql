SET client_min_messages TO 'warning';

INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
    (NULL, NULL, 27, 9, 1947, '', 0, NULL, NULL, NULL, NULL, '0', 1, 'b134d1bf-c7c7-4427-93ac-9fdbc2b59ef1', 9113, '2015-06-21 09:12:12.187989+00', 'Meat Loaf', 'Meat Loaf', 1);

INSERT INTO artist_credit (artist_count, created, id, name, ref_count) VALUES
    (1, '2011-05-16 16:32:11.963929+00', 9113, 'Meat Loaf', 4332);

INSERT INTO artist_credit_name (artist, artist_credit, join_phrase, name, position) VALUES
    (9113, 9113, '', 'Meat Loaf', 0);

INSERT INTO release_group (artist_credit, comment, edits_pending, gid, id, last_updated, name, type) VALUES
    (9113, '', 0, '758d7dc5-4aa2-3731-b970-549251a98232', 17814, '2010-03-19 18:03:48.279801+00', 'Bat Out of Hell II: Back Into Hell', 1);

INSERT INTO release (artist_credit, barcode, comment, edits_pending, gid, id, language, last_updated, name, packaging, quality, release_group, script, status) VALUES
    (9113, '094637912355', '', 2, '3a1a6bd7-dbe1-4004-813b-11debf0b61e8', 1718385, 120, '2016-01-22 10:53:51.139298+00', 'Bat Out of Hell II: Back Into Hell', NULL, -1, 17814, NULL, 1);

INSERT INTO medium (edits_pending, format, id, last_updated, name, position, release, track_count) VALUES
    (0, NULL, 1819308, '2016-01-22 10:13:55.59614+00', '', 3, 1718385, 5);

INSERT INTO recording (artist_credit, comment, edits_pending, gid, id, last_updated, length, name, video) VALUES
    (9113, '', 0, '7cb020c5-c7c4-495e-bbdb-774c0ac438b3', 14428606, '2013-01-10 18:11:06.367649+00', 562000, 'Back Into Hell: Meat Loaf and Jim Steinman Interview', '0'),
    (9113, '', 0, '23aec39a-896c-4a16-a1f5-d3ef9811cd5f', 14428607, '2016-01-22 10:13:55.59614+00', 460000, 'I’ll Do Anything for Love (But I Won’t Do That)', '0'),
    (9113, '', 0, 'c3a91791-1c5a-477e-8440-d74ac1ce5bf2', 14428608, '2013-01-10 18:11:06.367649+00', 347000, 'Rock and Roll Dreams Come Through', '0'),
    (9113, '', 0, '6e505245-98c3-47d6-8ee2-269cffeb97dc', 14428609, '2015-01-18 12:04:18.111683+00', 463000, 'Objects in the Rear View Mirror May Appear Closer Than They Are', '0'),
    (9113, '', 0, '69c38d37-901b-45d6-b469-0708d6d4a289', 9724192, NULL, 481000, 'Life Is a Lemon and I Want My Money Back (live)', '0'),
    (9113, '', 0, 'bff3edaf-c019-4cb5-8ede-78872ff472a9', 9724194, '2016-01-22 10:30:11.549976+00', 522000, 'Out of the Frying Pan (And Into the Fire) (live)', '0'),
    (9113, '', 0, '6a4ad015-a7b0-4687-be4c-1183858868c9', 9724195, '2016-01-22 10:27:51.598498+00', 583000, 'Everything Louder Than Everything Else (live)', '0'),
    (9113, '', 0, 'f531199f-db87-451b-ad3c-bea08435e9b3', 9724196, NULL, 356000, 'Objects in the Rear View Mirror May Appear Closer Than They Are (edit)', '0'),
    (9113, '', 0, '25a9c7a1-f9a0-4929-87ba-eef3d3661cee', 9724193, NULL, 507000, 'Rock and Roll Dreams Come Through (live)', '0');

INSERT INTO track (artist_credit, edits_pending, gid, id, is_data_track, last_updated, length, medium, name, number, position, recording) VALUES
    (9113, 0, '420e76c4-5d0e-493d-9af1-b113d45eec1f', 20036047, '0', '2016-01-22 10:30:11.549976+00', 562000, 1819308, 'Back Into Hell: Meat Loaf and Jim Steinman Interview', '1', 1, 14428606),
    (9113, 0, 'fb9b72a5-b8a1-4e66-9b8c-b7b2b712a364', 20036048, '0', '2016-01-22 10:30:11.549976+00', 460000, 1819308, 'I’ll Do Anything for Love (But I Won’t Do That)', '2', 2, 14428607),
    (9113, 0, 'b2237b04-eb5f-411e-901c-024cc430cf0a', 20036049, '0', '2016-01-22 10:30:11.549976+00', 347000, 1819308, 'Rock and Roll Dreams Come Through', '3', 4, 14428608),
    (9113, 0, '683d5ae0-fd1a-405b-be66-541d60d8d6d4', 20036050, '0', '2016-01-22 10:30:11.549976+00', 463000, 1819308, 'Objects in the Rear View Mirror May Appear Closer Than They Are', '4', 5, 14428609);
