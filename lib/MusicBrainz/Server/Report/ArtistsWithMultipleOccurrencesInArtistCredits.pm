package MusicBrainz::Server::Report::ArtistsWithMultipleOccurrencesInArtistCredits;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    "SELECT artist AS artist_id,
       row_number() OVER (ORDER BY artist.name COLLATE musicbrainz)
     FROM (
       SELECT DISTINCT artist
       FROM artist_credit_name
       GROUP BY artist_credit, artist
       HAVING count(position) > 1
     ) q
    JOIN artist ON artist.id = q.artist";

}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
