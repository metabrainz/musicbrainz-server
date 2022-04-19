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
         JOIN link_type ON link_type.id = link.link_type
         WHERE (artist.type NOT IN (2, 5, 6) OR artist.type IS NULL)
         AND link_type.name IN ('subgroup')),
       possible_groups_entity1 AS (
         SELECT artist.id, artist.name
         FROM artist
         JOIN l_artist_artist laa ON laa.entity1 = artist.id
         JOIN link ON link.id = laa.link
         JOIN link_type ON link_type.id = link.link_type
         WHERE (artist.type NOT IN (2, 5, 6) OR artist.type IS NULL)
         AND link_type.name IN ('member of band', 'collaboration', 'conductor position', 'artistic director', 'composer-in-residence', 'subgroup')),
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
