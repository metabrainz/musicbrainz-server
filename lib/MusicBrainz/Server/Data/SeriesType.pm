package MusicBrainz::Server::Data::SeriesType;
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache',
     'MusicBrainz::Server::Data::Role::OptionsTree',
     'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'series_type' }

sub _table {
    return 'series_type';
}

sub _build_columns
{
    return join q(, ), qw(
        id
        gid
        name
        entity_type
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
        id                  => 'id',
        gid                 => 'gid',
        name                => 'name',
        item_entity_type    => 'entity_type',
        parent_id           => 'parent',
        child_order         => 'child_order',
        description         => 'description',
    };
}

sub _entity_class {
    return 'MusicBrainz::Server::Entity::SeriesType';
}

sub load {
    my ($self, @objs) = @_;
    load_subobjects($self, 'type', @objs);
}

# Needed for indexed search results, which lack id and entity_type
sub load_entity_type_from_gid {
    my ($self, @series) = @_;

    my @type_gids = map { $_->{type}->{gid} } @series;
    return () unless @type_gids;

    my $query = 'SELECT gid, entity_type FROM series_type WHERE gid = any(?)';
    my %map = map { $_->[0] => $_->[1] }
        @{ $self->sql->select_list_of_lists($query, \@type_gids) };

    for my $series (@series) {
        $series->type->entity_type($map{$series->type->gid})
            if exists $map{$series->type->gid};
    }
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM series WHERE type = ? LIMIT 1',
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
