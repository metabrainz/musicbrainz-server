package MusicBrainz::Server::Data::Subscription;

use Moose;
use Sql;
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

has 'table' => (
    is => 'ro',
    isa => 'Str'
);

has 'column' => (
    is => 'ro',
    isa => 'Str'
);

sub subscribe
{
    my ($self, $user_id, $id) = @_;

    my $table = $self->table;
    my $column = $self->column;

    my $sql = Sql->new($self->c->dbh);
    Sql::RunInTransaction(sub {

        return if $sql->SelectSingleValue("
            SELECT id FROM $table WHERE editor = ? AND $column = ?",
            $user_id, $id);

        my $max_edit_id = $self->c->model('Edit')->get_max_id() || 0;
        $sql->Do("INSERT INTO $table (editor, $column, lasteditsent)
                  VALUES (?, ?, ?)", $user_id, $id, $max_edit_id);

    }, $sql);
}

sub unsubscribe
{
    my ($self, $user_id, $id) = @_;

    my $table = $self->table;
    my $column = $self->column;

    my $sql = Sql->new($self->c->dbh);
    Sql::RunInTransaction(sub {

        $sql->Do("
            DELETE FROM $table WHERE editor = ? AND $column = ?",
            $user_id, $id);

    }, $sql);
}

sub check_subscription
{
    my ($self, $user_id, $id) = @_;

    my $table = $self->table;
    my $column = $self->column;

    my $sql = Sql->new($self->c->dbh);
    return $sql->SelectSingleValue("
        SELECT 1 FROM $table
        WHERE editor = ? AND $column = ?",
        $user_id, $id) ? 1 : 0;
}

sub find_subscribed_editors
{
    my ($self, $entity_id) = @_;

    require MusicBrainz::Server::Data::Editor;
    my $table = $self->table;
    my $column = $self->column;
    my $query = "
        SELECT " . MusicBrainz::Server::Data::Editor->_columns . "
        FROM " . MusicBrainz::Server::Data::Editor->_table . "
            JOIN $table s ON editor.id = s.editor
        WHERE s.$column = ?
        ORDER BY editor.name, editor.id";

    return query_to_list(
        $self->c->dbh, sub { MusicBrainz::Server::Data::Editor->_new_from_row(@_) },
        $query, $entity_id);
}

sub get_subscribed_editor_count
{
    my ($self, $entity_id) = @_;

    my $table = $self->table;
    my $column = $self->column;
    my $sql = Sql->new($self->c->dbh);

    return $sql->SelectSingleValue("SELECT count(*) FROM $table
                                    WHERE $column = ?", $entity_id);
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    my $table = $self->table;
    my $column = $self->column;
    my $sql = Sql->new($self->c->dbh);

    # Remove duplicate joins
    $sql->Do("DELETE FROM $table
              WHERE $column IN (".placeholders(@old_ids).") AND
                  editor IN (SELECT editor FROM $table WHERE $column = ?)",
              @old_ids, $new_id);

    # Move all remaining joins to the new entity
    $sql->Do("UPDATE $table SET $column = ?
              WHERE $column IN (".placeholders(@old_ids).")",
              $new_id, @old_ids);
}

sub delete
{
    my ($self, @ids) = @_;

    my $table = $self->table;
    my $column = $self->column;

    my $sql = Sql->new($self->c->dbh);
    $sql->Do("DELETE FROM $table
              WHERE $column IN (".placeholders(@ids).")", @ids);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
