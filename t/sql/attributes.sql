SET client_min_messages TO 'warning';

INSERT INTO editor (
  id, name, password, ha1,
  email, email_confirm_date)
VALUES (
  1, 'editor', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca',
  'foo@example.com', now());

INSERT INTO editor (
  id, name, password, ha1,
  email, email_confirm_date, privs)
VALUES (
  2, 'admin', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca',
  'foo@example.com', now(), 128);

-- Release for language and script usage
INSERT INTO artist (
  begin_date_day, begin_date_month, begin_date_year, comment, area,
  edits_pending, end_date_day, end_date_month, end_date_year, ended,
  gender, gid, id, last_updated, name, sort_name,
  type, begin_area, end_area
)
VALUES (
  NULL, NULL, NULL, '', NULL,
  0, NULL, NULL, NULL, '0',
  NULL, '3088b672-fba9-4b4b-8ae0-dce13babfbb4', 11545, NULL, 'Plone', 'Plone',
  2, NULL, NULL
);

INSERT INTO artist_credit (
  id, artist_count, created, name,
  ref_count, gid
)
VALUES (
  11545, 1, '2011-01-18 16:24:02.551922+00', 'Plone',
  115, '68734848-cbfb-3d65-9e0c-d4e2870650bf'
);

INSERT INTO artist_credit_name (
  artist, artist_credit, join_phrase, name, position
)
VALUES (
  11545, 11545, '', 'Plone', 0
);

INSERT INTO release_group (
  artist_credit, comment, edits_pending, gid, id,
  last_updated, name, type
)
VALUES (
  11545, '', 0, '202cad78-a2e1-3fa7-b8bc-77c1f737e3da', 155364,
  '2009-05-24 20:47:00.490177+00', 'For Beginner Piano', 1
);

INSERT INTO release (
  status, release_group, edits_pending, packaging, id, quality, last_updated,
  script, language, name, artist_credit, barcode, comment,
  gid
)
VALUES (
  1, 155364, 0, NULL, 654729, -1, '2010-02-22 02:01:29.413661+00',
  28, 120, 'For Beginner Piano', 11545, '', '',
  'dd66bfdd-6097-32e3-91b6-67f47ba25d4c'
);

-- Work for language usage
INSERT INTO work (
  id, gid, name, type, edits_pending, comment
)
VALUES (
  1, '559be0c1-2c87-45d6-ba43-1b1feb8f831e', 'Danza la Xarra', 1, 0, ''
);

INSERT INTO work_language (work, language)
VALUES (1, 27);

-- Editor language usage
INSERT INTO editor_language (editor, language, fluency)
VALUES (1, 123, 'native');

-- Series for series type usage
INSERT INTO series (
  id, gid, name, comment,
  type, ordering_type, last_updated
)
VALUES (
  1, 'a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', 'Test Release Series', '',
  2, 1, '2002-02-20'
);
