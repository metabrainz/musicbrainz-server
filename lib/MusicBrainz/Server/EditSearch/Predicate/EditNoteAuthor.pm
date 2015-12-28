package MusicBrainz::Server::EditSearch::Predicate::EditNoteAuthor;

use Moose;
use MusicBrainz::Server::Validation qw( is_database_row_id );

with 'MusicBrainz::Server::EditSearch::Predicate';

sub operator_cardinality_map {
    return (
        '=' => 1,
        '!=' => 1,
    );
};

sub valid {
    my ($self) = @_;

    my @args = $self->arguments;
    return scalar(@args) == 1 && is_database_row_id($args[0]);
}

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql = 'EXISTS (
        SELECT TRUE FROM edit_note
         WHERE edit_note.editor = ?
           AND edit_note.edit = edit.id
    )';

    if ($self->operator eq '!=') {
        $sql = 'NOT ' . $sql;
    }

    $query->add_where([$sql, [$self->arguments]]);
}

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
