package MusicBrainz::Server::Report::EventSequenceNotInSeries;
use Moose;

with 'MusicBrainz::Server::Report::EventReport',
     'MusicBrainz::Server::Report::FilterForEditor::EventID';

sub query {
    q{
      SELECT DISTINCT
        e.id AS event_id,
        row_number() OVER (ORDER BY e.name)
      FROM
        event AS e
        LEFT JOIN l_event_series AS les ON e.id=les.entity0
        LEFT JOIN l_event_event AS lee ON e.id=lee.entity1
      WHERE (
          e.name ~ '\d+1st|\d+2nd|\d+rd|\d+[4-90]th'
          OR e.name ~ '\D\d+$'
          OR e.name ~ '第\d+回'
          OR e.name ~ '(?:no\.?|№)\s*\d+'
        )
        AND les.entity0 IS null
        AND lee.entity0 IS null
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
