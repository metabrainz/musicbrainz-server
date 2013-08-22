package MusicBrainz::Server::Data::CoreEntity;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list query_to_list_limited );
use Sql;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::GetByGID';

sub _gid_redirect_table
{
    return undef;
}

around get_by_gids => sub
{
    my ($orig, $self) = splice(@_, 0, 2);
    my (@gids) = @_;
    my %gid_map = %{ $self->$orig(@_) };
    my $table = $self->_gid_redirect_table;
    return \%gid_map
        unless defined $table;
    my @missing_gids;
    for my $gid (@gids) {
        unless (exists $gid_map{$gid}) {
            push @missing_gids, $gid;
        }
    }
    if (@missing_gids) {
        my $sql = "SELECT new_id, gid FROM $table
            WHERE gid IN (" . placeholders(@missing_gids) . ")";
        my $ids = $self->sql->select_list_of_lists($sql, @missing_gids);
        my $id_map = $self->get_by_ids(map { $_->[0] } @$ids);
        for my $row (@$ids) {
            my $id = $row->[0];
            if (exists $id_map->{$id}) {
                my $obj = $id_map->{$id};
                $gid_map{$row->[1]} = $obj;
            }
        }
    }
    return \%gid_map;
};

around get_by_gid => sub
{
    my ($orig, $self) = splice(@_, 0, 2);
    my ($gid) = @_;
    if (my $obj = $self->$orig(@_)) {
        return $obj;
    }
    else {
        my $table = $self->_gid_redirect_table;
        if (defined($table)) {
            my $id = $self->sql->select_single_value("SELECT new_id FROM $table WHERE gid=?", $gid);
            if (defined($id)) {
                return $self->get_by_id($id);
            }
        }
        return undef;
    }
};

sub find_by_name
{
    my ($self, $name) = @_;
    my $query = "SELECT " . $self->_columns . " FROM " . $self->_table . "
                  WHERE musicbrainz_unaccent(lower(name.name)) = musicbrainz_unaccent(lower(?))";
    return query_to_list($self->c->sql, sub { $self->_new_from_row(shift) }, $query, $name);
}

sub get_by_ids_sorted_by_name
{
    my ($self, @ids) = @_;
    @ids = grep { defined && $_ } @ids;
    return [] unless @ids;

    my $key = $self->_id_column;
    my $query = "SELECT " . $self->_columns .
                " FROM " . $self->_table .
                " WHERE $key IN (" . placeholders(@ids) . ") " .
                " ORDER BY musicbrainz_collate(name.name)";
    my $sql = $self->sql;
    $self->sql->select($query, @ids);
    my @result;
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my $obj = $self->_new_from_row($row);
        push @result, $obj;
    }
    $self->sql->finish;
    return \@result;
}

sub find_by_names
{
    my $self = shift;
    my @names = @_;

    return () unless scalar @names;

    my $query = "SELECT " . $self->_columns . ", search_terms.term "
        ."FROM " . $self->_table
        . ", (VALUES "
        .     join (",", ("(?)") x scalar(@names))
        .    ") search_terms (term)"
        ." WHERE musicbrainz_unaccent(lower(name.name)) = "
        ." musicbrainz_unaccent(lower(search_terms.term));";

    my $results = $self->c->sql->select_list_of_hashes ($query, @names);

    my %mapped;
    for my $row (@$results)
    {
        my $key = delete $row->{term};

        $mapped{$key} //= [];

        push @{ $mapped{$key} }, $self->_new_from_row ($row);
    }

    return %mapped;
}

sub remove_gid_redirects
{
    my ($self, @ids) = @_;
    my $table = $self->_gid_redirect_table;
    $self->sql->do("DELETE FROM $table WHERE new_id IN (" . placeholders(@ids) . ')', @ids);
}

sub add_gid_redirects
{
    my ($self, %redirects) = @_;
    my $table = $self->_gid_redirect_table;
    my $query = "INSERT INTO $table (gid, new_id) VALUES " .
                (join ", ", ('(?, ?)') x keys %redirects);
    $self->sql->do($query, %redirects);
}

sub update_gid_redirects
{
    my ($self, $new_id, @old_ids) = @_;
    my $table = $self->_gid_redirect_table;
    $self->sql->do("
        UPDATE $table SET new_id = ?
        WHERE new_id IN (".placeholders(@old_ids).")", $new_id, @old_ids);
}

sub _delete_and_redirect_gids
{
    my ($self, $table, $new_id, @old_ids) = @_;

    # Update all GID redirects from @old_ids to $new_id
    $self->update_gid_redirects($new_id, @old_ids);

    # Delete the recording and select current GIDs
    my $old_gids = $self->delete_returning_gids($table, @old_ids);

    # Add redirects from GIDs of the deleted recordings to $new_id
    $self->add_gid_redirects(map { $_ => $new_id } @$old_gids);

    if ($self->can('_delete_from_cache')) {
        $self->_delete_from_cache(
            $new_id, @old_ids,
            @$old_gids
        );
    }
}

sub delete_returning_gids {
    my ($self, $table, @ids) = @_;
    return $self->sql->select_single_column_array('
        DELETE FROM '.$table.'
        WHERE id IN ('.placeholders(@ids).')
        RETURNING gid', @ids);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::CoreEntity

=head1 METHODS

=head2 get_by_gid ($gid)

Loads and returns a single CoreEntity instance for the specified $gid.

=head2 get_by_gids (@gids)

Loads and returns multiple CoreEntity instances for the specified @gids,
the response is a GID-keyes HASH reference.

=head1 COPYRIGHT

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

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
