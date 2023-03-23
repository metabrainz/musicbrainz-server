\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER update_tags_and_ratings_for_spammer AFTER UPDATE ON editor
    FOR EACH ROW EXECUTE PROCEDURE update_tags_and_ratings_for_spammer();

COMMIT;
