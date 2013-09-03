use strict;
use warnings;

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

my $ids = [];
do {
    $c->sql->begin;
    $ids = $c->sql->select_single_column_array(<<EOSQL);
UPDATE release_group_meta SET first_release_date_year = updates.date_year,
                              first_release_date_month = updates.date_month,
                              first_release_date_day = updates.date_day
  FROM (
    SELECT *
    FROM (
      SELECT DISTINCT
        release_group,
        first_value(date_year)  OVER sorted_dates AS date_year,
        first_value(date_month) OVER sorted_dates AS date_month,
        first_value(date_day)   OVER sorted_dates AS date_day
      FROM (
        SELECT release, date_year, date_month, date_day
        FROM release_country
        UNION
        SELECT release, date_year, date_month, date_day
        FROM release_unknown_country
      ) events
      JOIN release ON release.id = events.release
      WINDOW sorted_dates AS (
          PARTITION BY release_group
          ORDER BY
            date_year NULLS LAST,
            date_month NULLS LAST,
            date_day NULLS LAST
      )
    ) expected
    JOIN release_group_meta ON release_group_meta.id = release_group
    WHERE (first_release_date_year  IS DISTINCT FROM
                         date_year

        OR first_release_date_month IS DISTINCT FROM
                         date_month

        OR first_release_date_day   IS DISTINCT FROM
                         date_day)
    LIMIT 500
  ) updates
WHERE release_group_meta.id = updates.release_group
RETURNING release_group_meta.id
EOSQL

    warn scalar(@$ids);

    $c->sql->commit;
} while (@$ids > 0);

1;
