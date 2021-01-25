package MusicBrainz::Server::Report::CDTOCDubiousLength;
use Moose;

with 'MusicBrainz::Server::Report::CDTOCReport';

sub table { 'cd_toc_dubious_length' }
sub component_name { 'CDTocDubiousLength' }

sub query {
    q{
        SELECT
            cdtoc.id AS cdtoc_id,
            medium_format.name AS format,
            cdtoc.leadout_offset / 75 AS length, -- seconds
            row_number() OVER (
                ORDER BY medium_format.name, cdtoc.leadout_offset DESC)
        FROM
            cdtoc
            JOIN medium_cdtoc ON medium_cdtoc.cdtoc = cdtoc.id
            JOIN medium ON medium_cdtoc.medium = medium.id
            JOIN medium_format ON medium.format = medium_format.id
        WHERE
            -- cutoff 88 minutes
            (leadout_offset > 75 * 60 * 88
                AND medium_format.name != 'CD-R')
            OR
            (medium_format.name = '8cm CD'
                AND leadout_offset > 75 * 60 * 30)
        ORDER BY
            medium_format.name,
            cdtoc.leadout_offset DESC
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
