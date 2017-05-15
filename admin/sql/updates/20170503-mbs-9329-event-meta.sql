\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION a_ins_event() RETURNS trigger AS $$
BEGIN
    INSERT INTO event_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

TRUNCATE event_meta;

INSERT INTO event_meta (id) (SELECT id FROM event);

UPDATE event_meta
   SET rating = ratings.rating,
       rating_count = ratings.rating_count
  FROM (SELECT event,
               trunc((sum(rating) / count(rating)) + 0.5) AS rating,
               count(rating) AS rating_count
          FROM event_rating_raw
         GROUP BY event) ratings
 WHERE event_meta.id = ratings.event;

COMMIT;
