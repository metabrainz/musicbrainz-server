package MusicBrainz::Server::Data::WorkAttributeTypeAllowedValue;

use Moose;
use namespace::autoclean;
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
    return 'id, gid, work_attribute_type, value, parent, child_order, description';
}

sub _column_mapping
{
    return {
        id                      => 'id',
        gid                     => 'gid',
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
