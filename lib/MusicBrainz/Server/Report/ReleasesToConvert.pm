package MusicBrainz::Server::Report::ReleasesToConvert;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    q{
        SELECT DISTINCT release.id AS release_id,
          row_number() OVER (ORDER BY artist_credit.name COLLATE musicbrainz, release.name COLLATE musicbrainz)
        FROM track
        JOIN medium ON medium.id = track.medium
        JOIN release ON medium.release = release.id
        JOIN artist_credit ON release.artist_credit = artist_credit.id
        WHERE track.name ~* E'[^\\\\d]-[^\\\\d]' OR track.name LIKE '%/%'
        GROUP BY release.id, release.name, medium.id, medium.track_count, artist_credit.name
        HAVING count(*) = medium.track_count
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
