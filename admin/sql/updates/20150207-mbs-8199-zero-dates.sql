UPDATE release_country
   SET date_year = NULL, date_month = NULL, date_day = NULL
 WHERE date_year = 0 AND date_month = 0 AND date_day = 0;
