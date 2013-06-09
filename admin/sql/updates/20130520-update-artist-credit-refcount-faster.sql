\set ON_ERROR_STOP 1

BEGIN;
    CREATE TEMPORARY TABLE track_ac_count AS SELECT artist_credit, count(*) FROM track GROUP BY artist_credit;
    CREATE TEMPORARY TABLE release_ac_count AS SELECT artist_credit, count(*) FROM release GROUP BY artist_credit;
    CREATE TEMPORARY TABLE release_group_ac_count AS SELECT artist_credit, count(*) FROM release_group GROUP BY artist_credit;
    CREATE TEMPORARY TABLE recording_ac_count AS SELECT artist_credit, count(*) FROM recording GROUP BY artist_credit;

    CREATE TABLE artist_credit_new AS
    SELECT
        artist_credit.id,
        artist_credit.name,
        artist_credit.artist_count,
        (coalesce(track_ac_count.count, 0) + coalesce(release_ac_count.count, 0) + coalesce(release_group_ac_count.count, 0) + coalesce(recording_ac_count.count, 0))::integer AS ref_count,
        artist_credit.created
    FROM
        artist_credit
        LEFT JOIN track_ac_count ON track_ac_count.artist_credit=artist_credit.id
        LEFT JOIN release_ac_count ON release_ac_count.artist_credit=artist_credit.id
        LEFT JOIN release_group_ac_count ON release_group_ac_count.artist_credit=artist_credit.id
        LEFT JOIN recording_ac_count ON recording_ac_count.artist_credit=artist_credit.id;

    -- Drop old artist credit table FKs
    ALTER TABLE recording DROP CONSTRAINT IF EXISTS recording_fk_artist_credit;
    ALTER TABLE release DROP CONSTRAINT IF EXISTS release_fk_artist_credit;
    ALTER TABLE release_group DROP CONSTRAINT IF EXISTS release_group_fk_artist_credit;
    ALTER TABLE track DROP CONSTRAINT IF EXISTS track_fk_artist_credit;

    ALTER TABLE artist_credit_name DROP CONSTRAINT IF EXISTS artist_credit_name_fk_artist_credit;

    -- re-add column defaults/not-null
    ALTER TABLE artist_credit_new
      ALTER COLUMN id SET DEFAULT nextval('artist_credit_id_seq'),
      ALTER COLUMN name SET NOT NULL,
      ALTER COLUMN artist_count SET NOT NULL,
      ALTER COLUMN ref_count SET DEFAULT 0,
      ALTER COLUMN created SET DEFAULT NOW();

    ALTER SEQUENCE artist_credit_id_seq OWNED BY artist_credit_new.id;

    DROP TABLE artist_credit;
    ALTER TABLE artist_credit_new RENAME TO artist_credit;

    -- rebuild PK (FKs separate)
    ALTER TABLE artist_credit ADD CONSTRAINT artist_credit_pkey PRIMARY KEY (id);
COMMIT;
