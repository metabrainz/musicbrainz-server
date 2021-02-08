package MusicBrainz::Server::Data::ReleaseGroupType;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::ReleaseGroupType;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'release_group_type' }

sub _table
{
    return 'release_group_primary_type';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ReleaseGroupType';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'primary_type', @objs);
    $self->c->model('ReleaseGroupSecondaryType')->load_for_release_groups(@objs);
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
        'SELECT 1 FROM release_group WHERE type = ? LIMIT 1',
        $id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
