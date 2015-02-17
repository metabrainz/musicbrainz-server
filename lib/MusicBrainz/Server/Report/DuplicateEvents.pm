package MusicBrainz::Server::Report::DuplicateEvents;
use Moose;

with 'MusicBrainz::Server::Report::EventReport',
     'MusicBrainz::Server::Report::FilterForEditor::EventID';

sub query { "
WITH duplicates AS (
    SELECT event.begin_date_year AS begin_date_year, event.begin_date_month AS begin_date_month, 
           event.begin_date_day AS begin_date_day, l_event_place.entity1 AS entity1
     FROM event 
     JOIN l_event_place ON event.id = l_event_place.entity0
 GROUP BY l_event_place.entity1, event.begin_date_year, event.begin_date_month, event.begin_date_day
   HAVING count(*) > 1
) 

SELECT event.id AS event_id, 
       row_number() OVER ( ORDER BY musicbrainz_collate(place.name), event.begin_date_year, event.begin_date_month, event.begin_date_day )
  FROM event 
  JOIN l_event_place ON event.id = l_event_place.entity0 
  JOIN place ON place.id = l_event_place.entity1
  JOIN duplicates ON (
       duplicates.begin_date_year = event.begin_date_year 
       AND duplicates.begin_date_month = event.begin_date_month 
       AND duplicates.begin_date_day = event.begin_date_day 
       AND l_event_place.entity1 = duplicates.entity1
  )";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
