package MusicBrainz::Server::Data::Area;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
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
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => undef };
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'area' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'area' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'area' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'area' };

Readonly my @CODE_TYPES => qw( iso_3166_1 iso_3166_2 iso_3166_3 );

sub _table
{
    return 'area';
}

sub _columns
{
    return 'area.id, gid, area.name, area.sort_name, area.type, ' .
           'area.edits_pending, begin_date_year, begin_date_month, begin_date_day, ' .
           'end_date_year, end_date_month, end_date_day, ended, area.last_updated';
}

sub browse_column { 'name' }

sub _id_column
{
    return 'area.id';
}

sub _gid_redirect_table
{
    return 'area_gid_redirect';
}

sub _table_join_name {}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        sort_name => 'sort_name',
        type_id => 'type',
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        edits_pending => 'edits_pending',
        last_updated => 'last_updated',
        ended => 'ended'
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

sub load_codes
{
    my ($self, @objs) = @_;

    my %obj_id_map = object_to_ids(grep { defined } @objs);
    my @all_ids = keys %obj_id_map;

    my $codes = $self->sql->select_list_of_hashes(
        "SELECT type, area, code
           FROM (SELECT 'iso_3166_1' AS type, code, area FROM iso_3166_1 UNION ALL
                 SELECT 'iso_3166_2' AS type, code, area FROM iso_3166_2 UNION ALL
                 SELECT 'iso_3166_3' AS type, code, area FROM iso_3166_3) s WHERE area = any(?)",
        [ @all_ids ]
    );

    for my $code (@$codes) {
        if (my $entities = $obj_id_map{ $code->{area} }) {
            my $all = $code->{type} . '_codes';
            my $add = 'add_' . $code->{type};
            for my $entity (@$entities) {
                if (!grep { $_ eq $code->{code} } $entity->$all) {
                    $entity->$add($code->{code});
                }
            }
        }
    }
}

sub load_parent_country
{
    my ($self, @objs) = @_;
    my $country_area_type = 1;
    my $area_area_parent_type = 356;

    my @objects_to_use = grep { defined $_ &&
                                !defined $_->parent_country &&
                                ( defined $_->type ? $_->type->id != $country_area_type : $_->type_id != $country_area_type)} @objs;
    return unless @objects_to_use;
    my %obj_id_map = object_to_ids(@objects_to_use);
    my @all_ids = keys %obj_id_map;

    # First, construct a table (recursively) of parent -> descendant connections
    # for areas including an array of the path (the 'descendants' array).
    #
    # Then, for given descendants, find the shortest path to a parent of type
    # 1 (country) by joining to area, limiting on type=1, distinct on descendant,
    # and order by array_length(descendants).
    #
    # Thus, find the nearest containing country for an area.
    my $query = "
        WITH RECURSIVE area_descendants AS (
            SELECT entity0 AS parent, entity1 AS descendant, ARRAY[entity1] AS descendants
            FROM   l_area_area laa
            JOIN   link ON laa.link = link.id
            WHERE  link_type = $area_area_parent_type
                UNION ALL
            SELECT entity0 AS parent, descendant, descendants || entity1
            FROM   l_area_area laa
            JOIN   link ON laa.link=link.id
            JOIN   area_descendants ON area_descendants.parent = laa.entity1
            WHERE  link_type = $area_area_parent_type
            AND    NOT entity0 = ANY(descendants))
        SELECT   DISTINCT ON (descendant) descendant, " . $self->_columns . "
        FROM     area_descendants
        JOIN     area ON area_descendants.parent = area.id
        WHERE    area.type = $country_area_type
        AND      descendant IN (" . placeholders(@all_ids) . ")
        ORDER BY descendant, array_length(descendants, 1) ASC
    ";
    my $parent_countries = $self->sql->select_list_of_hashes($query, @all_ids);

    my $parent_objects = $self->get_by_ids(map { $_->{id} } @$parent_countries);

    for my $parent (@$parent_countries) {
        if (my $entities = $obj_id_map{$parent->{descendant}}) {
            my $parent_obj = $parent_objects->{$parent->{id}};
            for my $entity (@$entities) {
                $entity->parent_country($parent_obj);
            }
        }
    };
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
    $self->c->model('Edit')->merge_entities('area', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('area', $new_id, @old_ids);
    $self->merge_codes($new_id, @old_ids);

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

sub find_by_iso_3166_1_code {
    my ($self, $code) = @_;
    my $query = "SELECT iso.code, " . $self->_columns .
        " FROM iso_3166_1 iso JOIN area ON iso.area = area.id" .
        " WHERE iso.code = ?";

    my $rows = $self->sql->select_list_of_hashes($query, $code);
    return $self->_new_from_row($rows->[0]);
}

sub _hash_to_row
{
    my ($self, $area) = @_;
    my $row = hash_to_row($area, {
        type => 'type_id',
        ended => 'ended',
        name => 'name',
        sort_name => 'sort_name',
    });

    add_partial_date_to_row($row, $area->{begin_date}, 'begin_date');
    add_partial_date_to_row($row, $area->{end_date}, 'end_date');

    return $row;
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
