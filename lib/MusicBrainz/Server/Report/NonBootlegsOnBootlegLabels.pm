package MusicBrainz::Server::Report::NonBootlegsOnBootlegLabels;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {<<~'SQL'}
    SELECT DISTINCT ON (r.id)
        r.id AS release_id,
        row_number() OVER (ORDER BY r.artist_credit, r.name)
    FROM
    ( SELECT id, artist_credit, name
      FROM release
      WHERE status != 3 -- not a bootleg
      AND EXISTS (
        SELECT 1
        FROM release_label rl
        JOIN label ON label.id = rl.label
        WHERE rl.release = release.id
        AND label.type = 5 -- bootleg production
      )
    ) r
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
