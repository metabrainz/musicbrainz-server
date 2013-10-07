package MusicBrainz::Server::Report::ArtistsWithMultipleOccurancesInArtistCredits;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {
    "SELECT artist AS artist_id,
       row_number() OVER (ORDER BY musicbrainz_collate(artist_name.name))
     FROM (
       SELECT DISTINCT artist
       FROM artist_credit_name
       GROUP BY artist_credit, artist
       HAVING count(position) > 1
     ) q
    JOIN artist ON artist.id = q.artist
    JOIN artist_name ON artist_name.id = artist.name";

}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
