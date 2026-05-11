\set ON_ERROR_STOP 1
BEGIN;

\set SERIES_PART_OF_SERIES_ID '1307'

\set SERIES_PART_OF_SERIES_GID '''8fe04b66-fe39-40ce-a28f-76b816d3f55a'''

-- id from link_attribute_type where name = 'number'
\set LINK_ATTRIBUTE_TYPE_NUMBER_ID '788'

-----------------------
-- CREATE NEW VIEWS  --
-----------------------

CREATE OR REPLACE VIEW series_series AS
    SELECT entity0 AS series_part,
           entity1 AS series,
           lss.id AS relationship,
           link_order,
           lss.link,
           COALESCE(text_value, '') AS text_value
    FROM l_series_series lss
    JOIN series s ON s.id = lss.entity1
    JOIN link l ON l.id = lss.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '8da75c99-46ff-373c-9d31-276ca8fa8cc3')
    LEFT OUTER JOIN link_attribute_text_value latv ON (latv.attribute_type = 788 AND latv.link = l.id)
    ORDER BY series, link_order;

-------------------------
-- INSERT INITIAL DATA --
-------------------------

-- Part-of-series rel
-- Already exists in production, but disabled (no description)

-- We insert the rel where it does not exist (outside prod)
INSERT INTO link_type (id, gid, entity_type0, entity_type1, entity0_cardinality,
                       entity1_cardinality, name, description, link_phrase,
                       reverse_link_phrase, long_link_phrase) VALUES
    (
        :SERIES_PART_OF_SERIES_ID,
        :SERIES_PART_OF_SERIES_GID,
        'series', 'series', 0, 0, 'part of',
        '',
        'part of', 'has parts', 'is a part of'
    ) ON CONFLICT DO NOTHING;

-- We add the description to enable the rel
UPDATE link_type
   SET description = 'Indicates that the series is part of a series.'
 WHERE gid = :SERIES_PART_OF_SERIES_GID;

-- We insert the attribute and orderable type where they do not exist (outside prod)
INSERT INTO link_attribute_type (id, parent, root, child_order, gid, name, description, last_updated) VALUES
    (
        :LINK_ATTRIBUTE_TYPE_NUMBER_ID,
        NULL,
        :LINK_ATTRIBUTE_TYPE_NUMBER_ID,
        0,
        'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
        'number',
        'This attribute indicates the number of an entity in a series.',
        '2021-05-10 11:27:11.858659+00'
    ) ON CONFLICT DO NOTHING;

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max) VALUES
    (
        :SERIES_PART_OF_SERIES_ID,
        :LINK_ATTRIBUTE_TYPE_NUMBER_ID,
        0,
        1
    ) ON CONFLICT DO NOTHING;

INSERT INTO orderable_link_type (link_type, direction) VALUES
    (:SERIES_PART_OF_SERIES_ID, 2) ON CONFLICT DO NOTHING;

ALTER TABLE series_type DROP CONSTRAINT IF EXISTS allowed_series_entity_type;

INSERT INTO series_type (id, name, entity_type, parent, child_order, description, gid) VALUES
    (16, 'Series series', 'series', NULL, 6, 'A series of series.', generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'series_type16')),
    (17, 'Series award', 'series', 16, 0, 'A series of series (such as podcasts or festivals) honoured by the same award.', generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'series_type17'));

\unset SERIES_PART_OF_SERIES_GID
\unset LINK_ATTRIBUTE_TYPE_NUMBER_ID

COMMIT;
