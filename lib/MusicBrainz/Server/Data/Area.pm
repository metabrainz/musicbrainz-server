package MusicBrainz::Server::Data::Area;

use Moose;
use namespace::autoclean;
use List::AllUtils qw( any );
use MusicBrainz::Server::Constants qw( $STATUS_OPEN $AREA_TYPE_COUNTRY );
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Entity::Area;
use MusicBrainz::Server::Entity::PartialDate;
use Readonly;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_partial_date
    placeholders
    object_to_ids
);

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'area' };
with 'MusicBrainz::Server::Data::Role::Name';
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'area' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'area' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'area' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'area' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'area' };

Readonly my @CODE_TYPES => qw( iso_3166_1 iso_3166_2 iso_3166_3 );

sub _table {
    return 'area';
}

sub _columns {
    return 'area.id, area.gid, area.name, area.comment, area.type, ' .
           'area.edits_pending, area.begin_date_year, area.begin_date_month, area.begin_date_day, ' .
           'area.end_date_year, area.end_date_month, area.end_date_day, area.ended, area.last_updated, ' .
           '(SELECT array_agg(code) FROM iso_3166_1 WHERE iso_3166_1.area = area.id) AS iso_3166_1, ' .
           '(SELECT array_agg(code) FROM iso_3166_2 WHERE iso_3166_2.area = area.id) AS iso_3166_2, ' .
           '(SELECT array_agg(code) FROM iso_3166_3 WHERE iso_3166_3.area = area.id) AS iso_3166_3';
}

sub _id_column
{
    return 'area.id';
}

sub _gid_redirect_table
{
    return 'area_gid_redirect';
}

sub _column_mapping
{
    return {
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        type_id => 'type',
        map {$_ => $_} qw( id gid name comment edits_pending last_updated ended iso_3166_1 iso_3166_2 iso_3166_3 )
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Area';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, ['area', 'begin_area', 'end_area', 'country'], @objs);
}

sub load_containment
{
    my ($self, @areas) = @_;
    # Define a map of area_type IDs to what property they correspond to
    # on an Entity::Area.
    my %type_parent_attribute = (
        $AREA_TYPE_COUNTRY => 'parent_country',
        2 => 'parent_subdivision',
        3 => 'parent_city',
    );

    # This helper function determines if a given area object should continue with loading
    # it won't include an object if all the containments are already loaded, or with undef.
    my $use_object = sub {
        my $obj = $_;
        return 0 if !defined $obj;
        my $obj_type = ( defined $obj->type ? $obj->type->id : $obj->type_id );
        # For each containment type, loading should continue
        # if the object type differs and the parent property is undefined
        # If all containments are loaded or match the object type, no loading needs to happen.
        return any { !defined($obj->{$type_parent_attribute{$_}}) && $obj_type != $_ } keys %type_parent_attribute;
    };
    my @objects_to_use = grep { $use_object->($_) } @areas;
    return unless @objects_to_use;
    my %obj_id_map = object_to_ids(@objects_to_use);
    my @all_ids = keys %obj_id_map;

    # See admin/sql/CreateViews.sql for a description of the area_containment view.
    # If more types are added to %type_parent_attribute the view should be updated.
    my $query = "SELECT descendant, parent, type, array_length(descendant_hierarchy,1) AS depth FROM area_containment WHERE descendant = any(?)";
    my $containment = $self->sql->select_list_of_hashes($query, \@all_ids);

    my @parent_ids = grep { defined } map { $_->{parent} } @$containment;

    # Having determined the IDs for all the parents, actually load them and attach to the
    # descendant objects.
    my $parent_objects = $self->get_by_ids(@parent_ids);
    for my $data (@$containment) {
        if (my $entities = $obj_id_map{$data->{descendant}}) {
            my $type = $type_parent_attribute{$data->{type}};
            my $type_depth = $type . '_depth';
            my $parent_obj = $parent_objects->{$data->{parent}};
            for my $entity (@$entities) {
                $entity->$type($parent_obj);
                $entity->$type_depth($data->{depth});
            }
        }
    }
}

sub _set_codes
{
    my ($self, $area, $type, $codes) = @_;
    $self->sql->do("DELETE FROM $type WHERE area = ?", $area);
    $self->sql->do(
        "INSERT INTO $type (area, code) VALUES " .
            join(', ', ("(?, ?)") x @$codes),
        map { $area, $_ } @$codes
   ) if @$codes;
}

sub set_all_codes
{
    my ($self, $area, $codes) = @_;
    for my $type (@CODE_TYPES) {
        $self->_set_codes($area, $type, $codes->{$type}) if exists $codes->{$type};
    }
}

sub insert
{
    my ($self, @areas) = @_;
    my $class = $self->_entity_class;
    my @created;
    for my $area (@areas)
    {
        my $row = $self->_hash_to_row($area);
        $row->{gid} = $area->{gid} || generate_gid();

        my $created = $class->new(
            name => $area->{name},
            id => $self->sql->insert_row('area', $row, 'id'),
            gid => $row->{gid}
        );

        $self->set_all_codes($created->id, $area);

        push @created, $created;
    }
    return @areas > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $area_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    $self->sql->update_row('area', $row, { id => $area_id }) if %$row;

    $self->set_all_codes($area_id, $update);

    return 1;
}

sub can_delete
{
    my ($self, $area_id) = @_;

    # Check no releases use the area
    my $refcount = $self->sql->select_single_column_array('select 1 from release_country WHERE country = ?', $area_id);
    return 0 if @$refcount != 0;

    # Check no artists use the area
    $refcount = $self->sql->select_single_column_array('select 1 from artist WHERE begin_area = ? OR end_area = ? OR area = ?', $area_id, $area_id, $area_id);
    return 0 if @$refcount != 0;

    # Check no labels use the area
    $refcount = $self->sql->select_single_column_array('select 1 from label WHERE area = ?', $area_id);
    return 0 if @$refcount != 0;

    return 1;
}

sub delete
{
    my ($self, @area_ids) = @_;

    $self->c->model('Relationship')->delete_entities('area', @area_ids);
    $self->annotation->delete(@area_ids);
    $self->alias->delete_entities(@area_ids);
    $self->tags->delete(@area_ids);
    $self->remove_gid_redirects(@area_ids);
    for my $code_table (@CODE_TYPES) {
        $self->sql->do("DELETE FROM $code_table WHERE area IN (" . placeholders(@area_ids) . ")", @area_ids);
    }
    $self->sql->do('DELETE FROM area WHERE id IN (' . placeholders(@area_ids) . ')', @area_ids);
    return 1;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('area', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('area', $new_id, @old_ids);
    $self->merge_codes($new_id, @old_ids);

    # If any of the areas being merged is a country, then the new area is a
    # country
    $self->sql->do(
        'INSERT INTO country_area (area)
         SELECT DISTINCT ?::int
         FROM country_area
         WHERE area = any(?) AND NOT EXISTS (
           SELECT TRUE from country_area WHERE area = ?
         )',
         $new_id, \@old_ids, $new_id
    );

    for my $update (
        [ artist => "area" ],
        [ artist => "begin_area" ],
        [ artist => "end_area" ],
        [ label => "area" ],
        [ place => "area" ],
        [ editor => "area" ],
        [ release_country => "country" ]
    ) {
        my ($table, $column) = @$update;
        $self->sql->do(
            "UPDATE $table SET $column = ? WHERE $column = any(?)",
            $new_id, \@old_ids
        );
    }

    $self->sql->do(
        'DELETE FROM country_area WHERE area = any(?)',
        \@old_ids
    );

    merge_table_attributes(
        $self->sql => (
            table => 'area',
            columns => [ qw( type ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    merge_partial_date(
        $self->sql => (
            table => 'area',
            field => $_,
            old_ids => \@old_ids,
            new_id => $new_id
        )
    ) for qw( begin_date end_date );

    $self->_delete_and_redirect_gids('area', $new_id, @old_ids);
    return 1;
}

sub merge_codes
{
    my ($self, $new_id, @old_ids) = @_;

    my @ids = ($new_id, @old_ids);

    for my $type (@CODE_TYPES) {
        # No work needed to keep codes distinct, as `code` is the PK
        # Simply move everything to the new area
        $self->sql->do('UPDATE ' . $type . ' SET area = ?
                  WHERE area IN ('.placeholders(@old_ids).')',
                  $new_id, @old_ids);
    }
}

sub _hash_to_row
{
    my ($self, $area) = @_;
    my $row = hash_to_row($area, {
        type => 'type_id',
        ended => 'ended',
        name => 'name',
        map { $_ => $_ } qw( comment )
    });

    add_partial_date_to_row($row, $area->{begin_date}, 'begin_date');
    add_partial_date_to_row($row, $area->{end_date}, 'end_date');

    return $row;
}

sub get_by_iso_3166_1 {
    shift->_get_by_iso('iso_3166_1', @_);
}

sub get_by_iso_3166_2 {
    shift->_get_by_iso('iso_3166_2', @_);
}

sub get_by_iso_3166_3 {
    shift->_get_by_iso('iso_3166_3', @_);
}

sub _get_by_iso {
    my ($self, $table, @codes) = @_;
    my $query = "SELECT ${table}s.codes AS iso_codes, " . $self->_columns .
        " FROM " . $self->_table . " WHERE ${table}s.codes && ?";

    my %ret = map { $_ => undef } @codes;
    for my $row (@{ $self->sql->select_list_of_hashes($query, \@codes) }) {
        for my $code (@codes) {
            if (any {$_ eq $code} @{ $row->{iso_codes} }) {
                $ret{$code} = $self->_new_from_row($row);
            }
        }
    }

    return \%ret;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
