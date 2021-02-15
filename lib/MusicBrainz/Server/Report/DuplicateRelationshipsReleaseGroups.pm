package MusicBrainz::Server::Report::DuplicateRelationshipsReleaseGroups;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseGroupID';

sub query {
    "

SELECT q.entity AS release_group_id, row_number() OVER (ORDER BY release_group.name COLLATE musicbrainz) FROM (

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_artist_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_label_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_recording_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_group_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_release_group_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_release_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_group_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_group_url lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

) AS q
JOIN release_group on q.entity = release_group.id
GROUP BY q.entity, release_group.name

    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
