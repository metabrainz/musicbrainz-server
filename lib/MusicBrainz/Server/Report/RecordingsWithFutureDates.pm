package MusicBrainz::Server::Report::RecordingsWithFutureDates;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    q{
        WITH
        link AS (
            SELECT
                l.id,
                l.begin_date_year AS begin,
                l.end_date_year AS end,
                lt.gid AS link_gid,
                lt.name AS link_name,
                lt.entity_type0,
                lt.entity_type1
            FROM
                link AS l
                JOIN link_type AS lt ON lt.id = l.link_type
            WHERE
                l.begin_date_year > date_part('year', now())
                OR l.end_date_year > date_part('year', now()) + 5
        )
        SELECT
            link.begin,
            link.end,
            link.link_gid,
            link.link_name,
            CASE
                WHEN entity_type0 = 'recording' THEN l_.entity0
                WHEN entity_type1 = 'recording' THEN l_.entity1
                ELSE NULL
            END AS recording_id,
            row_number() OVER (ORDER BY link.begin, link.end)
        FROM
            link
            JOIN (
                SELECT link, entity0, entity1 FROM l_area_recording
                UNION ALL
                SELECT link, entity0, entity1 FROM l_artist_recording
                UNION ALL
                SELECT link, entity0, entity1 FROM l_label_recording
                UNION ALL
                SELECT link, entity0, entity1 FROM l_place_recording
                UNION ALL
                SELECT link, entity0, entity1 FROM l_recording_recording
                UNION ALL
                SELECT link, entity0, entity1 FROM l_recording_work
            ) AS l_ ON l_.link = link.id
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 Jerome Roy

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
