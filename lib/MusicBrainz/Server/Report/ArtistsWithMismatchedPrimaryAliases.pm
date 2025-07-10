package MusicBrainz::Server::Report::ArtistsWithMismatchedPrimaryAliases;
use Moose;

with 'MusicBrainz::Server::Report::ArtistReport',
     'MusicBrainz::Server::Report::FilterForEditor::ArtistID';

sub query {<<~'SQL'}
    SELECT
        artist.id AS artist_id,
        row_number() OVER (ORDER BY artist.name COLLATE musicbrainz, artist.id)
     FROM artist
    WHERE EXISTS (
            SELECT 1
              FROM artist_alias
             WHERE artist_alias.artist = artist.id
               AND primary_for_locale IS TRUE
          )
      AND NOT EXISTS (
            SELECT 1
              FROM artist_alias
             WHERE artist_alias.artist = artist.id
               AND primary_for_locale IS TRUE
               AND name = artist.name
          )
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
