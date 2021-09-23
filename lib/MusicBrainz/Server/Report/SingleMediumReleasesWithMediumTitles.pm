package MusicBrainz::Server::Report::SingleMediumReleasesWithMediumTitles;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
   q{SELECT DISTINCT ON (release.id)
      release.id AS release_id,
      row_number() OVER (
        ORDER BY artist_credit.name COLLATE musicbrainz, release.name COLLATE musicbrainz
      )
    FROM release
    JOIN medium ON release.id = medium.release
    JOIN artist_credit ON release.artist_credit = artist_credit.id
    WHERE release.id IN (
      SELECT release
      FROM medium
      GROUP BY release
      HAVING count(id) = 1
    ) AND medium.name != ''};
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

