\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION edit_data_type_info(data JSONB) RETURNS TEXT AS $$
BEGIN
    CASE jsonb_typeof(data)
    WHEN 'object' THEN
        RETURN '{' ||
            (SELECT string_agg(
                to_json(key) || ':' ||
                edit_data_type_info(jsonb_extract_path(data, key)),
                ',' ORDER BY key)
               FROM jsonb_object_keys(data) AS key) ||
            '}';
    WHEN 'array' THEN
        RETURN '[' ||
            (SELECT string_agg(
                DISTINCT edit_data_type_info(item),
                ',' ORDER BY edit_data_type_info(item))
               FROM jsonb_array_elements(data) AS item) ||
            ']';
    WHEN 'string' THEN
        RETURN '1';
    WHEN 'number' THEN
        RETURN '2';
    WHEN 'boolean' THEN
        RETURN '4';
    WHEN 'null' THEN
        RETURN '8';
    END CASE;
    RETURN '';
END;
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE STRICT;

COMMIT;
