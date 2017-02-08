package MusicBrainz::Server::Report::InstrumentsWithoutAnImage;
use Moose;

with 'MusicBrainz::Server::Report::InstrumentReport';

sub table { 'instruments_without_an_image' }

sub query
{
    q{
        SELECT
            i.id AS instrument_id,
            row_number() OVER (ORDER BY i.type, musicbrainz_collate(i.name))
        FROM
            instrument i
            LEFT JOIN l_instrument_url liu ON i.id = liu.entity0
            LEFT JOIN link l ON liu.link = l.id AND l.link_type IN (
                SELECT lt.id
                FROM link_type lt
                WHERE lt.name IN ('image', 'wikidata')
            )
        WHERE
            liu.link IS NULL
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
