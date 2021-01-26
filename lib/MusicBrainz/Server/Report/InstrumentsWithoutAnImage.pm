package MusicBrainz::Server::Report::InstrumentsWithoutAnImage;
use Moose;

with 'MusicBrainz::Server::Report::InstrumentReport';

sub table { 'instruments_without_an_image' }

sub query
{
    q{
        SELECT
            i.id AS instrument_id,
            row_number() OVER (ORDER BY i.name COLLATE musicbrainz, i.type)
        FROM instrument i
        WHERE NOT EXISTS (
            SELECT 1
            FROM l_instrument_url liu
            JOIN link l ON liu.link = l.id
            JOIN link_type lt ON l.link_type = lt.id
            JOIN url ON liu.entity1 = url.id
            WHERE liu.entity0 = i.id
            AND lt.gid = 'f64eacbd-1ea1-381e-9886-2cfb552b7d90' --image
            AND url.url LIKE '%staticbrainz.org/irombook%'
        )
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2017 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
