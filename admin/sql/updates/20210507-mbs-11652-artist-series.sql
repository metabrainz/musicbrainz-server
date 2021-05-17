\set ON_ERROR_STOP 1
BEGIN;

\set ARTIST_PART_OF_SERIES_ID '996'

-- generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/artist/series/part_of')
\set ARTIST_PART_OF_SERIES_GID '''d1a845d1-8c03-3191-9454-e4e8d37fa5e0'''

-- id from link_attribute_type where name = 'number'
\set LINK_ATTRIBUTE_TYPE_NUMBER_ID '788'

-----------------------
-- CREATE NEW VIEWS  --
-----------------------

CREATE OR REPLACE VIEW artist_series AS
    SELECT entity0 AS artist,
           entity1 AS series,
           las.id AS relationship,
           link_order,
           las.link,
           COALESCE(text_value, '') AS text_value
    FROM l_artist_series las
    JOIN series s ON s.id = las.entity1
    JOIN link l ON l.id = las.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = :ARTIST_PART_OF_SERIES_GID)
    LEFT OUTER JOIN link_attribute_text_value latv ON (latv.attribute_type = :LINK_ATTRIBUTE_TYPE_NUMBER_ID AND latv.link = l.id)
    ORDER BY series, link_order;

-------------------------
-- INSERT INITIAL DATA --
-------------------------

-- Part-of-series rel

INSERT INTO link_type (id, gid, entity_type0, entity_type1, entity0_cardinality,
                       entity1_cardinality, name, description, link_phrase,
                       reverse_link_phrase, long_link_phrase) VALUES
    (
        :ARTIST_PART_OF_SERIES_ID,
        :ARTIST_PART_OF_SERIES_GID,
        'artist', 'series', 0, 0, 'part of',
        'Indicates that the artist is part of a series.',
        'part of', 'has parts', 'is a part of'
    );

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max) VALUES
    (
        :ARTIST_PART_OF_SERIES_ID,
        :LINK_ATTRIBUTE_TYPE_NUMBER_ID,
        0,
        1
    );

INSERT INTO orderable_link_type (link_type, direction) VALUES
    (:ARTIST_PART_OF_SERIES_ID, 2);

ALTER TABLE series_type DROP CONSTRAINT IF EXISTS allowed_series_entity_type;

INSERT INTO series_type (id, name, entity_type, parent, child_order, description, gid) VALUES
    (13, 'Artist series', 'artist', NULL, 4, 'A series of artists.', generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'series_type13')),
    (14, 'Artist award', 'artist', 13, 0, 'A series of artists honoured by the same award.', generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'series_type14'));

\unset ARTIST_PART_OF_SERIES_GID
\unset LINK_ATTRIBUTE_TYPE_NUMBER_ID

COMMIT;
