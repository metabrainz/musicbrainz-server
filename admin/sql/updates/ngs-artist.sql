BEGIN;

------------------------
-- Artists
------------------------

INSERT INTO artist_name (name)
    (SELECT DISTINCT name FROM public.artist) UNION
    (SELECT DISTINCT sortname FROM public.artist) UNION
    (SELECT DISTINCT name FROM public.artistalias);
SELECT setval('artist_name_id_seq', (SELECT MAX(id) FROM artist_name));

CREATE UNIQUE INDEX tmp_artist_name_name ON artist_name (name);

INSERT INTO artist (id, gid, name, sort_name, type,
                    begin_date_year, begin_date_month, begin_date_day,
                    end_date_year, end_date_month, end_date_day,
                    comment, last_updated)
    SELECT
        a.id, gid::uuid, n1.id, n2.id,
        NULLIF(NULLIF(type, 0), 3),
        NULLIF(substr(begindate, 1, 4)::int, 0),
        NULLIF(substr(begindate, 6, 2)::int, 0),
        NULLIF(substr(begindate, 9, 2)::int, 0),
        NULLIF(substr(enddate, 1, 4)::int, 0),
        NULLIF(substr(enddate, 6, 2)::int, 0),
        NULLIF(substr(enddate, 9, 2)::int, 0),
        resolution,
        m.lastupdate
    FROM public.artist a 
    JOIN artist_name n1 ON a.name = n1.name 
    JOIN artist_name n2 ON a.sortname = n2.name
    JOIN public.artist_meta m ON a.id = m.id;

INSERT INTO artist_credit (id, name, artist_count) SELECT id, name, 1 FROM artist;
SELECT setval('artist_credit_id_seq', (SELECT MAX(id) FROM artist_credit));

INSERT INTO artist_credit_name (artist_credit, artist, name, position) SELECT id, id, name, 0 FROM artist;

INSERT INTO artist_alias (id, artist, name)
    SELECT DISTINCT a.id, a.ref, n.id
    FROM public.artistalias a JOIN artist_name n ON a.name = n.name;

INSERT INTO artist_meta (id, rating, rating_count)
    SELECT id, round(rating * 20), rating_count
    FROM public.artist_meta;

COMMIT;
