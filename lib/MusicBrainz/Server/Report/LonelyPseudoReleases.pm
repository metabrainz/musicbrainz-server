package MusicBrainz::Server::Report::LonelyPseudoReleases;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {<<~'SQL'}
            SELECT r.id AS release_id,
                   row_number() OVER (
                       ORDER BY ac.name COLLATE musicbrainz,
                                r.name COLLATE musicbrainz
                   )
              FROM release r
              JOIN artist_credit ac ON r.artist_credit = ac.id
             WHERE r.status = 4 --pseudo-release
    AND NOT EXISTS (
                       SELECT 1
                         FROM release r2
                        WHERE r2.release_group = r.release_group
                          AND r2.status != 4
                   )
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
