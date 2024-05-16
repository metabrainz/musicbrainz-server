package MusicBrainz::Server::Report::VideoRelationshipsOnNonVideos;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {<<~'SQL'}
  SELECT DISTINCT r.id AS recording_id,
         row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
    FROM recording r
    JOIN artist_credit ac ON r.artist_credit = ac.id
   WHERE r.video IS FALSE
     AND EXISTS (
          SELECT TRUE
            FROM l_artist_recording lar
            JOIN link ON lar.link = link.id
           WHERE lar.entity1 = r.id 
             AND link.link_type IN (
                  125,  -- graphic design
                  858,  -- video appearance
                  962,  -- video director
                  1230, -- choreographer
                  1241, -- artwork
                  1242, -- design
                  1244, -- illustration
                  1245  -- cinematographer
                 )
         )
  SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
