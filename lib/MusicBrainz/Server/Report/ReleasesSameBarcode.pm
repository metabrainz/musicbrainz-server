package MusicBrainz::Server::Report::ReleasesSameBarcode;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub table { 'releases_same_barcode' }
sub component_name { 'ReleasesSameBarcode' }

sub query {
    q{
        SELECT DISTINCT ON (r.id)
            r.barcode AS barcode, r.id AS release_id, r.release_group AS release_group_id,
            row_number() OVER (ORDER BY r.barcode, r.name COLLATE musicbrainz)
        FROM
            release r
        WHERE r.barcode IS NOT NULL -- skip unset
        AND r.barcode != '' -- skip [none]
        AND r.status != 3 -- skip bootlegs
        AND EXISTS (
            SELECT 1 FROM release r2
                WHERE r.barcode = r2.barcode
                AND r2.status != 3 -- skip bootlegs
                AND r.release_group != r2.release_group
        )
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
