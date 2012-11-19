package MusicBrainz::Server::Report::ArtistsThatMayBePersons;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    "
WITH groups AS (
         SELECT DISTINCT ON (artist.id) artist.id, artist.name FROM
         artist
         JOIN l_artist_artist laa ON laa.entity1 = artist.id
         JOIN link on link.id = laa.link
         JOIN link_type on link_type.id = link.link_type
         WHERE artist.type IS DISTINCT FROM 1
         AND link_type.name IN ('member of band', 'collaboration', 'conductor position')),
     persons_entity0 AS (
         SELECT DISTINCT ON (artist.id) artist.id, artist.name FROM
         artist
         JOIN l_artist_artist laa ON laa.entity0 = artist.id
         JOIN link on link.id = laa.link
         JOIN link_type on link_type.id = link.link_type
         WHERE artist.type IS DISTINCT FROM 1
         AND link_type.name IN ('member of band', 'collaboration', 'voice actor', 'conductor position', 'is person', 'married', 'sibling', 'parent', 'involved with')),
     persons_entity1 AS (
         SELECT DISTINCT ON (artist.id) artist.id, artist.name FROM
         artist
         JOIN l_artist_artist laa ON laa.entity1 = artist.id
         JOIN link on link.id = laa.link
         JOIN link_type on link_type.id = link.link_type
         WHERE artist.type IS DISTINCT FROM 1
         AND link_type.name IN ('catalogued', 'is person', 'married', 'sibling', 'parent', 'involved with')),
     artists AS (
         SELECT DISTINCT ON (id) id, name FROM
             (SELECT * FROM persons_entity0
                  UNION
              SELECT * from persons_entity1) AS persons
          EXCEPT
              SELECT * from groups)
SELECT DISTINCT ON (artists.id) artists.id AS artist_id, row_number() OVER (ORDER BY musicbrainz_collate(name.name), artists.id)
    FROM artists
    JOIN artist_name AS name ON artists.name = name.id
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
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
