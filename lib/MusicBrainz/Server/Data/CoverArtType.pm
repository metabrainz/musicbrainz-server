package MusicBrainz::Server::Data::CoverArtType;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::CoverArtType;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects object_to_ids placeholders );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'cover_art_type' }

sub _table
{
    return 'cover_art_archive.art_type';
}

sub _columns
{
    return 'art_type.id, art_type.gid, art_type.name, art_type.parent AS parent_id,
            art_type.child_order, art_type.description';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CoverArtType';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
}

sub get_by_name
{
    my ($self, @names) = @_;

    my %types_by_name = map { $_->name => $_ } $self->get_all();

    return map { $types_by_name{$_} } @names;
}

sub find_by_cover_art_ids
{
    my ($self, @ids) = @_;
    return () unless @ids;

    my $query = 'SELECT cover_art_type.id AS cover_art_id, ' . $self->_columns . ' ' .
        'FROM ' . $self->_table . ' ' .
        'JOIN cover_art_archive.cover_art_type ' .
        'ON cover_art_type.type_id = art_type.id ' .
        'WHERE cover_art_type.id IN (' . placeholders(@ids) . ')';

    my %map;
    for my $row (@{ $self->sql->select_list_of_hashes($query, @ids) }) {
        $map{ $row->{cover_art_id} } ||= [];
        push @{ $map{ $row->{cover_art_id} } }, $self->_new_from_row($row);
    }

    return %map;
}

sub load_for
{
    my ($self, @objects) = @_;
    my %obj_id_map = object_to_ids(@objects);

    my %id_types_map = $self->find_by_cover_art_ids(keys %obj_id_map);

    while (my ($cover_art_id, $types) = each %id_types_map)
    {
        $obj_id_map{$cover_art_id}[0]->cover_art_types($types);
    }
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM cover_art_archive.cover_art_type WHERE type_id = ? LIMIT 1',
        $id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
