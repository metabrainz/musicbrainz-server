BEGIN;

SET search_path = 'event_art_archive';

CREATE OR REPLACE FUNCTION reindex_event() RETURNS trigger AS $$
    DECLARE
        event_mbid UUID;
    BEGIN
        SELECT gid INTO event_mbid
        FROM musicbrainz.event e
        JOIN event_art_archive.event_art ea ON e.id = ea.event
        WHERE e.id = NEW.id;

        IF FOUND THEN
            PERFORM amqp.publish(1, 'event-art-archive', 'index', event_mbid::text);
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER eaa_reindex AFTER UPDATE OR INSERT
ON musicbrainz.event FOR EACH ROW
EXECUTE PROCEDURE reindex_event();

CREATE OR REPLACE FUNCTION reindex_artist() RETURNS trigger AS $$
    BEGIN
        -- Short circuit if the name hasn't changed
        IF NEW.name = OLD.name AND NEW.sort_name = OLD.sort_name THEN
            RETURN NULL;
        END IF;

        PERFORM amqp.publish(1, 'event-art-archive', 'index', e.gid::text)
        FROM musicbrainz.event e
        JOIN event_art_archive.event_art ea ON e.id = ea.event
        JOIN musicbrainz.l_artist_event lae ON e.id = lae.entity1
        WHERE lae.entity0 = NEW.id;

        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER eaa_reindex AFTER UPDATE
ON musicbrainz.artist FOR EACH ROW
EXECUTE PROCEDURE reindex_artist();

CREATE OR REPLACE FUNCTION reindex_l_artist_event() RETURNS trigger AS $$
    BEGIN
        PERFORM amqp.publish(1, 'event-art-archive', 'index', e.gid::text)
        FROM musicbrainz.event e
        JOIN event_art_archive.event_art ea ON e.id = ea.event
        JOIN musicbrainz.l_artist_event lae ON e.id = lae.entity1
        WHERE lae.id = (CASE TG_OP
                            WHEN 'DELETE' THEN OLD.id
                            ELSE NEW.id
                        END);
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER eaa_reindex AFTER UPDATE OR INSERT OR DELETE
ON musicbrainz.l_artist_event FOR EACH ROW
EXECUTE PROCEDURE reindex_l_artist_event();

CREATE OR REPLACE FUNCTION reindex_place() RETURNS trigger AS $$
    BEGIN
        PERFORM amqp.publish(1, 'event-art-archive', 'index', e.gid::text)
        FROM musicbrainz.event e
        JOIN event_art_archive.event_art ea ON e.id = ea.event
        JOIN musicbrainz.l_event_place lep ON e.id = lep.entity0
        WHERE lep.entity1 = NEW.id;

        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER eaa_reindex AFTER UPDATE
ON musicbrainz.place FOR EACH ROW
EXECUTE PROCEDURE reindex_place();

CREATE OR REPLACE FUNCTION reindex_l_event_place() RETURNS trigger AS $$
    BEGIN
        PERFORM amqp.publish(1, 'event-art-archive', 'index', e.gid::text)
        FROM musicbrainz.event e
        JOIN event_art_archive.event_art ea ON e.id = ea.event
        JOIN musicbrainz.l_event_place lep ON e.id = lep.entity0
        WHERE lep.id = (CASE TG_OP
                            WHEN 'DELETE' THEN OLD.id
                            ELSE NEW.id
                        END);
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER eaa_reindex AFTER UPDATE OR INSERT OR DELETE
ON musicbrainz.l_event_place FOR EACH ROW
EXECUTE PROCEDURE reindex_l_event_place();

CREATE OR REPLACE FUNCTION reindex_eaa() RETURNS trigger AS $$
    BEGIN
        PERFORM amqp.publish(1, 'event-art-archive', 'index', gid::text)
        FROM musicbrainz.event
        WHERE id = coalesce((
                     CASE TG_OP
                         WHEN 'DELETE' THEN OLD.event
                         ELSE NEW.event
                     END));
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER eaa_reindex AFTER UPDATE OR INSERT OR DELETE
ON event_art_archive.event_art FOR EACH ROW
EXECUTE PROCEDURE reindex_eaa();

CREATE OR REPLACE FUNCTION move_event() RETURNS trigger AS $$
    BEGIN
        IF OLD.event != NEW.event THEN
            PERFORM amqp.publish(1, 'event-art-archive', 'move',
                      (SELECT ea.id || E'\n' ||
                              old_event.gid || E'\n' ||
                              new_event.gid || E'\n' ||
                              it.suffix || E'\n'
                       FROM event_art_archive.event_art ea
                       JOIN cover_art_archive.image_type it ON it.mime_type = ea.mime_type,
                         musicbrainz.event old_event,
                         musicbrainz.event new_event
                       WHERE ea.id = OLD.id
                       AND old_event.id = OLD.event
                       AND new_event.id = NEW.event));
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER eaa_move BEFORE UPDATE
ON event_art_archive.event_art FOR EACH ROW
EXECUTE PROCEDURE move_event();

CREATE OR REPLACE FUNCTION delete_event() RETURNS trigger AS $$
    BEGIN
        PERFORM
          amqp.publish(1, 'event-art-archive', 'delete',
            (event_art.id || E'\n' || OLD.gid || E'\n' || image_type.suffix)::text)
        FROM event_art_archive.event_art
        JOIN cover_art_archive.image_type ON image_type.mime_type = event_art.mime_type
        WHERE event = OLD.id;

        PERFORM amqp.publish(1, 'event-art-archive', 'delete',
            ('index.json' || E'\n' || OLD.gid)::text)
        FROM musicbrainz.event
        WHERE event.id = OLD.id;

        RETURN OLD;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER eaa_delete BEFORE DELETE
ON musicbrainz.event FOR EACH ROW
EXECUTE PROCEDURE delete_event();

COMMIT;
