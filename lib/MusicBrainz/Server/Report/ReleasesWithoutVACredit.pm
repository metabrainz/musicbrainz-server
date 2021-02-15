package MusicBrainz::Server::Report::ReleasesWithoutVACredit;
use Moose;
use MusicBrainz::Server::Constants qw( $VARTIST_ID );

with 'MusicBrainz::Server::Report::ReleaseReport';

sub component_name { 'ReleasesWithoutVaCredit' }

sub query {
    "
        SELECT DISTINCT ON (r.id)
            r.id AS release_id,
            row_number() OVER (ORDER BY r.artist_credit, r.name)
        FROM (
            SELECT r.id, r.artist_credit, r.name
            FROM release r
            JOIN artist_credit_name acn on acn.artist_credit = r.artist_credit
            WHERE acn.artist = $VARTIST_ID AND acn.name != 'Various Artists'

            UNION

            SELECT r.id, r.artist_credit, r.name
            FROM track
            JOIN artist_credit_name acn on acn.artist_credit = track.artist_credit
            JOIN medium on medium.id = track.medium
            JOIN release r on r.id = medium.release
            WHERE acn.artist = $VARTIST_ID AND acn.name != 'Various Artists'
        ) r
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
