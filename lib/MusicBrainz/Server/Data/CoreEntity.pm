package MusicBrainz::Server::Data::CoreEntity;

use Moose;
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list query_to_list_limited );
use Sql;

extends 'MusicBrainz::Server::Data::Entity';

sub _gid_redirect_table
{
    return undef;
}

sub get_by_gids
{
    my ($self, @gids) = @_;
    return $self->_get_by_keys('gid', @gids);
}

sub get_by_gid
{
    my ($self, $gid) = @_;
    return unless $gid;
    my @result = values %{$self->_get_by_keys("gid", $gid)};
    if (scalar(@result)) {
        return $result[0];
    }
    my $table = $self->_gid_redirect_table;
    if (defined($table)) {
        my $id = $self->sql->select_single_value("SELECT new_id FROM $table WHERE gid=?", $gid);
        if (defined($id)) {
            return $self->get_by_id($id);
        }
    }
    return undef;
}

sub find_by_name
{
    my ($self, $name) = @_;
    my $query = "SELECT " . $self->_columns . " FROM " . $self->_table . "
                  WHERE unaccent(lower(name.name)) = unaccent(lower(?))";
    return query_to_list($self->c->sql, sub { $self->_new_from_row(shift) }, $query, $name);
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
    my $old_gids = $self->sql->select_single_column_array('
        DELETE FROM '.$table.'
        WHERE id IN ('.placeholders(@old_ids).')
        RETURNING gid', @old_ids);

    # Add redirects from GIDs of the deleted recordings to $new_id
    $self->add_gid_redirects(map { $_ => $new_id } @$old_gids);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::CoreEntity

=head1 METHODS

=head2 get_by_gid ($gid)

Loads and returns a single CoreEntity instance for the specified $gid.

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
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
