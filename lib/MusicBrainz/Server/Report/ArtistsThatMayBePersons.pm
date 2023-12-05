package MusicBrainz::Server::Report::ArtistsThatMayBePersons;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    q{
WITH groups_entity0 AS (
         SELECT artist.id, artist.name
         FROM artist
         JOIN l_artist_artist laa ON laa.entity0 = artist.id
         JOIN link ON link.id = laa.link
         WHERE (
            artist.type NOT IN (1, 4) -- person, character
            OR
            artist.type IS NULL
         )
         AND link.link_type IN (722)), -- subgroup
     groups_entity1 AS (
         SELECT artist.id, artist.name
         FROM artist
         JOIN l_artist_artist laa ON laa.entity1 = artist.id
         JOIN link ON link.id = laa.link
         WHERE (
            artist.type NOT IN (1, 4) -- person, character
            OR
            artist.type IS NULL
         )
         AND link.link_type IN (
            103, -- member of band
            102, -- collaboration
            305, -- conductor position
            965, -- artistic director
            855, -- composer-in-residence
            722  -- subgroup
         )
     ),
     persons_entity0 AS (
         SELECT artist.id, artist.name FROM
         artist
         JOIN l_artist_artist laa ON laa.entity0 = artist.id
         JOIN link ON link.id = laa.link
         WHERE (
            artist.type NOT IN (1, 4) -- person, character
            OR
            artist.type IS NULL
         )
         AND link.link_type IN (
            103, -- member of band
            104, -- supporting musician
            107, -- vocal supporting musician
            105, -- instrumental supporting musician
            102, -- collaboration
            292, -- voice actor
            305, -- conductor position
            965, -- artistic director
            855, -- composer-in-residence
            847, -- teacher
            108, -- is person
            111, -- married
            110, -- sibling
            109, -- parent
            112  -- involved with
         )
     ),
     persons_entity1 AS (
         SELECT artist.id, artist.name FROM
         artist
         JOIN l_artist_artist laa ON laa.entity1 = artist.id
         JOIN link ON link.id = laa.link
         WHERE (
            artist.type NOT IN (1, 4) -- person, character
            OR
            artist.type IS NULL
         )
         AND link.link_type IN (
            847, -- teacher
            108, -- is person
            111, -- married
            110, -- sibling
            109, -- parent
            112  -- involved with
         )
     ),
     artists AS (
         SELECT id, name FROM
             (SELECT * FROM persons_entity0
                  UNION
              SELECT * FROM persons_entity1) AS persons
          EXCEPT
              SELECT * FROM 
                (SELECT * FROM groups_entity0
                  UNION
                 SELECT * FROM groups_entity1) AS groups
     )
SELECT artists.id AS artist_id, row_number() OVER (ORDER BY artists.name COLLATE musicbrainz, artists.id)
    FROM artists
    };
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
