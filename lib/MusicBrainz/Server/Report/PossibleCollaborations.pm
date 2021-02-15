package MusicBrainz::Server::Report::PossibleCollaborations;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    "
        SELECT artist.id AS artist_id, row_number() OVER ( ORDER BY artist.name COLLATE musicbrainz )
        FROM
            artist
        WHERE
            (artist.name ~ '&' OR artist.name ~ E'\\\\yvs\\\\.' OR artist.name ~ E'\\\\yfeat\\\\.')
            AND NOT EXISTS (
                SELECT TRUE 
                FROM 
                    l_artist_artist
                    JOIN link ON link.id=l_artist_artist.link
                    JOIN link_type ON link_type.id=link.link_type
                WHERE 
                    l_artist_artist.entity1=artist.id
                    AND link_type.name IN
                      ('collaboration', 'conductor position', 'founder', 'member of band', 'subgroup')            )
        GROUP BY artist.id, artist.name
    "
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

