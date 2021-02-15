package MusicBrainz::Server::Report::SomeFormatsUnset;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
            (
                SELECT release
                FROM medium
                WHERE format IS NULL
                INTERSECT
                SELECT release
                FROM medium
                WHERE format IS NOT NULL
            ) AS q
            JOIN release r ON r.id = q.release
            JOIN artist_credit ac ON r.artist_credit = ac.id
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

