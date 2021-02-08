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
SELECT DISTINCT ON (artists.id) artists.id AS artist_id, row_number() OVER (ORDER BY artists.name COLLATE musicbrainz, artists.id)
    FROM artists
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
