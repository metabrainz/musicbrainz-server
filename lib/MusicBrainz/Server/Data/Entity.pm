package MusicBrainz::Server::Data::Entity;
use Moose;
use namespace::autoclean;

use Class::MOP;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw( placeholders );
use Carp qw( confess );

with 'MusicBrainz::Server::Data::Role::Sql';
with 'MusicBrainz::Server::Data::Role::NewFromRow';

sub _columns
{
    die("Not implemented");
}

sub _table
{
    die("Not implemented");
}

sub _column_mapping
{
    return {};
}

sub _get_by_keys
{
    my ($self, $key, @ids) = @_;
    return $self->_get_by_keys_append_sql($key, '', @ids);
}

sub _get_by_keys_append_sql
{
    my ($self, $key, $extra_sql, @ids) = @_;
    @ids = grep { defined && $_ } @ids;
    return {} unless @ids;
    my $query = "SELECT " . $self->_columns .
                " FROM " . $self->_table .
                " WHERE $key IN (" . placeholders(@ids) . ") " .
                $extra_sql;
    my $sql = $self->sql;
    $self->sql->select($query, @ids);
    my %result;
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my $obj = $self->_new_from_row($row);
        $result{$obj->id} = $obj;
    }
    $self->sql->finish;
    return \%result;
}

sub get_by_id
{
    my ($self, $id) = @_;
    my @result = values %{$self->get_by_ids($id)};
    return $result[0];
}

sub get_by_id_locked
{
    my ($self, $id) = @_;
    my @result = values %{$self->_get_by_keys_append_sql($self->_id_column, 'FOR UPDATE', $id)};
    return $result[0];
}

sub _id_column
{
    return 'id';
}

sub get_by_ids
{
    my ($self, @ids) = @_;
    @ids = grep defined, @ids;
    return {} unless @ids;

    return $self->_get_by_keys($self->_id_column, uniq(@ids));
}

sub _get_by_key
{
    my ($self, $key, $id, %options) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table;
    if (my $transform = $options{transform}) {
        $query .= " WHERE $transform($key) = $transform(?)";
    }
    else {
        $query .= " WHERE $key = ?";
    }

    return $self->_new_from_row(
        $self->sql->select_single_row_hash(
            $query, $id));
}

sub insert { confess "Not implemented" }
sub update { confess "Not implemented" }
sub delete { confess "Not implemented" }
sub merge  { confess "Not implemented" }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Entity

=head1 METHODS

=head2 get_by_id ($id)

Loads and returns a single Entity instance for the specified $id.

=head2 get_by_ids (@ids)

Loads and returns an id => object HASH reference of Entity instances
for the specified @ids.

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
