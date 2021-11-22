package MusicBrainz::Server::Report::MediumsWithOrderInTitle;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    <<~'SQL'
    SELECT DISTINCT ON (release.id)
        release.id AS release_id,
        row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, release.name COLLATE musicbrainz)
    FROM release
    JOIN artist_credit ac ON release.artist_credit = ac.id
    JOIN medium ON medium.release = release.id
    WHERE medium.name ~* concat('^(Cassette|CD|Disc|DVD|SACD|Vinyl)\s*', medium.position)
    SQL
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
