package MusicBrainz::Server::Report::ReleasesWithoutVALink;
use Moose;
use MusicBrainz::Server::Constants qw( $VARTIST_ID );

with 'MusicBrainz::Server::Report::ReleaseReport';

sub component_name { 'ReleasesWithoutVaLink' }

sub query {
    "
        SELECT DISTINCT ON (r.id)
            r.id AS release_id,
            row_number() OVER (ORDER BY r.artist_credit, r.name)
        FROM (
            SELECT r.id, r.artist_credit, r.name
            FROM release r
            JOIN artist_credit_name acn ON acn.artist_credit = r.artist_credit
            JOIN artist a ON a.id = acn.artist
            WHERE acn.name = 'Various Artists'
              AND a.name != 'Various Artists'

            UNION

            SELECT r.id, r.artist_credit, r.name
            FROM track
            JOIN artist_credit_name acn ON acn.artist_credit = track.artist_credit
            JOIN artist a ON a.id = acn.artist
            JOIN medium ON medium.id = track.medium
            JOIN release r ON r.id = medium.release
            WHERE acn.name = 'Various Artists'
              AND a.name != 'Various Artists'
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
