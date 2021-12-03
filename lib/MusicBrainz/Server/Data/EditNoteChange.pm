package MusicBrainz::Server::Data::EditNoteChange;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::EditNoteChange;

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'edit_note_change';
}

sub _columns
{
    return 'id, change_editor AS editor_id, change_time, status, reason';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::EditNoteChange';
}

sub get_latest
{
    my ($self, $id) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE edit_note = ?' .
                ' ORDER BY change_time DESC, id DESC LIMIT 1';
    my $row = $self->sql->select_single_row_hash($query, $id)
        or return undef;
    return $self->_new_from_row($row);
}

sub load_latest
{
    my ($self, @edit_notes) = @_;
    for my $edit_note (@edit_notes) {
        my $edit_note_change = $self->get_latest($edit_note->id) or next;
        $edit_note->latest_change($edit_note_change);
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

