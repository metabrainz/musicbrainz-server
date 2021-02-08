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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
