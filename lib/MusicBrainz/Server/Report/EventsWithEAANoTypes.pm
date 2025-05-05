package MusicBrainz::Server::Report::EventsWithEAANoTypes;
use Moose;

with 'MusicBrainz::Server::Report::EventReport',
     'MusicBrainz::Server::Report::FilterForEditor::EventID';

sub component_name { 'EventsWithEaaNoTypes' }
sub query {<<~'SQL'}
    SELECT
        e.id AS event_id,
        row_number() OVER (ORDER BY e.name COLLATE musicbrainz)
    FROM (
        SELECT DISTINCT e.*
        FROM event e
        WHERE EXISTS (
            SELECT 1
              FROM event_art_archive.event_art
             WHERE event_art.event = e.id
        )
        AND NOT EXISTS (
            SELECT 1
              FROM event_art_archive.event_art_type
              JOIN event_art_archive.event_art ON event_art_type.id = event_art.id
             WHERE event_art.event = e.id
        )
    ) e
    SQL

sub table { 'events_with_eaa_no_types' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
