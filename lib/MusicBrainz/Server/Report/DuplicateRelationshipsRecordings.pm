package MusicBrainz::Server::Report::DuplicateRelationshipsRecordings;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    "

SELECT q.entity AS recording_id, row_number() OVER (ORDER BY musicbrainz_collate(track_name.name)) FROM (

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_artist_recording lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_label_recording lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION


    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_recording_recording lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_recording_recording lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_recording_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_recording_release lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_recording_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_recording_url lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

) AS q
JOIN recording on q.entity = recording.id
JOIN track_name on track_name.id = recording.name
GROUP BY q.entity, track_name.name

    ";
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
