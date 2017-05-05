package MusicBrainz::Server::EditSearch::Predicate::Editor;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::EditSearch::Predicate::Role::User' => {
    template_clause => 'ROLE_CLAUSE(edit.editor)'
};
with 'MusicBrainz::Server::EditSearch::Predicate';

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
