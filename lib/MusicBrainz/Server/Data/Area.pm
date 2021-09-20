package MusicBrainz::Server::Data::Area;

use DBDefs;
use Moose;
use namespace::autoclean;
use List::AllUtils qw( any );
use List::UtilsBy qw( partition_by );
use MusicBrainz::Server::Constants qw(
    $STATUS_OPEN
    $AREA_TYPE_COUNTRY
);
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Entity::Area;
use MusicBrainz::Server::Entity::PartialDate;
use Readonly;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    get_area_containment_query
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_date_period
    order_by
    placeholders
    object_to_ids
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'area' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'area' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'area' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'area' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'area' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'area' };
with 'MusicBrainz::Server::Data::Role::Collection';

Readonly my @CODE_TYPES => qw( iso_3166_1 iso_3166_2 iso_3166_3 );

sub _type { 'area' }

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

sub _column_mapping
{
    return {
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        type_id => 'type',
        map {$_ => $_} qw( id gid name comment edits_pending last_updated ended iso_3166_1 iso_3166_2 iso_3166_3 )
    };
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, ['area', 'begin_area', 'end_area', 'country'], @objs);
}

sub load_containment {
    my ($self, @areas) = @_;

    @areas = grep { $_ && !defined $_->containment } @areas;
    return unless @areas;

    my @results = @{ $self->sql->select_list_of_hashes(
        get_area_containment_query('$1', 'any($2)'),
        [map { $_->id } @areas],
    ) };

    my %results_by_descendant = partition_by {
        $_->{descendant}
    } @results;

    my $parent_areas = $self->get_by_ids(
        map { $_->{parent} } @results
    );

    for my $area (@areas) {
        my @parent_ids = map {
            $_->{parent}
        } @{ $results_by_descendant{$area->id} // [] };
        $area->containment([map { $parent_areas->{$_} } @parent_ids]);
    }
}

sub _set_codes
{
    my ($self, $area, $type, $codes) = @_;
    $self->sql->do("DELETE FROM $type WHERE area = ?", $area);
    $self->sql->do(
        "INSERT INTO $type (area, code) VALUES " .
            join(', ', ('(?, ?)') x @$codes),
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

sub _insert_hook_after_each {
    my ($self, $created, $area) = @_;
    $self->set_all_codes($created->{id}, $area);
}

sub update
{
    my ($self, $area_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    $self->sql->update_row('area', $row, { id => $area_id }) if %$row;

    $self->set_all_codes($area_id, $update);

    return 1;
}

sub is_release_country_area {
    my ($self, $area_id) = @_;

    my $is_used = $self->sql->select_single_value('SELECT 1 FROM country_area WHERE area = ?', $area_id);
    return 1 if $is_used;

    return 0;
}

sub can_delete
{
    my ($self, $area_id) = @_;

    # Check the area is not one of the release countries
    return 0 if $self->is_release_country_area($area_id);

    my $used_in_relationship = used_in_relationship($self->c, area => 'area_row.id');
    return 1 if $self->sql->select_single_value(<<~"SQL", $area_id, $STATUS_OPEN);
        SELECT TRUE
        FROM area area_row
        WHERE id = ?
        AND edits_pending = 0
        AND NOT (
            EXISTS (
                SELECT TRUE FROM edit_area
                JOIN edit ON edit_area.edit = edit.id
                WHERE edit.status = ? AND edit_area.area = area_row.id
            ) OR
            EXISTS (
                SELECT TRUE FROM artist
                WHERE area = area_row.id
                OR begin_area = area_row.id
                OR end_area = area_row.id
            ) OR
            EXISTS (
                SELECT TRUE FROM label
                WHERE area = area_row.id
            ) OR
            EXISTS (
                SELECT TRUE FROM place
                WHERE area = area_row.id
            ) OR
            $used_in_relationship
        )
        SQL

    return 0;
}

sub delete
{
    my ($self, @area_ids) = @_;

    $self->c->model('Collection')->delete_entities('area', @area_ids);
    $self->c->model('Relationship')->delete_entities('area', @area_ids);
    $self->annotation->delete(@area_ids);
    $self->alias->delete_entities(@area_ids);
    $self->tags->delete(@area_ids);
    $self->remove_gid_redirects(@area_ids);
    for my $code_table (@CODE_TYPES) {
        $self->sql->do("DELETE FROM $code_table WHERE area IN (" . placeholders(@area_ids) . ')', @area_ids);
    }
    $self->delete_returning_gids(@area_ids);
    return 1;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('area', $new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('area', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('area', $new_id, \@old_ids);
    $self->merge_codes($new_id, @old_ids);

    # If any of the areas being merged is a country, then the new area is a
    # country
    $self->sql->do(
        'INSERT INTO country_area (area)
         SELECT DISTINCT ?::int
         FROM country_area
         WHERE area = any(?) AND NOT EXISTS (
           SELECT TRUE FROM country_area WHERE area = ?
         )',
         $new_id, \@old_ids, $new_id
    );

    for my $update (
        [ artist => 'area' ],
        [ artist => 'begin_area' ],
        [ artist => 'end_area' ],
        [ label => 'area' ],
        [ place => 'area' ],
        [ editor => 'area' ],
        [ release_country => 'country' ]
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

    merge_date_period(
        $self->sql => (
            table => 'area',
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

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

=method load_ids

Load internal IDs for area objects that only have GIDs.

=cut

sub load_ids
{
    my ($self, @areas) = @_;

    my @gids = map { $_->gid } @areas;
    return () unless @gids;

    my $query = '
        SELECT gid, id FROM area
        WHERE gid IN (' . placeholders(@gids) . ')
    ';
    my %map = map { $_->[0] => $_->[1] }
        @{ $self->sql->select_list_of_lists($query, @gids) };

    for my $area (@areas) {
        $area->id($map{$area->gid}) if exists $map{$area->gid};
    }
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

    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                " JOIN ${table} c ON c.area = area.id" .
                ' WHERE c.code = any(?)';

    my %ret = map { $_ => undef } @codes;
    for my $row (@{ $self->sql->select_list_of_hashes($query, \@codes) }) {
        for my $code (@codes) {
            if (any {$_ eq $code} @{ $row->{$table} }) {
                $ret{$code} = $self->_new_from_row($row);
            }
        }
    }

    return \%ret;
}

sub _order_by {
    my ($self, $order) = @_;

    my $order_by = order_by($order, 'name', {
        'name' => sub {
            return 'name COLLATE musicbrainz'
        },
        'type' => sub {
            return 'type, name COLLATE musicbrainz'
        }
    });

    return $order_by
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
