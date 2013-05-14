BEGIN;

WITH dash1 AS (SELECT area, string_agg('"' || code || '"', ',') AS codes FROM iso_3166_1 GROUP BY area),
     dash2 AS (SELECT area, string_agg('"' || code || '"', ',') AS codes FROM iso_3166_2 GROUP BY area),
     dash3 AS (SELECT area, string_agg('"' || code || '"', ',') AS codes FROM iso_3166_3 GROUP BY area)
SELECT
     id AS area, 4::integer AS editor, 81::smallint AS type, 2::smallint AS status, 1::smallint AS autoedit, now() AS open_time, now() AS close_time, now() AS expire_time,
         '{' ||
           '"entity_id":' || id || ',' ||
           '"name":"' || name || '",' ||
           '"sort_name":"' || sort_name || '",' ||
           '"type_id":' || COALESCE(type::text, 'null'::text) || ',' ||
           '"begin_date":{"month":' || COALESCE(begin_date_month::text, 'null'::text) || ',"day":' || COALESCE(begin_date_day::text, 'null'::text) || ',"year":' || COALESCE(begin_date_year::text, 'null'::text) || '},' ||
           '"end_date":{"month":' || COALESCE(end_date_month::text, 'null'::text) || ',"day":' || COALESCE(end_date_day::text, 'null'::text) || ',"year":' || COALESCE(end_date_year::text, 'null'::text) || '},' ||
           '"ended":"' || ended::int || '",' ||
           '"iso_3166_1":[' || coalesce(dash1.codes::text, ''::text) || '],' ||
           '"iso_3166_2":[' || coalesce(dash2.codes::text, ''::text) || '],' ||
           '"iso_3166_3":[' || coalesce(dash3.codes::text, ''::text) || ']' ||
         '}' AS data
      INTO TEMPORARY tmp_area_edits
      FROM area
           LEFT JOIN dash1 ON dash1.area = area.id
           LEFT JOIN dash2 ON dash2.area = area.id
           LEFT JOIN dash3 ON dash3.area = area.id
     WHERE NOT EXISTS (SELECT TRUE FROM edit_area WHERE area = area.id)
     GROUP BY area.id, area.name, area.sort_name, area.type, area.begin_date_year, area.begin_date_month, area.begin_date_day, area.end_date_year, area.end_date_month, area.end_date_day, area.ended, dash1.codes, dash2.codes, dash3.codes;

INSERT INTO edit (editor, type, status, autoedit, open_time, close_time, expire_time, data)
           SELECT editor, type, status, autoedit, open_time, close_time, expire_time, data FROM tmp_area_edits;
INSERT INTO edit_area (area, edit)
   SELECT tmp.area, edit.id AS edit FROM tmp_area_edits tmp JOIN edit ON tmp.data = edit.data WHERE edit.type = 81 and edit.editor = 4;
INSERT INTO edit_note (editor, edit, text)
   SELECT 4::integer AS editor, edit.id, 'This area was created as part of the 2013-05-15 schema change migration, when the area entity came into existence.'::text
     FROM edit WHERE edit.type = 81 AND edit.editor = 4 AND edit.open_time = now();

COMMIT;
