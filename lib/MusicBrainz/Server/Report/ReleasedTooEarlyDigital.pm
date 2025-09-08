package MusicBrainz::Server::Report::ReleasedTooEarlyDigital;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {<<~'SQL'}
    SELECT DISTINCT ON (r.id)
        r.id AS release_id,
        row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
    FROM
        ( SELECT r.*
        FROM release r
        LEFT JOIN release_event events ON events.release = r.id
        JOIN medium m ON m.release = r.id
        WHERE m.format = 12 -- there is one digital medium
          AND date_year < 1999 -- first major label digital store
        ) r
    JOIN artist_credit ac ON r.artist_credit = ac.id
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

