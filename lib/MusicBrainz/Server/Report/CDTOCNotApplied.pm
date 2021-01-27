package MusicBrainz::Server::Report::CDTOCNotApplied;
use Moose;

with 'MusicBrainz::Server::Report::CDTOCReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub table { 'cd_toc_not_applied' }
sub component_name { 'CDTocNotApplied' }

sub query {
    q{
        WITH
        mc AS (
            SELECT
                UNNEST(ARRAY_AGG(cdtoc)) AS cdtoc,
                medium
            FROM
                medium_cdtoc
            GROUP BY
                medium
            HAVING
                COUNT(medium) = 1
        ),
        disc AS (
            SELECT DISTINCT
                c.id AS cdtoc_id,
                c.discid,
                mc.medium
            FROM
                cdtoc AS c
                JOIN mc ON c.id = mc.cdtoc
                JOIN track AS t ON t.medium = mc.medium
            WHERE
                t.length IS NULL
                AND NOT t.is_data_track
        )
        SELECT
            cdtoc_id,
            r.id AS release_id,
            row_number() OVER (ORDER BY r.name)
        FROM
            disc
            JOIN medium AS m ON m.id = disc.medium
            JOIN release AS r ON r.id = m.release
        ORDER BY
            r.name
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 Jerome Roy

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
