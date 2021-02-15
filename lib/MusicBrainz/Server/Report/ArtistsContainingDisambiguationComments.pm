package MusicBrainz::Server::Report::ArtistsContainingDisambiguationComments;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    "SELECT artist.id AS artist_id,
       row_number() OVER (ORDER BY artist.name COLLATE musicbrainz)
     FROM artist
     WHERE (name LIKE '%(%' OR name LIKE '%)%')
       AND name NOT LIKE '(%'";
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
