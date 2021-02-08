package MusicBrainz::Server::Report::DuplicateRelationshipsReleases;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "

SELECT q.entity AS release_id, row_number() OVER (ORDER BY release.name COLLATE musicbrainz) FROM (

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_artist_release lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_label_release lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_recording_release lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_release lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_release_release lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_url lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

) AS q
JOIN release on q.entity = release.id
GROUP BY q.entity, release.name

    ";
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
