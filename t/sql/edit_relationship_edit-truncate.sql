BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE link_type CASCADE;
TRUNCATE link CASCADE;
TRUNCATE l_artist_artist CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_name CASCADE;

COMMIT;
