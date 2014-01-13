\set ON_ERROR_STOP 1
BEGIN;
-- FUNCTIONS
CREATE OR REPLACE FUNCTION delete_unused_url(ids INTEGER[])
RETURNS VOID AS $$
DECLARE
  clear_up INTEGER[];
BEGIN
  SELECT ARRAY(
    SELECT id FROM url url_row WHERE id = any(ids)
    AND NOT (
      EXISTS (
        SELECT TRUE FROM l_area_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
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
        SELECT TRUE FROM l_place_url
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
        SELECT TRUE FROM l_area_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_artist_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_label_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_place_recording WHERE entity1 = outer_r.id
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
      DELETE FROM recording_rating_raw WHERE recording = OLD.recording;
      DELETE FROM recording_tag WHERE recording = OLD.recording;
      DELETE FROM recording_tag_raw WHERE recording = OLD.recording;

      DELETE FROM recording WHERE id = OLD.recording;
    END IF;

    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

-- TRIGGERS
-- remove_unused_url
CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_area_url
AFTER UPDATE ON l_area_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_area_url
AFTER DELETE ON l_area_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_place_url
AFTER UPDATE ON l_place_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_place_url
AFTER DELETE ON l_place_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

-- remove_unused_links
CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_area DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_artist DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_label DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_place DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_recording DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_place DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_label_place DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_place_place DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_place_recording DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_place_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_place_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_place_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_place_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

-- clean up URL and link tables
SELECT delete_unused_url(array_agg(id)) FROM url url_row WHERE NOT (
      EXISTS (
        SELECT TRUE FROM l_area_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
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
        SELECT TRUE FROM l_place_url
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
      ));

CREATE TEMPORARY TABLE unused
    ON COMMIT DROP
    AS
    SELECT link.id
    FROM   link
    JOIN   link_type ON link.link_type = link_type.id
    WHERE
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'area'
            AND NOT EXISTS (SELECT TRUE FROM l_area_area WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'artist'
            AND NOT EXISTS (SELECT TRUE FROM l_area_artist WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'label'
            AND NOT EXISTS (SELECT TRUE FROM l_area_label WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'place'
            AND NOT EXISTS (SELECT TRUE FROM l_area_place WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'recording'
            AND NOT EXISTS (SELECT TRUE FROM l_area_recording WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'release'
            AND NOT EXISTS (SELECT TRUE FROM l_area_release WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'release_group'
            AND NOT EXISTS (SELECT TRUE FROM l_area_release_group WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'url'
            AND NOT EXISTS (SELECT TRUE FROM l_area_url WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'area'
            AND link_type.entity_type1 = 'work'
            AND NOT EXISTS (SELECT TRUE FROM l_area_work WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'artist'
            AND link_type.entity_type1 = 'place'
            AND NOT EXISTS (SELECT TRUE FROM l_artist_place WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'label'
            AND link_type.entity_type1 = 'place'
            AND NOT EXISTS (SELECT TRUE FROM l_label_place WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'place'
            AND link_type.entity_type1 = 'place'
            AND NOT EXISTS (SELECT TRUE FROM l_place_place WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'place'
            AND link_type.entity_type1 = 'recording'
            AND NOT EXISTS (SELECT TRUE FROM l_place_recording WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'place'
            AND link_type.entity_type1 = 'release'
            AND NOT EXISTS (SELECT TRUE FROM l_place_release WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'place'
            AND link_type.entity_type1 = 'release_group'
            AND NOT EXISTS (SELECT TRUE FROM l_place_release_group WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'place'
            AND link_type.entity_type1 = 'url'
            AND NOT EXISTS (SELECT TRUE FROM l_place_url WHERE link = link.id LIMIT 1))
    OR
           (link_type.entity_type0 = 'place'
            AND link_type.entity_type1 = 'work'
            AND NOT EXISTS (SELECT TRUE FROM l_place_work WHERE link = link.id LIMIT 1));

DELETE FROM link_attribute WHERE link IN (SELECT id FROM unused);
DELETE FROM link WHERE id IN (SELECT id FROM unused);

COMMIT;
