BEGIN;
-----------------------
-- CREATE NEW TABLES --
-----------------------
CREATE TABLE place_type (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL);

CREATE TABLE place (id SERIAL PRIMARY KEY,
                    gid uuid NOT NULL,
                    name INTEGER NOT NULL REFERENCES location_name(id),
                    type INTEGER REFERENCES place_type(id),
                    address VARCHAR NOT NULL DEFAULT '',
                    coordinates CUBE,
                    begin_date_year     SMALLINT,
                    begin_date_month    SMALLINT,
                    begin_date_day      SMALLINT,
                    end_date_year       SMALLINT,
                    end_date_month      SMALLINT,
                    end_date_day        SMALLINT);
ROLLBACK;
