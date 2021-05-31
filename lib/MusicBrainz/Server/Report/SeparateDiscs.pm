package MusicBrainz::Server::Report::SeparateDiscs;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT DISTINCT ON (r.id)
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
            release r
            JOIN artist_credit ac ON r.artist_credit = ac.id
            JOIN release_group rg ON rg.id = r.release_group
            LEFT JOIN release_country ON r.id = release_country.release
        WHERE
            r.name ~ E'\\\\((disc [0-9]+|bonus disc)(: .*)?\\\\)'
            AND NOT (rg.type = 2 AND release_country.country = 221)
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
