package MusicBrainz::Server::Report::EmptyReleaseGroups;
use Moose;
use utf8;

with 'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseGroupID';

sub query {<<~'SQL'}
    SELECT rg.id AS release_group_id,
           row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, rg.name COLLATE musicbrainz)
      FROM release_group rg
      JOIN artist_credit ac ON rg.artist_credit = ac.id
      JOIN release_group_meta rm ON rg.id = rm.id
     WHERE NOT EXISTS (
        SELECT 1
          FROM release r
         WHERE r.release_group = rg.id
         LIMIT 1
     )
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

