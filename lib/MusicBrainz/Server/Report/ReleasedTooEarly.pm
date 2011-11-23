package MusicBrainz::Server::Report::ReleasedTooEarly;
use Moose;

extends 'MusicBrainz::Server::Report::ReleaseReport';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
        SELECT
            DISTINCT r.gid, rn.name, r.artist_credit AS artist_credit_id,
            musicbrainz_collate(an.name), musicbrainz_collate(rn.name)
        FROM
            release r
            JOIN artist_credit ac ON r.artist_credit = ac.id
            JOIN artist_name an ON ac.name = an.id
            JOIN release_name rn ON r.name = rn.id
            JOIN medium m ON m.release = r.id
            LEFT JOIN medium_format mf ON mf.id = m.format
            LEFT JOIN medium_cdtoc mcd on mcd.medium = m.id
        WHERE
            (mcd.id IS NOT NULL AND r.date_year < (select min(year) from medium_format where has_discids = 't')) OR
            (mcd.id IS NOT NULL AND mf.year IS NOT NULL AND mf.has_discids = 'f') OR
            (mf.year IS NOT NULL AND r.date_year < mf.year)
        ORDER BY musicbrainz_collate(an.name), musicbrainz_collate(rn.name)
    ");
}

sub template
{
    return 'report/released_too_early.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation

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
