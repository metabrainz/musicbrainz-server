\set ON_ERROR_STOP 1

BEGIN;

SET LOCAL statement_timeout = 0;

UPDATE area_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE artist_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE event_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE genre_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE instrument_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE label_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE place_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE recording_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE release_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE release_group_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE series_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE work_alias
   SET locale = replace(locale, '-', '_')
 WHERE locale LIKE '%-%';

UPDATE edit_data
   SET data = jsonb_set(data, '{locale}'::text[], to_jsonb(replace(data->>'locale', '-', '_')), false)
  FROM edit
 WHERE edit_data.edit = edit.id
   AND edit.type IN (
    6,      -- EDIT_ARTIST_ADD_ALIAS
    7,      -- EDIT_ARTIST_DELETE_ALIAS
    16,     -- EDIT_LABEL_ADD_ALIAS
    17,     -- EDIT_LABEL_DELETE_ALIAS
    26,     -- EDIT_RELEASEGROUP_ADD_ALIAS
    27,     -- EDIT_RELEASEGROUP_DELETE_ALIAS
    46,     -- EDIT_WORK_ADD_ALIAS
    47,     -- EDIT_WORK_DELETE_ALIAS
    66,     -- EDIT_PLACE_ADD_ALIAS
    67,     -- EDIT_PLACE_DELETE_ALIAS
    86,     -- EDIT_AREA_ADD_ALIAS
    87,     -- EDIT_AREA_DELETE_ALIAS
    136,    -- EDIT_INSTRUMENT_ADD_ALIAS
    137,    -- EDIT_INSTRUMENT_DELETE_ALIAS
    145,    -- EDIT_SERIES_ADD_ALIAS
    146,    -- EDIT_SERIES_DELETE_ALIAS
    155,    -- EDIT_EVENT_ADD_ALIAS
    156,    -- EDIT_EVENT_DELETE_ALIAS
    318,    -- EDIT_RELEASE_ADD_ALIAS
    319,    -- EDIT_RELEASE_DELETE_ALIAS
    711,    -- EDIT_RECORDING_ADD_ALIAS
    712     -- EDIT_RECORDING_DELETE_ALIAS
   )
   AND edit_data.data#>>'{locale}' LIKE '%-%';

UPDATE edit_data
   SET data = jsonb_set(
                data,
                '{old,locale}'::text[],
                to_jsonb(replace(data#>>'{old,locale}', '-', '_')),
                false)
  FROM edit
 WHERE edit_data.edit = edit.id
   AND edit.type IN (
    8,     -- EDIT_ARTIST_EDIT_ALIAS
    18,    -- EDIT_LABEL_EDIT_ALIAS
    28,    -- EDIT_RELEASEGROUP_EDIT_ALIAS
    48,    -- EDIT_WORK_EDIT_ALIAS
    68,    -- EDIT_PLACE_EDIT_ALIAS
    88,    -- EDIT_AREA_EDIT_ALIAS
    138,   -- EDIT_INSTRUMENT_EDIT_ALIAS
    147,   -- EDIT_SERIES_EDIT_ALIAS
    157,   -- EDIT_EVENT_EDIT_ALIAS
    320,   -- EDIT_RELEASE_EDIT_ALIAS
    713    -- EDIT_RECORDING_EDIT_ALIAS
   )
   AND edit_data.data#>>'{old,locale}' LIKE '%-%';

UPDATE edit_data
   SET data = jsonb_set(
                data,
                '{new,locale}'::text[],
                to_jsonb(replace(data#>>'{new,locale}', '-', '_')),
                false)
  FROM edit
 WHERE edit_data.edit = edit.id
   AND edit.type IN (
    8,     -- EDIT_ARTIST_EDIT_ALIAS
    18,    -- EDIT_LABEL_EDIT_ALIAS
    28,    -- EDIT_RELEASEGROUP_EDIT_ALIAS
    48,    -- EDIT_WORK_EDIT_ALIAS
    68,    -- EDIT_PLACE_EDIT_ALIAS
    88,    -- EDIT_AREA_EDIT_ALIAS
    138,   -- EDIT_INSTRUMENT_EDIT_ALIAS
    147,   -- EDIT_SERIES_EDIT_ALIAS
    157,   -- EDIT_EVENT_EDIT_ALIAS
    320,   -- EDIT_RELEASE_EDIT_ALIAS
    713    -- EDIT_RECORDING_EDIT_ALIAS
   )
   AND edit_data.data#>>'{new,locale}' LIKE '%-%';

COMMIT;
