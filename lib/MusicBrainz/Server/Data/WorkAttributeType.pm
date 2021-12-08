package MusicBrainz::Server::Data::WorkAttributeType;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );
use MusicBrainz::Server::Entity::WorkAttributeType;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'work_attribute_type' }

sub _table
{
    return 'work_attribute_type';
}

sub _columns
{
    return 'id, gid, name, free_text, parent, child_order, comment, description';
}

sub _column_mapping
{
    return {
        id          => 'id',
        gid         => 'gid',
        name        => 'name',
        comment     => 'comment',
        free_text   => 'free_text',
        parent_id   => 'parent',
        child_order => 'child_order',
        description => 'description',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::WorkAttributeType';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM work_attribute WHERE work_attribute_type = ? LIMIT 1',
        $id);
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
