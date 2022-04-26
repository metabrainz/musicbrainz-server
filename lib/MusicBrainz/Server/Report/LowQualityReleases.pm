package MusicBrainz::Server::Report::LowQualityReleases;
use Moose;

use MusicBrainz::Server::Constants qw( $QUALITY_LOW );

with 'MusicBrainz::Server::Report::ReleaseReport';
with 'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {<<~"SQL"}
    SELECT
        r.id AS release_id,
        row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
    FROM release r
    JOIN artist_credit ac ON r.artist_credit = ac.id
    WHERE r.quality = $QUALITY_LOW
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
