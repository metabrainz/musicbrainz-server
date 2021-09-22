package MusicBrainz::Server::Report::DuplicateEvents;
use Moose;

with 'MusicBrainz::Server::Report::EventReport',
     'MusicBrainz::Server::Report::FilterForEditor::EventID';

sub query { q{
WITH duplicates AS (
    SELECT event.begin_date_year AS begin_date_year, event.begin_date_month AS begin_date_month, 
           event.begin_date_day AS begin_date_day, l_event_place.entity1 AS entity1
     FROM event 
     JOIN l_event_place ON event.id = l_event_place.entity0
 GROUP BY l_event_place.entity1, event.begin_date_year, event.begin_date_month, event.begin_date_day
   HAVING count(*) > 1
) 

SELECT event.id AS event_id, 
       row_number() OVER ( ORDER BY place.name COLLATE musicbrainz, event.begin_date_year, event.begin_date_month, event.begin_date_day )
  FROM event 
  JOIN l_event_place ON event.id = l_event_place.entity0 
  JOIN place ON place.id = l_event_place.entity1
  JOIN duplicates ON (
       duplicates.begin_date_year = event.begin_date_year 
       AND duplicates.begin_date_month = event.begin_date_month 
       AND duplicates.begin_date_day = event.begin_date_day 
       AND l_event_place.entity1 = duplicates.entity1
  )
  WHERE EXISTS (
    SELECT TRUE
    FROM event e2
    JOIN l_event_place lep2 ON e2.id = lep2.entity0 
    JOIN place p2 ON p2.id = lep2.entity1
    WHERE e2.begin_date_year = event.begin_date_year 
        AND e2.begin_date_month = event.begin_date_month 
        AND e2.begin_date_day = event.begin_date_day 
        AND lep2.entity1 = duplicates.entity1
        AND e2.comment = ''
  )
};
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
