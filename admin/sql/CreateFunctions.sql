\set ON_ERROR_STOP 1
BEGIN;

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


CREATE OR REPLACE FUNCTION inc_refcount(tbl varchar, row_id integer, val integer) RETURNS void AS $$
BEGIN
    -- increment refcount for the new name
    EXECUTE 'SELECT refcount FROM ' || tbl || ' WHERE id = ' || row_id || ' FOR UPDATE';
    EXECUTE 'UPDATE ' || tbl || ' SET refcount = refcount + ' || val || ' WHERE id = ' || row_id;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION dec_refcount(tbl varchar, row_id integer, val integer) RETURNS void AS $$
DECLARE
    ref_count integer;
BEGIN
    -- decrement refcount for the old name,
    -- or delete it if refcount would drop to 0
    EXECUTE 'SELECT refcount FROM ' || tbl || ' WHERE id = ' || row_id || ' FOR UPDATE' INTO ref_count;
    IF ref_count <= val THEN
        EXECUTE 'DELETE FROM ' || tbl || ' WHERE id = ' || row_id;
    ELSE
        EXECUTE 'UPDATE ' || tbl || ' SET refcount = refcount - ' || val || ' WHERE id = ' || row_id;
    END IF;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- artist triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_artist() RETURNS trigger AS $$
BEGIN
    IF NEW.name = NEW.sortname THEN
        -- name is the same as sortname, increment refcount of it by 2
        PERFORM inc_refcount('artist_name', NEW.name, 2);
    ELSE
        -- name and sortname are different, increment refcount of each by 1
        PERFORM inc_refcount('artist_name', NEW.name, 1);
        PERFORM inc_refcount('artist_name', NEW.sortname, 1);
    END IF;
    -- add a new entry to the artist_meta table
    INSERT INTO artist_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_artist() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        IF NEW.sortname != OLD.sortname THEN
            -- both names and sortnames are changed
            IF OLD.name = OLD.sortname THEN
                -- name and sortname were the same in the old version
                PERFORM dec_refcount('artist_name', OLD.name, 2);
            ELSE
                -- name and sortname were different in the old version
                PERFORM dec_refcount('artist_name', OLD.name, 1);
                PERFORM dec_refcount('artist_name', OLD.sortname, 1);
            END IF;
            IF NEW.name = NEW.sortname THEN
                -- name and sortname are the same in the new version
                PERFORM inc_refcount('artist_name', NEW.name, 2);
            ELSE
                -- name and sortname are different in the new version
                PERFORM inc_refcount('artist_name', NEW.name, 1);
                PERFORM inc_refcount('artist_name', NEW.sortname, 1);
            END IF;
        ELSE
            -- only names are changed
            PERFORM dec_refcount('artist_name', OLD.name, 1);
            PERFORM inc_refcount('artist_name', NEW.name, 1);
        END IF;
    ELSE
        IF NEW.sortname != OLD.sortname THEN
            -- only sortnames are changed
            PERFORM dec_refcount('artist_name', OLD.sortname, 1);
            PERFORM inc_refcount('artist_name', NEW.sortname, 1);
        END IF;
    END IF;
    IF NEW.editpending = OLD.editpending THEN
        -- editpending is unchanged and we are in UPDATE query, that means some data have changed
        UPDATE artist_meta SET lastupdate=NOW() WHERE id=NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_artist() RETURNS trigger AS $$
BEGIN
    IF OLD.name = OLD.sortname THEN
        -- name is the same as sortname, increment refcount of it by 2
        PERFORM dec_refcount('artist_name', OLD.name, 2);
    ELSE
        -- name and sortname are different, increment refcount of each by 1
        PERFORM dec_refcount('artist_name', OLD.name, 1);
        PERFORM dec_refcount('artist_name', OLD.sortname, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- artist_alias triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_artist_alias() RETURNS trigger AS $$
BEGIN
    PERFORM inc_refcount('artist_name', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_artist_alias() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_refcount('artist_name', OLD.name, 1);
        PERFORM inc_refcount('artist_name', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_artist_alias() RETURNS trigger AS $$
BEGIN
    PERFORM dec_refcount('artist_name', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- artist_credit_name triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_artist_credit_name() RETURNS trigger AS $$
BEGIN
    PERFORM inc_refcount('artist_name', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_artist_credit_name() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_refcount('artist_name', OLD.name, 1);
        PERFORM inc_refcount('artist_name', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_artist_credit_name() RETURNS trigger AS $$
BEGIN
    PERFORM dec_refcount('artist_name', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- label triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_label() RETURNS trigger AS $$
BEGIN
    IF NEW.name = NEW.sortname THEN
        PERFORM inc_refcount('label_name', NEW.name, 2);
    ELSE
        PERFORM inc_refcount('label_name', NEW.name, 1);
        PERFORM inc_refcount('label_name', NEW.sortname, 1);
    END IF;
    INSERT INTO label_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_label() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        IF NEW.sortname != OLD.sortname THEN
            -- both names and sortnames are different
            IF OLD.name = OLD.sortname THEN
                PERFORM dec_refcount('label_name', OLD.name, 2);
            ELSE
                PERFORM dec_refcount('label_name', OLD.name, 1);
                PERFORM dec_refcount('label_name', OLD.sortname, 1);
            END IF;
            IF NEW.name = NEW.sortname THEN
                PERFORM inc_refcount('label_name', NEW.name, 2);
            ELSE
                PERFORM inc_refcount('label_name', NEW.name, 1);
                PERFORM inc_refcount('label_name', NEW.sortname, 1);
            END IF;
        ELSE
            -- only names are different
            PERFORM dec_refcount('label_name', OLD.name, 1);
            PERFORM inc_refcount('label_name', NEW.name, 1);
        END IF;
    ELSE
        -- only sortnames are different
        IF NEW.sortname != OLD.sortname THEN
            PERFORM dec_refcount('label_name', OLD.sortname, 1);
            PERFORM inc_refcount('label_name', NEW.sortname, 1);
        END IF;
    END IF;
    IF NEW.editpending = OLD.editpending THEN
        -- editpending is unchanged and we are in UPDATE query, that means some data have changed
        UPDATE label_meta SET lastupdate=NOW() WHERE id=NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_label() RETURNS trigger AS $$
BEGIN
    IF OLD.name = OLD.sortname THEN
        PERFORM dec_refcount('label_name', OLD.name, 2);
    ELSE
        PERFORM dec_refcount('label_name', OLD.name, 1);
        PERFORM dec_refcount('label_name', OLD.sortname, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- label_alias triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_label_alias() RETURNS trigger AS $$
BEGIN
    PERFORM inc_refcount('label_name', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_label_alias() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_refcount('label_name', OLD.name, 1);
        PERFORM inc_refcount('label_name', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_label_alias() RETURNS trigger AS $$
BEGIN
    PERFORM dec_refcount('label_name', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- recording triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_recording() RETURNS trigger AS $$
BEGIN
    PERFORM inc_refcount('track_name', NEW.name, 1);
    PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    INSERT INTO recording_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_recording() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_refcount('track_name', OLD.name, 1);
        PERFORM inc_refcount('track_name', NEW.name, 1);
    END IF;
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.editpending = OLD.editpending THEN
        -- editpending is unchanged and we are in UPDATE query, that means some data have changed
        UPDATE recording_meta SET lastupdate=NOW() WHERE id=NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_recording() RETURNS trigger AS $$
BEGIN
    PERFORM dec_refcount('track_name', OLD.name, 1);
    PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- release triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_release() RETURNS trigger AS $$
BEGIN
    -- increment refcount of the name
    PERFORM inc_refcount('release_name', NEW.name, 1);
    PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    -- increment releasecount of the parent release group
    UPDATE release_group_meta SET releasecount = releasecount + 1 WHERE id = NEW.release_group;
    -- add new release_meta
    INSERT INTO release_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        -- name is changed, fix refcounts
        PERFORM dec_refcount('release_name', OLD.name, 1);
        PERFORM inc_refcount('release_name', NEW.name, 1);
    END IF;
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.release_group != OLD.release_group THEN
        -- release group is changed, decrement releasecount in the original RG, increment in the new one
        UPDATE release_group_meta SET releasecount = releasecount - 1 WHERE id = OLD.release_group;
        UPDATE release_group_meta SET releasecount = releasecount + 1 WHERE id = NEW.release_group;
    END IF;
    IF NEW.editpending = OLD.editpending THEN
        -- editpending is unchanged and we are in UPDATE query, that means some data have changed
        UPDATE release_meta SET lastupdate=NOW() WHERE id=NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release() RETURNS trigger AS $$
BEGIN
    -- decrement refcount of the name
    PERFORM dec_refcount('release_name', OLD.name, 1);
    PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
    -- decrement releasecount of the parent release group
    UPDATE release_group_meta SET releasecount = releasecount - 1 WHERE id = OLD.release_group;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- release_group triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_release_group() RETURNS trigger AS $$
BEGIN
    PERFORM inc_refcount('release_name', NEW.name, 1);
    PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    INSERT INTO release_group_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_group() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_refcount('release_name', OLD.name, 1);
        PERFORM inc_refcount('release_name', NEW.name, 1);
    END IF;
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.editpending = OLD.editpending THEN
        -- editpending is unchanged and we are in UPDATE query, that means some data have changed
        UPDATE release_group_meta SET lastupdate=NOW() WHERE id=NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_group() RETURNS trigger AS $$
BEGIN
    PERFORM dec_refcount('release_name', OLD.name, 1);
    PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- track triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_track() RETURNS trigger AS $$
BEGIN
    PERFORM inc_refcount('track_name', NEW.name, 1);
    PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    -- increment trackcount in the parent tracklist
    UPDATE tracklist SET trackcount = trackcount + 1 WHERE id = NEW.tracklist;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_track() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_refcount('track_name', OLD.name, 1);
        PERFORM inc_refcount('track_name', NEW.name, 1);
    END IF;
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.tracklist != OLD.tracklist THEN
        -- tracklist is changed, decrement trackcount in the original tracklist, increment in the new one
        UPDATE tracklist SET trackcount = trackcount - 1 WHERE id = OLD.tracklist;
        UPDATE tracklist SET trackcount = trackcount + 1 WHERE id = NEW.tracklist;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_track() RETURNS trigger AS $$
BEGIN
    PERFORM dec_refcount('track_name', OLD.name, 1);
    PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
    -- decrement trackcount in the parent tracklist
    UPDATE tracklist SET trackcount = trackcount - 1 WHERE id = OLD.tracklist;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-----------------------------------------------------------------------
-- work triggers
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_ins_work() RETURNS trigger AS $$
BEGIN
    PERFORM inc_refcount('work_name', NEW.name, 1);
    PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    INSERT INTO work_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_work() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_refcount('work_name', OLD.name, 1);
        PERFORM inc_refcount('work_name', NEW.name, 1);
    END IF;
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.editpending = OLD.editpending THEN
        -- editpending is unchanged and we are in UPDATE query, that means some data have changed
        UPDATE work_meta SET lastupdate=NOW() WHERE id=NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_work() RETURNS trigger AS $$
BEGIN
    PERFORM dec_refcount('work_name', OLD.name, 1);
    PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
    RETURN NULL;
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
COMMIT;

-- vi: set ts=4 sw=4 et :
