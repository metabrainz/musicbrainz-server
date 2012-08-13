BEGIN;
DELETE FROM statistic WHERE name IN 
    -- i.e.: iso_code_3-only language, set to frequency 0.
    (SELECT regexp_replace(language.iso_code_3, '^', 'count.release.language.') FROM language WHERE iso_code_2t IS NULL AND frequency = 0 
         UNION 
     SELECT regexp_replace(language.iso_code_3, '^', 'count.work.language.') FROM language WHERE iso_code_2t IS NULL AND frequency = 0);
COMMIT;
