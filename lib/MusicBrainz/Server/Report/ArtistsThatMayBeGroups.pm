package MusicBrainz::Server::Report::ArtistsThatMayBeGroups;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    q{SELECT DISTINCT ON (artist.id) artist.id AS artist_id,
       row_number() OVER (ORDER BY artist.name COLLATE musicbrainz, artist.id)
     FROM artist
     JOIN l_artist_artist ON l_artist_artist.entity1=artist.id
     JOIN link ON link.id=l_artist_artist.link
     JOIN link_type ON link_type.id=link.link_type
     WHERE (artist.type NOT IN (2, 5, 6) OR artist.type IS NULL)
       AND link_type.name IN ('collaboration', 'member of band', 'conductor position')}
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
