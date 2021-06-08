package MusicBrainz::Server::Report::WorkSameTypeAsParent;
use Moose;

with 'MusicBrainz::Server::Report::WorkReport',
     'MusicBrainz::Server::Report::FilterForEditor::WorkID';

sub query {<<~'EOSQL'}
    SELECT DISTINCT w.id AS work_id,
           row_number() OVER (ORDER BY w.type, w.name COLLATE musicbrainz)
    FROM work w
    WHERE EXISTS (
        SELECT 1
        FROM l_work_work lww
        JOIN link l ON lww.link = l.id
        JOIN link_type lt ON l.link_type = lt.id
        JOIN work w2 ON w2.id = lww.entity0
        WHERE lww.entity1 = w.id
        AND lt.gid = 'ca8d3642-ce5f-49f8-91f2-125d72524e6a' --parts
        AND w2.type = w.type 
    )
    EOSQL

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
