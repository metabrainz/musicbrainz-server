package MusicBrainz::Server::Report::ReleaseLabelSameArtist;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    q{
      SELECT DISTINCT
        release.id AS release_id,
        row_number() OVER (ORDER BY release.artist_credit, release.name)
      FROM
        release
        INNER JOIN artist ON release.artist_credit=artist.id
        INNER JOIN release_label ON release_label.release=release.id
        INNER JOIN label ON release_label.label=label.id
      WHERE
        label.name=artist.name
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
