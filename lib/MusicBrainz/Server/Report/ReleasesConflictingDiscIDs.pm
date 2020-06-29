package MusicBrainz::Server::Report::ReleasesConflictingDiscIDs;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub component_name { 'ReleasesConflictingDiscIds' }

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
                COUNT(medium) > 1
        ),
        toc AS (
            SELECT
                c.discid,
                c.leadout_offset,
                m.position,
                r.id,
                r.name,
                r.artist_credit
            FROM
                cdtoc AS c
                INNER JOIN mc ON c.id = mc.cdtoc
                INNER JOIN medium AS m ON m.id = mc.medium
                INNER JOIN release AS r ON r.id = m.release
        ),
        results AS (
            SELECT
                MAX(leadout_offset) - MIN(leadout_offset) AS maxdiff,
                id,
                position,
                name,
                artist_credit
            FROM
                toc
            GROUP BY
                id,
                position,
                name,
                artist_credit
            HAVING
                COUNT(discid) > 1
        )
        SELECT
            id AS release_id,
            position,
            row_number() OVER (ORDER BY artist_credit, name)
        FROM
            results
        WHERE
            (maxdiff / 75) > (3*60)  -- cutoff 3min
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 Jerome Roy

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
