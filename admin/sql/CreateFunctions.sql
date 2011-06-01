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
    input := regexp_replace(upper(substr(unaccent(txt), 1, 6)), '[^A-Z ]', '_', 'g');
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
    input := regexp_replace(upper(substr(unaccent(txt), 1, 6)), '[^A-Z ]', '_', 'g');
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
    PERFORM set_release_group_first_release_date(NEW.release_group);
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
    END IF;
    PERFORM set_release_group_first_release_date(NEW.release_group);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release() RETURNS trigger AS $$
BEGIN
    -- decrement ref_count of the name
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    -- decrement release_count of the parent release group
    UPDATE release_group_meta SET release_count = release_count - 1 WHERE id = OLD.release_group;
    PERFORM set_release_group_first_release_date(OLD.release_group);
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
    -- increment track_count in the parent tracklist
    UPDATE tracklist SET track_count = track_count + 1 WHERE id = NEW.tracklist;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_track() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.tracklist != OLD.tracklist THEN
        -- tracklist is changed, decrement track_count in the original tracklist, increment in the new one
        UPDATE tracklist SET track_count = track_count - 1 WHERE id = OLD.tracklist;
        UPDATE tracklist SET track_count = track_count + 1 WHERE id = NEW.tracklist;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_track() RETURNS trigger AS $$
BEGIN
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    -- decrement track_count in the parent tracklist
    UPDATE tracklist SET track_count = track_count - 1 WHERE id = OLD.tracklist;
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

-----------------------------------------------------------------------
-- lastupdate triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION b_upd_last_updated_table() RETURNS trigger AS $$
BEGIN
    NEW.last_updated = NOW();
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
        SELECT date_year, date_month, date_day FROM release
         WHERE release_group = release_group_id
      ORDER BY date_year NULLS LAST, date_month NULLS LAST, date_day NULLS LAST
         LIMIT 1
           ) AS first WHERE id = release_group_id;
END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------
-- Find artists that are empty, and have been updated within the
-- last $interval
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION empty_artists() RETURNS SETOF artist AS
$BODY$
DECLARE
    artist_row artist%rowtype;
BEGIN
    FOR artist_row IN
        SELECT * FROM artist
        WHERE edits_pending = 0
          AND last_updated < NOW() - '1 day'::INTERVAL
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

COMMIT;
-- vi: set ts=4 sw=4 et :
