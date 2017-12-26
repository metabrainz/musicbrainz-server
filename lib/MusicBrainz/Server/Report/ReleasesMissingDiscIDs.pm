package MusicBrainz::Server::Report::ReleasesMissingDiscIDs;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

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
              WHERE (SELECT has_discids FROM medium_format WHERE medium_format.id = medium.format)
              AND id NOT IN (SELECT medium FROM medium_cdtoc)
          )
          AND status NOT IN (3, 4) -- ignore pseudo and bootleg releases
        ) r
    }
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
