package MusicBrainz::Server::Data::MediumFormat;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::MediumFormat;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache',
     'MusicBrainz::Server::Data::Role::OptionsTree',
     'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'medium_format' }

sub _table
{
    return 'medium_format';
}

sub _build_columns
{
    return join q(, ), qw(
        id
        gid
        name
        year
        parent
        child_order
        has_discids
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

sub find_by_ids
{
    my ($self, $ids) = @_;

    my @formats = sort { $a->name cmp $b->name }
                  values %{ $self->get_by_ids(@$ids) };
    return \@formats;
}

sub find_by_name
{
    my ($self, $name) = @_;
    my $row = $self->sql->select_single_row_hash(
        'SELECT ' . $self->_columns . ' FROM ' . $self->_table . '
          WHERE lower(name) = lower(?)', $name);
    return $row ? $self->_new_from_row($row) : undef;
}

sub find_by_release_artist
{
    my ($self, $artist_id) = @_;

    my $query = 'SELECT DISTINCT m.format
                 FROM release rel
                 JOIN medium m
                     ON m.release = rel.id
                 JOIN artist_credit_name acn
                     ON acn.artist_credit = rel.artist_credit
                 WHERE acn.artist = ?';
    my $ids = $self->sql->select_single_column_array($query, $artist_id);
    return $self->find_by_ids($ids);
}

sub find_by_release_label
{
    my ($self, $label_id) = @_;

    my $query = 'SELECT DISTINCT m.format
                 FROM release rel
                 JOIN medium m
                     ON m.release = rel.id
                 JOIN release_label rl
                     ON rl.release = rel.id
                 WHERE rl.label = ?';
    my $ids = $self->sql->select_single_column_array($query, $label_id);
    return $self->find_by_ids($ids);
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
