package MusicBrainz::Server::Report::ReleasedTooEarlyForLabel;
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
            JOIN release_label rl ON rl.release = r.id
            JOIN label l ON rl.label = l.id
           WHERE events.date_year < l.begin_date_year
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

