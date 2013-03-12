package MusicBrainz::Server::Report::DuplicateRelationshipsWorks;
use Moose;

with 'MusicBrainz::Server::Report::WorkReport',
     'MusicBrainz::Server::Report::FilterForEditor::WorkID';

sub query {
    "

SELECT q.entity AS work_id, row_number() OVER (ORDER BY musicbrainz_collate(work_name.name)) FROM (

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_artist_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_label_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_release_group_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_release_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_work_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION
    
    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_work_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_url_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

) AS q
JOIN work on q.entity = work.id
JOIN work_name on work_name.id = work.name
GROUP BY q.entity, work_name.name

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
