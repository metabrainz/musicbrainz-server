ALTER TABLE artist ADD CONSTRAINT artist_va_check
    CHECK (id <> 1 OR
           (type = 3 AND
            gender IS NULL AND
            country IS NULL AND
            begin_date_year IS NULL AND
            begin_date_month IS NULL AND
            begin_date_day IS NULL AND
            end_date_year IS NULL AND
            end_date_month IS NULL AND
            end_date_day IS NULL));
