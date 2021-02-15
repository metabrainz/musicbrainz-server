package MusicBrainz::Server::Report::MultipleDiscogsLinks;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
            l_release_url lru
            JOIN link ON lru.link = link.id
            JOIN link_type ON link.link_type = link_type.id
            JOIN release r ON lru.entity0 = r.id
            JOIN artist_credit ac ON r.artist_credit = ac.id
        WHERE
            link_type.name = 'discogs'
        GROUP BY
            r.id, r.name, ac.name, r.artist_credit
            HAVING COUNT(r.gid) > 1
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
