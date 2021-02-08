package MusicBrainz::Server::Report::CoverArtRelationships;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::URLReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

sub query {
    "
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM release r
            JOIN l_release_url l_ru ON r.id = l_ru.entity0
            JOIN link l ON l_ru.link = l.id
            JOIN artist_credit ac on ac.id = r.artist_credit
        WHERE l.link_type = 78 AND l_ru.edits_pending = 0
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
