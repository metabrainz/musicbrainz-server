package MusicBrainz::Server::Data::MediumFormat;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::MediumFormat;
use MusicBrainz::Server::Data::Utils qw( load_subobjects hash_to_row );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'medium_format' }

sub _table
{
    return 'medium_format';
}

sub _columns
{
    return 'id, gid, name, year, parent, child_order, has_discids, description';
}

sub _column_mapping {
    return {
        id              => 'id',
        gid             => 'gid',
        parent_id       => 'parent',
        child_order     => 'child_order',
        name            => 'name',
        description     => 'description',
        year            => 'year',
        has_discids     => 'has_discids',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::MediumFormat';
}

sub load
{
    my ($self, @media) = @_;
    load_subobjects($self, 'format', @media);
}

sub find_by_name
{
    my ($self, $name) = @_;
    my $row = $self->sql->select_single_row_hash(
        'SELECT ' . $self->_columns . ' FROM ' . $self->_table . '
          WHERE lower(name) = lower(?)', $name);
    return $row ? $self->_new_from_row($row) : undef;
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM medium WHERE format = ? LIMIT 1',
        $id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
