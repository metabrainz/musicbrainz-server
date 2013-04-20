package MusicBrainz::Server::Data::Area;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Entity::Area;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_partial_date
    placeholders
);

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'area' };
# with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'area_name' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'area' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'area' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'area' };
with 'MusicBrainz::Server::Data::Role::Merge';

sub _table
{
    return 'area';
}

sub _table_join_name {
    my ($self, $join_on) = @_;
    return $self->_table("ON area.name = $join_on OR area.sort_name = $join_on");
}

sub _columns
{
    return 'area.id, gid, area.name, area.sort_name, area.type, ' .
           'area.edits_pending, begin_date_year, begin_date_month, begin_date_day, ' .
           'end_date_year, end_date_month, end_date_day, ended, area.last_updated';
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
    load_subobjects($self, 'area', @objs);
    load_subobjects($self, 'country', @objs);
}

sub insert
{
    my ($self, @artists) = @_;
    my $class = $self->_entity_class;
    my @created;
    for my $artist (@artists)
    {
        my $row = $self->_hash_to_row($artist);
        $row->{gid} = $artist->{gid} || generate_gid();

        my $created = $class->new(
            name => $artist->{name},
            id => $self->sql->insert_row('artist', $row, 'id'),
            gid => $row->{gid}
        );

        push @created, $created;
    }
    return @artists > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $area_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    $self->sql->update_row('area', $row, { id => $area_id }) if %$row;

    return 1;
}

sub delete
{
    my ($self, @area_ids) = @_;

    $self->c->model('Relationship')->delete_entities('area', @area_ids);
    $self->annotation->delete(@area_ids);
    $self->alias->delete_entities(@area_ids);
    $self->remove_gid_redirects(@area_ids);
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

sub search_by_names {
    my ($self, @names) = @_;
    return {} unless scalar @names;

    my $id = $self->_id_column;
    my $query =
        "WITH search (term) AS (" .
            "VALUES " . join (",", ("(?)") x scalar @names) .
        ")" .
            # Search over name/sort-name
            "(".
                "SELECT search.term AS search_term, " . $self->_columns .
                " FROM " . $self->_table . " search_name" .
                " JOIN search ON musicbrainz_unaccent(lower(search_name.name)) = musicbrainz_unaccent(lower(search.term))".
                " JOIN " . $self->_table_join_name("search_name.id").
            ")";

    $self->c->sql->select($query, @names);
    my %ret;
    while (my $row = $self->c->sql->next_row_hash_ref) {
        my $search_term = delete $row->{search_term};

        $ret{$search_term} ||= [];
        push @{ $ret{$search_term} }, $self->_new_from_row ($row);
    }
    $self->c->sql->finish;

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
