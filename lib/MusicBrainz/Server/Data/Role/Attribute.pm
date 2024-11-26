package MusicBrainz::Server::Data::Role::Attribute;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _build_columns
{
    return join q(, ), qw(
        id
        gid
        name
        parent
        child_order
        description
    );
}

has '_columns' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_columns',
);

sub _column_mapping {
    return {
        id              => 'id',
        gid             => 'gid',
        name            => 'name',
        parent_id       => 'parent',
        child_order     => 'child_order',
        description     => 'description',
    };
}

sub find_by_name {
    my ($self, $name) = @_;
    my $row = $self->sql->select_single_row_hash(
        'SELECT ' . $self->_columns . ' FROM ' . $self->_table . '
        WHERE lower(name) = lower(?)', $name);
    return $row ? $self->_new_from_row($row) : undef;
}

sub has_children {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM ' . $self->_table . ' WHERE parent = ? LIMIT 1',
        $id);
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
