package MusicBrainz::Server::Report::ArtistsThatMayBeGroups;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {<<~'SQL'}
  WITH possible_groups_entity0 AS (
         SELECT artist.id, artist.name
         FROM artist
         JOIN l_artist_artist laa ON laa.entity0 = artist.id
         JOIN link ON link.id = laa.link
         WHERE (
            artist.type NOT IN (2, 5, 6) -- group, orchestra, choir
            OR
            artist.type IS NULL
         )
         AND link.link_type IN (
            722, -- subgroup
            1079 -- renamed into
         )
       ),
       possible_groups_entity1 AS (
         SELECT artist.id, artist.name
         FROM artist
         JOIN l_artist_artist laa ON laa.entity1 = artist.id
         JOIN link ON link.id = laa.link
         JOIN link_type ON link_type.id = link.link_type
         WHERE (
            artist.type NOT IN (2, 5, 6) -- group, orchestra, choir
            OR
            artist.type IS NULL
         )
         AND link.link_type IN (
            103, -- member of band
            102, -- collaboration
            305, -- conductor position
            965, -- artistic director
            855, -- composer-in-residence
            722, -- subgroup
            1079 -- renamed into
         )
       )
  SELECT possible_groups.id AS artist_id,
         row_number() OVER (ORDER BY possible_groups.name COLLATE musicbrainz, possible_groups.id)
  FROM
    (SELECT * FROM possible_groups_entity0
        UNION
     SELECT * FROM possible_groups_entity1) AS possible_groups
  SQL

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
