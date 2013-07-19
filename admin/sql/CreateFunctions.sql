\set ON_ERROR_STOP 1
BEGIN;

-- We may want to create a CreateAggregate.sql script, but it seems silly to do that for one aggregate
CREATE AGGREGATE array_accum (basetype = anyelement, sfunc = array_append, stype = anyarray, initcond = '{}');

-- This function calculates an integer based on the first 6
-- characters of the input. First, it strips accents, converts to upper case
-- and removes everything except ASCII characters A-Z and space. That means
-- we can fit one character into 5 bits and the first 6 characters into a
-- 32-bit integer.
CREATE OR REPLACE FUNCTION page_index(txt varchar) RETURNS integer AS $$
DECLARE
    input varchar;
    res integer;
    i integer;
    x varchar;
BEGIN
    input := regexp_replace(upper(substr(musicbrainz.musicbrainz_unaccent(txt), 1, 6)), '[^A-Z ]', '_', 'g');
    res := 0;
    FOR i IN 1..6 LOOP
        x := substr(input, i, 1);
        IF x = '_' OR x = '' THEN
            res := (res << 5);
        ELSIF x = ' ' THEN
            res := (res << 5) | 1;
        ELSE
            res := (res << 5) | (ascii(x) - 63);
        END IF;
    END LOOP;
    RETURN res;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION page_index_max(txt varchar) RETURNS integer AS $$
DECLARE
    input varchar;
    res integer;
    i integer;
    x varchar;
BEGIN
    input := regexp_replace(upper(substr(musicbrainz_unaccent(txt), 1, 6)), '[^A-Z ]', '_', 'g');
    res := 0;
    FOR i IN 1..6 LOOP
        x := substr(input, i, 1);
        IF x = '' THEN
            res := (res << 5) | 31;
        ELSIF x = '_' THEN
            res := (res << 5);
        ELSIF x = ' ' THEN
            res := (res << 5) | 1;
        ELSE
            res := (res << 5) | (ascii(x) - 63);
        END IF;
    END LOOP;
    RETURN res;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;


-- Generates UUID version 4 (random-based)
CREATE OR REPLACE FUNCTION generate_uuid_v4() RETURNS uuid
    AS $$
DECLARE
    value VARCHAR(36);
BEGIN
    value =          lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || '-';
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || '-';
    value = value || lpad((to_hex((ceil(random() * 255)::int & 15) | 64)), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || '-';
    value = value || lpad((to_hex((ceil(random() * 255)::int & 63) | 128)), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || '-';
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    value = value || lpad(to_hex(ceil(random() * 255)::int), 2, '0');
    RETURN value::uuid;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION from_hex(t text) RETURNS integer
    AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN EXECUTE 'SELECT x'''||t||'''::integer AS hex' LOOP
        RETURN r.hex;
    END LOOP;
END
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- NameSpace_URL = '6ba7b8119dad11d180b400c04fd430c8'
CREATE OR REPLACE FUNCTION generate_uuid_v3(namespace varchar, name varchar) RETURNS uuid
    AS $$
DECLARE
    value varchar(36);
    bytes varchar;
BEGIN
    bytes = md5(decode(namespace, 'hex') || decode(name, 'escape'));
    value = substr(bytes, 1+0, 8);
    value = value || '-';
    value = value || substr(bytes, 1+2*4, 4);
    value = value || '-';
    value = value || lpad(to_hex((from_hex(substr(bytes, 1+2*6, 2)) & 15) | 48), 2, '0');
    value = value || substr(bytes, 1+2*7, 2);
    value = value || '-';
    value = value || lpad(to_hex((from_hex(substr(bytes, 1+2*8, 2)) & 63) | 128), 2, '0');
    value = value || substr(bytes, 1+2*9, 2);
    value = value || '-';
    value = value || substr(bytes, 1+2*10, 12);
    return value::uuid;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;


CREATE OR REPLACE FUNCTION inc_ref_count(tbl varchar, row_id integer, val integer) RETURNS void AS $$
BEGIN
    -- increment ref_count for the new name
    EXECUTE 'SELECT ref_count FROM ' || tbl || ' WHERE id = ' || row_id || ' FOR UPDATE';
    EXECUTE 'UPDATE ' || tbl || ' SET ref_count = ref_count + ' || val || ' WHERE id = ' || row_id;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION dec_ref_count(tbl varchar, row_id integer, val integer) RETURNS void AS $$
DECLARE
    ref_count integer;
BEGIN
    -- decrement ref_count for the old name,
    -- or delete it if ref_count would drop to 0
    EXECUTE 'SELECT ref_count FROM ' || tbl || ' WHERE id = ' || row_id || ' FOR UPDATE' INTO ref_count;
    IF ref_count <= val THEN
        EXECUTE 'DELETE FROM ' || tbl || ' WHERE id = ' || row_id;
    ELSE
        EXECUTE 'UPDATE ' || tbl || ' SET ref_count = ref_count - ' || val || ' WHERE id = ' || row_id;
    END IF;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- artist triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_artist() RETURNS trigger AS $$
BEGIN
    -- add a new entry to the artist_meta table
    INSERT INTO artist_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- editor triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_editor() RETURNS trigger AS $$
BEGIN
    -- add a new entry to the editor_watch_preference table
    INSERT INTO editor_watch_preferences (editor) VALUES (NEW.id);

    -- by default watch for new official albums
    INSERT INTO editor_watch_release_group_type (editor, release_group_type)
        VALUES (NEW.id, 2);
    INSERT INTO editor_watch_release_status (editor, release_status)
        VALUES (NEW.id, 1);

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- label triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_label() RETURNS trigger AS $$
BEGIN
    INSERT INTO label_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- recording triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_recording() RETURNS trigger AS $$
BEGIN
    PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    INSERT INTO recording_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_recording() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_recording() RETURNS trigger AS $$
BEGIN
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- release triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_release() RETURNS trigger AS $$
BEGIN
    -- increment ref_count of the name
    PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    -- increment release_count of the parent release group
    UPDATE release_group_meta SET release_count = release_count + 1 WHERE id = NEW.release_group;
    -- add new release_meta
    INSERT INTO release_meta (id) VALUES (NEW.id);
    INSERT INTO release_coverart (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.release_group != OLD.release_group THEN
        -- release group is changed, decrement release_count in the original RG, increment in the new one
        UPDATE release_group_meta SET release_count = release_count - 1 WHERE id = OLD.release_group;
        UPDATE release_group_meta SET release_count = release_count + 1 WHERE id = NEW.release_group;
        PERFORM set_release_group_first_release_date(OLD.release_group);
        PERFORM set_release_group_first_release_date(NEW.release_group);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release() RETURNS trigger AS $$
BEGIN
    -- decrement ref_count of the name
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    -- decrement release_count of the parent release group
    UPDATE release_group_meta SET release_count = release_count - 1 WHERE id = OLD.release_group;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- release_group triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_release_group() RETURNS trigger AS $$
BEGIN
    PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    INSERT INTO release_group_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_group() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_group() RETURNS trigger AS $$
BEGIN
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- track triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_track() RETURNS trigger AS $$
BEGIN
    PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    -- increment track_count in the parent medium
    UPDATE medium SET track_count = track_count + 1 WHERE id = NEW.medium;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_track() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.medium != OLD.medium THEN
        -- medium is changed, decrement track_count in the original medium, increment in the new one
        UPDATE medium SET track_count = track_count - 1 WHERE id = OLD.medium;
        UPDATE medium SET track_count = track_count + 1 WHERE id = NEW.medium;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_track() RETURNS trigger AS $$
BEGIN
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    -- decrement track_count in the parent medium
    UPDATE medium SET track_count = track_count - 1 WHERE id = OLD.medium;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- work triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_work() RETURNS trigger AS $$
BEGIN
    INSERT INTO work_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- Ensure attribute type allows free text if free text is added
CREATE OR REPLACE FUNCTION ensure_work_attribute_type_allows_text()
RETURNS trigger AS $$
  BEGIN
    IF NEW.work_attribute_text IS NOT NULL
        AND NOT EXISTS (
           SELECT TRUE FROM work_attribute_type
		WHERE work_attribute_type.id = NEW.work_attribute_type
		AND free_text
	)
    THEN
        RAISE EXCEPTION 'This attribute type can not contain free text';
    ELSE RETURN NEW;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- lastupdate triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION b_upd_last_updated_table() RETURNS trigger AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_edit() RETURNS trigger AS $$
BEGIN
    IF NEW.status != OLD.status THEN
       UPDATE edit_artist SET status = NEW.status WHERE edit = NEW.id;
       UPDATE edit_label  SET status = NEW.status WHERE edit = NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION b_ins_edit_materialize_status() RETURNS trigger AS $$
BEGIN
    NEW.status = (SELECT status FROM edit WHERE id = NEW.edit);
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

------------------------
-- Collection deletion and hiding triggers
------------------------

CREATE OR REPLACE FUNCTION replace_old_sub_on_add()
RETURNS trigger AS $$
  BEGIN
    UPDATE editor_subscribe_collection
     SET available = TRUE, last_seen_name = NULL,
      last_edit_sent = NEW.last_edit_sent
     WHERE editor = NEW.editor AND collection = NEW.collection;

    IF FOUND THEN
      RETURN NULL;
    ELSE
      RETURN NEW;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION del_collection_sub_on_delete()
RETURNS trigger AS $$
  BEGIN
    UPDATE editor_subscribe_collection sub
     SET available = FALSE, last_seen_name = OLD.name
     FROM editor_collection coll
     WHERE sub.collection = OLD.id AND sub.collection = coll.id;

    RETURN OLD;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION del_collection_sub_on_private()
RETURNS trigger AS $$
  BEGIN
    IF NEW.public = FALSE AND OLD.public = TRUE THEN
      UPDATE editor_subscribe_collection sub
       SET available = FALSE, last_seen_name = OLD.name
       FROM editor_collection coll
       WHERE sub.collection = OLD.id AND sub.collection = coll.id
       AND sub.editor != coll.editor;
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE 'plpgsql';

------------------------
-- CD Lookup
------------------------

CREATE OR REPLACE FUNCTION create_cube_from_durations(durations INTEGER[]) RETURNS cube AS $$
DECLARE
    point    cube;
    str      VARCHAR;
    i        INTEGER;
    count    INTEGER;
    dest     INTEGER;
    dim      CONSTANT INTEGER = 6;
    selected INTEGER[];
BEGIN

    count = array_upper(durations, 1);
    FOR i IN 0..dim LOOP
        selected[i] = 0;
    END LOOP;

    IF count < dim THEN
        FOR i IN 1..count LOOP
            selected[i] = durations[i];
        END LOOP;
    ELSE
        FOR i IN 1..count LOOP
            dest = (dim * (i-1) / count) + 1;
            selected[dest] = selected[dest] + durations[i];
        END LOOP;
    END IF;

    str = '(';
    FOR i IN 1..dim LOOP
        IF i > 1 THEN
            str = str || ',';
        END IF;
        str = str || cast(selected[i] as text);
    END LOOP;
    str = str || ')';

    RETURN str::cube;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION create_bounding_cube(durations INTEGER[], fuzzy INTEGER) RETURNS cube AS $$
DECLARE
    point    cube;
    str      VARCHAR;
    i        INTEGER;
    dest     INTEGER;
    count    INTEGER;
    dim      CONSTANT INTEGER = 6;
    selected INTEGER[];
    scalers  INTEGER[];
BEGIN

    count = array_upper(durations, 1);
    IF count < dim THEN
        FOR i IN 1..dim LOOP
            selected[i] = 0;
            scalers[i] = 0;
        END LOOP;
        FOR i IN 1..count LOOP
            selected[i] = durations[i];
            scalers[i] = 1;
        END LOOP;
    ELSE
        FOR i IN 1..dim LOOP
            selected[i] = 0;
            scalers[i] = 0;
        END LOOP;
        FOR i IN 1..count LOOP
            dest = (dim * (i-1) / count) + 1;
            selected[dest] = selected[dest] + durations[i];
            scalers[dest] = scalers[dest] + 1;
        END LOOP;
    END IF;

    str = '(';
    FOR i IN 1..dim LOOP
        IF i > 1 THEN
            str = str || ',';
        END IF;
        str = str || cast((selected[i] - (fuzzy * scalers[i])) as text);
    END LOOP;
    str = str || '),(';
    FOR i IN 1..dim LOOP
        IF i > 1 THEN
            str = str || ',';
        END IF;
        str = str || cast((selected[i] + (fuzzy * scalers[i])) as text);
    END LOOP;
    str = str || ')';

    RETURN str::cube;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;


-------------------------------------------------------------------
-- Maintain release_group_meta.first_release_date
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_release_group_first_release_date(release_group_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE release_group_meta SET first_release_date_year = first.date_year,
                                  first_release_date_month = first.date_month,
                                  first_release_date_day = first.date_day
      FROM (
        SELECT date_year, date_month, date_day
        FROM (
          SELECT date_year, date_month, date_day
          FROM release
          JOIN release_country ON (release_country.release = release.id)
          WHERE release.release_group = release_group_id
          UNION
          SELECT date_year, date_month, date_day
          FROM release
          JOIN release_unknown_country ON (release_unknown_country.release = release.id)
          WHERE release.release_group = release_group_id
        ) b
        ORDER BY date_year NULLS LAST, date_month NULLS LAST, date_day NULLS LAST
        LIMIT 1
      ) AS first
    WHERE id = release_group_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = NEW.release;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id IN (NEW.release, OLD.release);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = OLD.release;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------
-- Find artists that are empty, and have not been updated within the
-- last 1 days
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION empty_artists() RETURNS SETOF artist AS
$BODY$
DECLARE
    artist_row artist%rowtype;
BEGIN
    FOR artist_row IN
        SELECT * FROM artist
        WHERE edits_pending = 0
          AND (last_updated < NOW() - '1 day'::INTERVAL OR
               last_updated IS NULL)
          AND NOT EXISTS (
            SELECT TRUE FROM edit_artist
            WHERE edit_artist.artist = artist.id
            AND edit_artist.status = 1
            LIMIT 1
          )
    LOOP
        CONTINUE WHEN
        (
            SELECT TRUE FROM artist_credit_name
             WHERE artist = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_recording
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_work
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_url
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_artist
             WHERE entity0 = artist_row.id OR entity1 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_label
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_release
             WHERE entity0 = artist_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_release_group WHERE entity0 = artist_row.id
             LIMIT 1
        );
        RETURN NEXT artist_row;
    END LOOP;
END
$BODY$
LANGUAGE 'plpgsql' ;

-------------------------------------------------------------------
-- Find labels that are empty, and have not been updated within the
-- last 1 day
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION empty_labels() RETURNS SETOF label AS
$BODY$
DECLARE
    label_row label%rowtype;
BEGIN
    FOR label_row IN
        SELECT * FROM label
        WHERE edits_pending = 0
          AND (last_updated < NOW() - '1 day'::INTERVAL OR
               last_updated IS NULL)
          AND NOT EXISTS (
            SELECT TRUE FROM edit_label
            WHERE edit_label.label = label.id
            AND edit_label.status = 1
            LIMIT 1
          )
    LOOP
        CONTINUE WHEN
        (
            SELECT TRUE FROM release_label
             WHERE label = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_label
             WHERE entity1 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_label
             WHERE entity0 = label_row.id OR entity1 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_recording
             WHERE entity0 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_release
             WHERE entity0 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_release_group
             WHERE entity0 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_url
             WHERE entity0 = label_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_work
             WHERE entity0 = label_row.id
             LIMIT 1
        );
        RETURN NEXT label_row;
    END LOOP;
END
$BODY$
LANGUAGE 'plpgsql' ;

-------------------------------------------------------------------
-- Find release groups that are empty, and have not been updated
-- within the last 1 day
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION empty_release_groups() RETURNS SETOF release_group AS
$BODY$
DECLARE
    rg_row release_group%rowtype;
BEGIN
    FOR rg_row IN
        SELECT * FROM release_group
        WHERE edits_pending = 0
          AND (last_updated < NOW() - '1 day'::INTERVAL OR
               last_updated IS NULL)
          AND NOT EXISTS (
            SELECT TRUE FROM edit_release_group
            JOIN edit ON edit_release_group.edit = edit.id
            WHERE edit_release_group.release_group = release_group.id
            AND edit.status = 1
            LIMIT 1
          )
    LOOP
        CONTINUE WHEN
        (
            SELECT TRUE FROM release
             WHERE release_group = rg_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_artist_release_group
             WHERE entity1 = rg_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_release_group
             WHERE entity1 = rg_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_recording_release_group
             WHERE entity1 = rg_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_release_group
             WHERE entity1 = rg_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_group_release_group
             WHERE entity0 = rg_row.id OR entity1 = rg_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_group_url
             WHERE entity0 = rg_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_group_work
             WHERE entity0 = rg_row.id
             LIMIT 1
        );
        RETURN NEXT rg_row;
    END LOOP;
END
$BODY$
LANGUAGE 'plpgsql' ;


-------------------------------------------------------------------
-- Find works that are empty, and have not been updated within the
-- last 1 day
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION empty_works() RETURNS SETOF work AS
$BODY$
DECLARE
    work_row work%rowtype;
BEGIN
    FOR work_row IN
        SELECT * FROM work
        WHERE edits_pending = 0
          AND (last_updated < NOW() - '1 day'::INTERVAL OR
               last_updated IS NULL)
          AND NOT EXISTS (
            SELECT TRUE FROM edit_work
            JOIN edit ON edit.id = edit_work.edit
            WHERE edit_work.work = work.id
            AND edit.status = 1
            LIMIT 1
          )
    LOOP
        CONTINUE WHEN
        (
            SELECT TRUE FROM l_artist_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_label_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_recording_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_release_group_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_url_work
             WHERE entity1 = work_row.id
             LIMIT 1
        ) OR
        (
            SELECT TRUE FROM l_work_work
             WHERE entity0 = work_row.id OR entity1 = work_row.id
             LIMIT 1
        );
        RETURN NEXT work_row;
    END LOOP;
END
$BODY$
LANGUAGE 'plpgsql' ;

CREATE OR REPLACE FUNCTION deny_special_purpose_artist_deletion() RETURNS trigger AS $$
BEGIN
    IF OLD.id IN (1, 2) THEN
        RAISE EXCEPTION 'Attempted to delete a special purpose row';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION deny_special_purpose_label_deletion() RETURNS trigger AS $$
BEGIN
    IF OLD.id = 1 THEN
        RAISE EXCEPTION 'Attempted to delete a special purpose row';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION delete_ratings(enttype TEXT, ids INTEGER[])
RETURNS TABLE(editor INT, rating SMALLINT) AS $$
DECLARE
    tablename TEXT;
BEGIN
    tablename = enttype || '_rating_raw';
    RETURN QUERY
       EXECUTE 'DELETE FROM ' || tablename || ' WHERE ' || enttype || ' = any($1)
                RETURNING editor, rating'
         USING ids;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------
-- Delete tags and return them for use in sub queries
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION delete_tags(enttype TEXT, ids INTEGER[])
RETURNS TABLE(editor INT, tag INT) AS $$
DECLARE
    tablename TEXT;
BEGIN
    tablename = enttype || '_tag_raw';
    RETURN QUERY
       EXECUTE 'DELETE FROM ' || tablename || ' WHERE ' || enttype || ' = any($1)
                RETURNING editor, tag'
         USING ids;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------
-- Prevent link attributes being used on links that don't support them
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION prevent_invalid_attributes()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT TRUE
        FROM (VALUES (NEW.link, NEW.attribute_type)) la (link, attribute_type)
        JOIN link l ON l.id = la.link
        JOIN link_type lt ON l.link_type = lt.id
        JOIN link_attribute_type lat ON lat.id = la.attribute_type
        JOIN link_type_attribute_type ltat ON ltat.attribute_type = lat.root AND ltat.link_type = lt.id
    ) THEN
        RAISE EXCEPTION 'Attribute type % is invalid for link %', NEW.attribute_type, NEW.link;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--------------------------------------------------------------------------------
-- Remove unused link rows when a relationship is changed
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION remove_unused_links()
RETURNS TRIGGER AS $$
DECLARE
    other_ars_exist BOOLEAN;
BEGIN
    EXECUTE 'SELECT EXISTS (SELECT TRUE FROM ' || quote_ident(TG_TABLE_NAME) ||
            ' WHERE link = $1)'
    INTO other_ars_exist
    USING OLD.link;

    IF NOT other_ars_exist THEN
       DELETE FROM link_attribute WHERE link = OLD.link;
       DELETE FROM link WHERE id = OLD.link;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION delete_unused_url(ids INTEGER[])
RETURNS VOID AS $$
DECLARE
  clear_up INTEGER[];
BEGIN
  SELECT ARRAY(
    SELECT id FROM url url_row WHERE id = any(ids)
    AND NOT (
      EXISTS (
        SELECT TRUE FROM l_artist_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_label_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_recording_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_release_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_release_group_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_url_url
        WHERE entity0 = url_row.id OR entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_url_work
        WHERE entity0 = url_row.id
        LIMIT 1
      )
    )
  ) INTO clear_up;

  DELETE FROM url_gid_redirect WHERE new_id = any(clear_up);
  DELETE FROM url WHERE id = any(clear_up);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION remove_unused_url()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME LIKE 'l_url_%' THEN
      EXECUTE delete_unused_url(ARRAY[OLD.entity0]);
    END IF;

    IF TG_TABLE_NAME LIKE 'l_%_url' THEN
      EXECUTE delete_unused_url(ARRAY[OLD.entity1]);
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary_area_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE area_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND area = NEW.area;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary_artist_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE artist_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND artist = NEW.artist;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary_label_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE label_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND label = NEW.label;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary_work_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE work_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND work = NEW.work;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION simplify_search_hints()
RETURNS trigger AS $$
BEGIN
    IF NEW.type::int = TG_ARGV[0]::int THEN
        NEW.sort_name := NEW.name;
        NEW.begin_date_year := NULL;
        NEW.begin_date_month := NULL;
        NEW.begin_date_day := NULL;
        NEW.end_date_year := NULL;
        NEW.end_date_month := NULL;
        NEW.end_date_day := NULL;
        NEW.end_date_day := NULL;
        NEW.locale := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION end_date_implies_ended()
RETURNS trigger AS $$
BEGIN
    IF NEW.end_date_year IS NOT NULL OR
       NEW.end_date_month IS NOT NULL OR
       NEW.end_date_day IS NOT NULL
    THEN
        NEW.ended = TRUE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION delete_orphaned_recordings()
RETURNS TRIGGER
AS $$
  BEGIN
    PERFORM TRUE
    FROM recording outer_r
    WHERE id = OLD.recording
      AND edits_pending = 0
      AND NOT EXISTS (
        SELECT TRUE
        FROM edit JOIN edit_recording er ON edit.id = er.edit
        WHERE er.recording = outer_r.id
          AND type IN (71, 207, 218)
          LIMIT 1
      ) AND NOT EXISTS (
        SELECT TRUE FROM track WHERE track.recording = outer_r.id LIMIT 1
      ) AND NOT EXISTS (
        SELECT TRUE FROM l_artist_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_label_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_recording WHERE entity1 = outer_r.id OR entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_release WHERE entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_release_group WHERE entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_work WHERE entity0 = outer_r.id
          UNION ALL
         SELECT TRUE FROM l_recording_url WHERE entity0 = outer_r.id
      );

    IF FOUND THEN
      -- Remove references from tables that don't change whether or not this recording
      -- is orphaned.
      DELETE FROM isrc WHERE recording = OLD.recording;
      DELETE FROM recording_annotation WHERE recording = OLD.recording;
      DELETE FROM recording_gid_redirect WHERE new_id = OLD.recording;
      DELETE FROM recording_puid WHERE recording = OLD.recording;
      DELETE FROM recording_rating_raw WHERE recording = OLD.recording;
      DELETE FROM recording_tag WHERE recording = OLD.recording;
      DELETE FROM recording_tag_raw WHERE recording = OLD.recording;

      DELETE FROM recording WHERE id = OLD.recording;
    END IF;

    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION padded_by_whitespace(TEXT) RETURNS boolean AS $$
  SELECT btrim($1) <> $1;
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION whitespace_collapsed(TEXT) RETURNS boolean AS $$
  SELECT $1 !~ E'\\s{2,}';
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION controlled_for_whitespace(TEXT) RETURNS boolean AS $$
  SELECT NOT padded_by_whitespace($1) AND whitespace_collapsed($1);
$$ LANGUAGE SQL IMMUTABLE SET search_path = musicbrainz, public;

CREATE OR REPLACE FUNCTION delete_unused_tag(tag_id INT)
RETURNS void AS $$
  BEGIN
    DELETE FROM tag WHERE id = tag_id;
  EXCEPTION
    WHEN foreign_key_violation THEN RETURN;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION trg_delete_unused_tag()
RETURNS trigger AS $$
  BEGIN
    PERFORM delete_unused_tag(NEW.id);
    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION trg_delete_unused_tag_ref()
RETURNS trigger AS $$
  BEGIN
    PERFORM delete_unused_tag(OLD.tag);
    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

COMMIT;
-- vi: set ts=4 sw=4 et :
