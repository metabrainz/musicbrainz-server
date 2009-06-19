package MusicBrainz::Server::Data::Entity;
use Moose;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw( placeholders );
use UNIVERSAL::require;

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

sub _columns
{
    die("Not implemented");
}

sub _table
{
    die("Not implemented");
}

sub _entity_class
{
    die("Not implemented");
}

sub _column_mapping
{
    return {};
}


sub _attribute_mapping
{
    return {};
}

sub _dbh
{
    shift->c->dbh;
}

sub _new_from_row
{
    my ($self, $row, $prefix) = @_;
    my %info;
    my %mapping = %{$self->_column_mapping};
    my @attribs = %mapping ? keys %mapping : keys %{$row};
    $prefix ||= '';
    foreach my $attrib (@attribs) {
        my $column = $mapping{$attrib} || $attrib;
        my $val;
        if (ref($column) eq 'CODE') {
            $val = $column->($row, $prefix);
        }
        elsif (defined $row->{$prefix.$column}) {
            $val = $row->{$prefix.$column};
        }
        $info{$attrib} = $val if defined $val;
    }
    my $entity_class = $self->_entity_class;
    $entity_class->require;
    return $entity_class->new(%info);
}

sub _get_by_keys
{
    my ($self, $key, @ids) = @_;
    my $query = "SELECT " . $self->_columns . 
                " FROM " . $self->_table .
                " WHERE $key IN (" . placeholders(@ids) . ")";
    my $sql = Sql->new($self->_dbh);
    $sql->Select($query, @ids);
    my %result;
    while (1) {
        my $row = $sql->NextRowHashRef or last;
        my $obj = $self->_new_from_row($row);
        $result{$obj->id} = $obj;
    }
    $sql->Finish;
    return \%result;
}

sub get_by_id
{
    my ($self, $id) = @_;
    my @result = values %{$self->get_by_ids($id)};
    return $result[0];
}

sub _id_column
{
    return 'id';
}

sub get_by_ids
{
    my ($self, @ids) = @_;
    return $self->_get_by_keys($self->_id_column, uniq(@ids));
}

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
