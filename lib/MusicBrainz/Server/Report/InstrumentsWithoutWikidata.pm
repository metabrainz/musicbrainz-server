package MusicBrainz::Server::Report::InstrumentsWithoutWikidata;
use Moose;

with 'MusicBrainz::Server::Report::InstrumentReport';

sub table { 'instruments_without_wikidata' }

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
            WHERE liu.entity0 = i.id
            AND lt.gid = '1486fccd-cf59-35e4-9399-b50e2b255877' --wikidata
        )
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
