package MusicBrainz::Server::EditSearch::Predicate::EditNoteAuthor;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::EditSearch::Predicate::Role::User' => {
        template_clause => 'EXISTS (
            SELECT TRUE FROM edit_note
             WHERE ROLE_CLAUSE(edit_note.editor)
               AND edit_note.edit = edit.id
        )',
     },
     'MusicBrainz::Server::EditSearch::Predicate';

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
