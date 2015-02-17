package MusicBrainz::Server::Report::ArtistsWithNoSubscribers;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport';

sub query {
    "SELECT artist.id AS artist_id,
       row_number() OVER (ORDER BY count(distinct release_group.id) DESC, artist.edits_pending DESC)
     FROM artist
     LEFT JOIN editor_subscribe_artist ON artist.id=editor_subscribe_artist.artist
     JOIN artist_credit_name ON artist.id = artist_credit_name.artist
     LEFT JOIN release_group ON release_group.artist_credit = artist_credit_name.artist_credit
     WHERE editor_subscribe_artist.editor IS NULL GROUP BY artist_id";
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
