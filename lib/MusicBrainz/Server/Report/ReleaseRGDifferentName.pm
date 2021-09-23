package MusicBrainz::Server::Report::ReleaseRGDifferentName;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub table { 'release_rg_different_name' }
sub component_name { 'ReleaseRgDifferentName' }

sub query {
    '
        SELECT
            r.id AS release_id, rg.id AS release_group_id,
            row_number() OVER (ORDER BY r.name COLLATE musicbrainz, rg.name COLLATE musicbrainz)
        FROM
            release r
            JOIN release_group rg 
            ON r.release_group = rg.id
            JOIN release_group_meta rgm
            ON rgm.id = rg.id
        WHERE rgm.release_count = 1
          AND r.name != rg.name
    '
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
