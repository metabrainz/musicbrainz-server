package MusicBrainz::Server::Data::Place;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Entity::Place;
use MusicBrainz::Server::Entity::Coordinates;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    add_coordinates_to_row
    hash_to_row
    load_subobjects
    order_by
    merge_table_attributes
    merge_string_attributes
    merge_date_period
    placeholders
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Data::Utils::Uniqueness qw( assert_uniqueness_conserved );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'place' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => undef };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'place' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'place' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'place' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'place' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Area';
with 'MusicBrainz::Server::Data::Role::Collection';

sub _type { 'place' }

sub _columns
{
    return 'place.id, place.gid, place.name, place.type, place.address, place.area, place.coordinates[0] as coordinates_x, ' .
           'place.coordinates[1] as coordinates_y, place.edits_pending, place.begin_date_year, place.begin_date_month, place.begin_date_day, ' .
           'place.end_date_year, place.end_date_month, place.end_date_day, place.ended, place.comment, place.last_updated';
}

sub _id_column
{
    return 'place.id';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        type_id => 'type',
        address => 'address',
        area_id => 'area',
        coordinates =>  sub { MusicBrainz::Server::Entity::Coordinates->new_from_row(shift, shift() . 'coordinates') },
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        edits_pending => 'edits_pending',
        comment => 'comment',
        last_updated => 'last_updated',
        ended => 'ended'
    };
}

sub _area_cols
{
    return ['area']
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'place', @objs);
}

sub update
{
    my ($self, $place_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    $self->sql->update_row('place', $row, { id => $place_id }) if %$row;

    return 1;
}

sub can_delete {1}

sub delete
{
    my ($self, @place_ids) = @_;

    $self->c->model('Collection')->delete_entities('place', @place_ids);
    $self->c->model('Relationship')->delete_entities('place', @place_ids);
    $self->annotation->delete(@place_ids);
    $self->alias->delete_entities(@place_ids);
    $self->tags->delete(@place_ids);
    $self->remove_gid_redirects(@place_ids);
    $self->sql->do('DELETE FROM place WHERE id IN (' . placeholders(@place_ids) . ')', @place_ids);
    return 1;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('place', $new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('place', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('place', $new_id, \@old_ids);

    my @merge_options = ($self->sql => (
                           table => 'place',
                           old_ids => \@old_ids,
                           new_id => $new_id
                        ));

    merge_table_attributes(@merge_options, columns => [ qw( type area coordinates ) ]);
    merge_string_attributes(@merge_options, columns => [ qw( address ) ]);
    merge_date_period(@merge_options);

    $self->_delete_and_redirect_gids('place', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $place, $names) = @_;
    my $row = hash_to_row($place, {
        type => 'type_id',
        ended => 'ended',
        name => 'name',
        area => 'area_id',
        map { $_ => $_ } qw( comment address )
    });

    add_partial_date_to_row($row, $place->{begin_date}, 'begin_date');
    add_partial_date_to_row($row, $place->{end_date}, 'end_date');
    add_coordinates_to_row($row, $place->{coordinates}, 'coordinates')
        if exists $place->{coordinates};
    return $row;
}

sub is_empty {
    my ($self, $place_id) = @_;

    my $used_in_relationship = used_in_relationship($self->c, place => 'place_row.id');
    return $self->sql->select_single_value(<<EOSQL, $place_id, $STATUS_OPEN);
        SELECT TRUE
        FROM place place_row
        WHERE id = ?
        AND edits_pending = 0
        AND NOT (
          EXISTS (
            SELECT TRUE
            FROM edit_place JOIN edit ON edit_place.edit = edit.id
            WHERE status = ? AND place = place_row.id
          ) OR
          $used_in_relationship
        )
EOSQL
}

sub find_by_area {
    my ($self, $area_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN area ON place.area = area.id
                 WHERE area.id = ?
                 ORDER BY musicbrainz_collate(place.name), place.id";
    $self->query_to_list_limited($query, [$area_id], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;
    my $order_by = order_by($order, "name", {
        "name" => sub {
            return "musicbrainz_collate(name)"
        },
        "address" => sub {
            return "musicbrainz_collate(address), musicbrainz_collate(name)"
        },
        "type" => sub {
            return "type, musicbrainz_collate(name)"
        }
    });

    return $order_by
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013-2015 MetaBrainz Foundation

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
