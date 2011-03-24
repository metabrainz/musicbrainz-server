BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist CASCADE;
TRUNCATE cdtoc CASCADE;
TRUNCATE country CASCADE;
TRUNCATE language CASCADE;
TRUNCATE medium CASCADE;
TRUNCATE medium_cdtoc CASCADE;
TRUNCATE medium_format CASCADE;
TRUNCATE recording CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE release_status CASCADE;
TRUNCATE release_packaging CASCADE;
TRUNCATE script CASCADE;
TRUNCATE tracklist CASCADE;
TRUNCATE track CASCADE;
TRUNCATE track_name CASCADE;

COMMIT;
