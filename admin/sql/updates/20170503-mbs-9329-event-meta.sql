\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION a_ins_event() RETURNS trigger AS $$
BEGIN
    INSERT INTO event_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

INSERT INTO event_meta (id, rating, rating_count)
    (SELECT event AS id,
            trunc((sum(rating) / count(rating)) + 0.5) AS rating,
            count(rating) AS rating_count
       FROM event_rating_raw
      GROUP BY event)
    ON CONFLICT (id)
    DO UPDATE SET rating = EXCLUDED.rating,
                  rating_count = EXCLUDED.rating_count;

COMMIT;
