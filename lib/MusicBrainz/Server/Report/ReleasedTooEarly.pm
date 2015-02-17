package MusicBrainz::Server::Report::ReleasedTooEarly;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT DISTINCT ON (r.id)
            r.id AS release_id,
            row_number() OVER (ORDER BY musicbrainz_collate(ac.name), musicbrainz_collate(r.name))
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
            LEFT JOIN medium_cdtoc mcd on mcd.medium = m.id
            WHERE
              (mcd.id IS NOT NULL AND date_year < (select min(year) from medium_format where has_discids = 't')) OR
              (mcd.id IS NOT NULL AND mf.year IS NOT NULL AND mf.has_discids = 'f') OR
              (mf.year IS NOT NULL AND date_year < mf.year)
          ) r
        JOIN artist_credit ac ON r.artist_credit = ac.id
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
