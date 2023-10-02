package MusicBrainz::Server::Report::ShowNotesButNotBroadcast;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';


sub query {<<~'SQL'}
        SELECT r.id AS release_id,
               row_number() OVER (ORDER BY r.name COLLATE musicbrainz, rg.name COLLATE musicbrainz)
          FROM release r
          JOIN release_group rg ON r.release_group = rg.id
         WHERE rg.type != 12 -- not Broadcast
    AND EXISTS (
                SELECT TRUE
                  FROM l_release_url lru
                  JOIN link ON lru.link = link.id
                 WHERE lru.entity0 = r.id 
                   AND link.link_type = 729 -- show notes
               )
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
