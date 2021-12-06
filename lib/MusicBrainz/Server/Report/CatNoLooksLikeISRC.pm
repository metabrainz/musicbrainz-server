package MusicBrainz::Server::Report::CatNoLooksLikeISRC;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub component_name { 'CatNoLooksLikeIsrc' }

sub query {
    q{
        SELECT
            r.id AS release_id, rl.catalog_number,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
            release_label rl
            JOIN release r
            ON r.id = rl.release
            JOIN artist_credit ac ON r.artist_credit = ac.id
        WHERE rl.catalog_number ~ '^[A-Z]{2}-?[A-Z0-9]{3}-?[0-9]{2}-?[0-9]{5}$'
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

