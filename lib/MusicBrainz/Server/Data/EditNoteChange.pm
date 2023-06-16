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
    return 'id, edit_note AS edit_note_id, change_editor AS editor_id, ' .
        'change_time, status, reason, old_note, new_note';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::EditNoteChange';
}

sub get_latest
{
    my ($self, @ids) = @_;
    my $query = 'SELECT DISTINCT ON (edit_note) ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE edit_note = any(?)' .
                ' ORDER BY edit_note, change_time DESC, id DESC';
    $self->query_to_list($query, [\@ids]);
}

sub load_latest
{
    my ($self, @edit_notes) = @_;
    my @changes = $self->get_latest(map { $_->id } @edit_notes);
    my %changes;
    for my $edit_note_change (@changes) {
        $changes{ $edit_note_change->edit_note_id } = $edit_note_change;
    }
    for my $edit_note (@edit_notes) {
        my $edit_note_change = $changes{ $edit_note->id } or next;
        $edit_note->latest_change($edit_note_change);
    }
}

sub get_history
{
    my ($self, $id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE edit_note = ?' .
                ' ORDER BY change_time DESC';
    $self->query_to_list_limited($query, [$id], $limit, $offset);
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

