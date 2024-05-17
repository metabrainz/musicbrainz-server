package MusicBrainz::Server::Report::KaraokeRecordingsMarkedInstrumental;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport';

sub query {<<~'SQL'}
      SELECT
          DISTINCT r.id AS recording_id,
          row_number() OVER (ORDER BY r.artist_credit, r.name)
      FROM recording r
      JOIN artist_credit_name acn ON acn.artist_credit = r.artist_credit
      WHERE EXISTS (
          SELECT 1
          FROM l_recording_recording lrr
          JOIN link l ON lrr.link = l.id
          JOIN link_type lt ON l.link_type = lt.id
          WHERE lrr.entity1 = r.id
          AND lt.gid = '39a08d0e-26e4-44fb-ae19-906f5fe9435d' --karaoke
      )
      AND EXISTS (
          SELECT 1
          FROM l_recording_work lrw
          JOIN link l ON lrw.link = l.id
          JOIN link_attribute la ON la.link = l.id
          JOIN link_attribute_type lat ON lat.id = la.attribute_type
          WHERE lrw.entity0 = r.id
          AND lat.gid = 'c031ed4f-c9bb-4394-8cf5-e8ce4db512ae' --instrumental
      )
      SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
