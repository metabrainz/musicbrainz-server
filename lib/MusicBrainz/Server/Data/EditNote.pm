package MusicBrainz::Server::Data::EditNote;
use Moose;

use MusicBrainz::Server::Entity::EditNote;
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
);

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'edit_note';
}

sub _columns
{
    return 'id, editor, edit, text, notetime';
}

sub _column_mapping
{
    return {
        id => 'id',
        editor_id => 'editor',
        edit_id => 'edit',
        text => 'text',
        post_time => 'notetime',
    }
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::EditNote';
}

sub load
{
    my ($self, @edits) = @_;
    my %id_to_edit = map { $_->id => $_ } @edits;
    my @ids = keys %id_to_edit or return;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE edit IN (' . placeholders(@ids) . ')' .
                ' ORDER BY notetime ASC';
    my @notes = query_to_list($self->c->raw_dbh, sub {
            my $r = shift;
            my $note = $self->_new_from_row($r);
            my $edit = $id_to_edit{ $r->{edit} };
            $note->edit($edit);
            $edit->add_edit_note($note);
            return $note;
        }, $query, @ids);
}

sub insert
{
    my ($self, $edit_id, $note_hash) = @_;
    my $mapping = $self->_column_mapping;
    my %r = map {
        my $key = $mapping->{$_} || $_;
        $key => $note_hash->{$_};
    } keys %$note_hash;
    $r{edit} = $edit_id;
    my $sql = Sql->new($self->c->raw_dbh);
    $sql->AutoCommit(1) if !$sql->IsInTransaction;
    $sql->InsertRow('edit_note', \%r);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
