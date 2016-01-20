package MusicBrainz::Server::Data::WorkAttributeTypeAllowedValue;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );
use aliased 'MusicBrainz::Server::Entity::WorkAttributeTypeAllowedValue';

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::SelectAll';

sub _type { 'work_attribute_type_allowed_value' }

sub _table
{
    return 'work_attribute_type_allowed_value';
}

sub _columns
{
    return 'id, work_attribute_type, value, parent, child_order, description';
}

sub _column_mapping
{
    return {
        id                      => 'id',
        work_attribute_type_id  => 'work_attribute_type',
        value                   => 'value',
        parent_id               => 'parent',
        child_order             => 'child_order',
        description             => 'description',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::WorkAttributeTypeAllowedValue';
}

sub load_for_work_attribute_types
{
    my ($self, @wats) = @_;

    @wats = grep { scalar $_->all_allowed_values == 0 } @wats;
    return unless scalar @wats;

    my @wat_ids = map { $_->id } @wats;
    my %wats_map = map { $_->id => $_ } @wats;

    my $allowed_values = $self->sql->select_list_of_hashes(
        'SELECT ' . $self->_columns . ' FROM ' . $self->_table . '
          WHERE work_attribute_type = any(?)',
        \@wat_ids
    );

    my $mapping = $self->_column_mapping;
    my @attrs = keys %$mapping;

    for my $row (@$allowed_values) {
        $row->{$_} = delete $row->{$mapping->{$_}} for @attrs;

        $wats_map{$row->{work_attribute_type_id}}
            ->add_allowed_value(WorkAttributeTypeAllowedValue->new($row));
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
