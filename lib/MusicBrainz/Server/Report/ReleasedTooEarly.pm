package MusicBrainz::Server::Report::ReleasedTooEarly;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT DISTINCT ON (r.id)
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
          ( SELECT r.*
            FROM release r
            LEFT JOIN (
                SELECT release, date_year, date_month, date_day
                FROM release_country
                UNION ALL
                SELECT release, date_year, date_month, date_day
                FROM release_unknown_country
            ) events ON (events.release = r.id)
            JOIN medium m ON m.release = r.id
            LEFT JOIN medium_format mf ON mf.id = m.format
            LEFT JOIN medium_cdtoc mcd ON mcd.medium = m.id
            WHERE
              (mcd.id IS NOT NULL AND date_year < (SELECT min(year) FROM medium_format WHERE has_discids = 't')) OR
              (mcd.id IS NOT NULL AND mf.year IS NOT NULL AND mf.has_discids = 'f') OR
              (mf.year IS NOT NULL AND date_year < mf.year)
          ) r
        JOIN artist_credit ac ON r.artist_credit = ac.id
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

