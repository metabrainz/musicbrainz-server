package MusicBrainz::Server::Report::ReleasesToConvert;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT DISTINCT release.id AS release_id,
          row_number() OVER (ORDER BY musicbrainz_collate(ac_name.name), musicbrainz_collate(release_name.name))
        FROM track_name
        JOIN track ON track.name = track_name.id
        JOIN medium ON medium.id = track.medium
        JOIN release ON medium.release = release.id
        JOIN release_name ON release.name = release_name.id
        JOIN artist_credit ON release.artist_credit = artist_credit.id
        JOIN artist_name ac_name ON artist_credit.name = ac_name.id
        WHERE track_name.name ~* E'[^\\d]-[^\\d]' OR track_name.name LIKE '%/%'
        GROUP BY release.id, release_name.name, medium.id, medium.track_count, ac_name.name
        HAVING count(*) = medium.track_count
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
