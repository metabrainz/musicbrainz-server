package MusicBrainz::Server::Report::ShouldNotHaveDiscIDs;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub component_name { 'ShouldNotHaveDiscIds' }

sub query {
    q{
        SELECT DISTINCT ON (r.id)
            r.id AS release_id,
            row_number() OVER (ORDER BY r.artist_credit, r.name)
        FROM
        ( SELECT id, artist_credit, name
          FROM release
          WHERE id IN (
              SELECT release FROM medium
              WHERE (SELECT TRUE FROM medium_format WHERE medium_format.id = medium.format AND has_discids IS FALSE)
              AND id IN (SELECT medium FROM medium_cdtoc)
          )
        ) r
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
