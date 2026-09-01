\set ON_ERROR_STOP 1
BEGIN;

-----------------------------------
-- UPDATE VIEW TO USE RIGHT GID  --
-----------------------------------

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
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '8fe04b66-fe39-40ce-a28f-76b816d3f55a')
    LEFT OUTER JOIN link_attribute_text_value latv ON (latv.attribute_type = 788 AND latv.link = l.id)
    ORDER BY series, link_order;

COMMIT;
