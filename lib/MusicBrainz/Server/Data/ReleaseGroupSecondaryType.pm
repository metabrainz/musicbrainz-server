package MusicBrainz::Server::Data::ReleaseGroupSecondaryType;
use Moose;
use namespace::autoclean;

use List::AllUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw( object_to_ids );
use MusicBrainz::Server::Entity::ReleaseGroupSecondaryType;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll' => { order_by => [ 'name'] };
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'release_group_secondary_type' }

sub _table
{
    return 'release_group_secondary_type';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ReleaseGroupSecondaryType';
}

sub load_for_release_groups {
    my ($self, @release_groups) = @_;
    my %rg_by_id = object_to_ids(uniq @release_groups);
    my @ids = keys %rg_by_id;
    my @rows = @{
        $self->c->sql->select_list_of_hashes(
            'SELECT release_group, id, name
             FROM release_group_secondary_type_join
             JOIN release_group_secondary_type ON id = secondary_type
             WHERE release_group = any(?)',
            \@ids
        )
    };

    my $types_by_rg = {};
    for my $type (@rows) {
        push @{ $types_by_rg->{$type->{release_group}} }, $type;
    }

    for my $rgs (values %rg_by_id) {
        for my $rg (@$rgs) {
            $rg->secondary_types([
                map {
                    MusicBrainz::Server::Entity::ReleaseGroupSecondaryType->new($_)
                } @{ $types_by_rg->{$rg->id} }
            ]);
        }
    }
}

sub set_types {
    my ($self, $group_id, $types) = @_;
    my @types = uniq @$types;
    $self->sql->do('DELETE FROM release_group_secondary_type_join WHERE release_group = ?',
                   $group_id);
    $self->sql->do('INSERT INTO release_group_secondary_type_join (release_group, secondary_type)
                    VALUES ' . join(', ', ('(?, ?)') x @types),
                   map { $group_id, $_ } @types)
        if @types;
}

sub merge_entities
{
    my ($self, $new_id, @old_ids) = @_;

    $self->sql->do(
        "DELETE FROM release_group_secondary_type_join " .
        "WHERE release_group = any(?)", \@old_ids );
}

sub delete_entities {
    my ($self, @ids) = @_;

    $self->sql->do(
        "DELETE FROM release_group_secondary_type_join " .
        "WHERE release_group = any(?) ", \@ids);
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM release_group_secondary_type_join WHERE secondary_type = ? LIMIT 1',
        $id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
