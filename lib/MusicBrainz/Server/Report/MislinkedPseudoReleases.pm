package MusicBrainz::Server::Report::MislinkedPseudoReleases;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {<<~'SQL'}
    SELECT r.id AS release_id,
           row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
    FROM release r
        JOIN l_release_release lrr ON r.id = lrr.entity0
        JOIN link l ON l.id = lrr.link
        JOIN link_type lt ON l.link_type = lt.id
        JOIN artist_credit ac ON r.artist_credit = ac.id
    WHERE lt.gid = 'fc399d47-23a7-4c28-bfcf-0607a562b644' --transl(iter)ation
    AND r.status = 4 --pseudo-release
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
