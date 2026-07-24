package MusicBrainz::Server::Report::RedundantWriterRelationships;
use Moose;

with 'MusicBrainz::Server::Report::WorkReport',
     'MusicBrainz::Server::Report::FilterForEditor::WorkID';

sub query {<<~'SQL'}
    SELECT DISTINCT w.id AS work_id,
           row_number() OVER (ORDER BY w.type, w.name COLLATE musicbrainz)
    FROM work w
    JOIN l_artist_work law ON law.entity1 = w.id
    JOIN link l ON l.id = law.link
    JOIN link_type lt ON l.link_type = lt.id
    WHERE lt.gid = 'a255bca1-b157-4518-9108-7b147dc3fc68' --writer
    AND EXISTS (
        SELECT 1
        FROM l_artist_work law2
        JOIN link l2 ON law2.link = l2.id
        JOIN link_type lt2 ON l2.link_type = lt2.id
        WHERE law2.entity1 = w.id
        AND law2.entity0 = law.entity0
        AND (
            lt2.gid = 'd59d99ea-23d4-4a80-b066-edca32ee158f' --composer
            OR
            lt2.gid = '3e48faba-ec01-47fd-8e89-30e81161661c' --lyricist
        )
    )
    SQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
