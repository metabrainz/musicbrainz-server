package MusicBrainz::Server::Data::CoreEntity;

use Moose;
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );
use Sql;

extends 'MusicBrainz::Server::Data::Entity';

sub _gid_redirect_table
{
    return undef;
}

sub get_by_gid
{
    my ($self, $gid) = @_;
    my @result = values %{$self->_get_by_keys("gid", $gid)};
    if (scalar(@result)) {
        return $result[0];
    }
    my $table = $self->_gid_redirect_table;
    if (defined($table)) {
        my $sql = Sql->new($self->c->mb->dbh);
        my $id = $sql->SelectSingleValue("SELECT newid FROM $table WHERE gid=?", $gid);
        if (defined($id)) {
            return $self->get_by_id($id);
        }
    }
    return undef;
}

sub find_by_name
{
    my ($self, $name) = @_;
    my $query = "SELECT " . $self->_columns . " FROM " . $self->_table . " WHERE name.name = ?";
    return query_to_list($self->c->dbh, sub { $self->_new_from_row(shift) }, $query, $name);
}

sub remove_gid_redirects
{
    my ($self, @ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $table = $self->_gid_redirect_table;
    $sql->Do("DELETE FROM $table WHERE newid IN (" . placeholders(@ids) . ')', @ids);
}

sub add_gid_redirects
{
    my ($self, %redirects) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $table = $self->_gid_redirect_table;
    my $query = "INSERT INTO $table (gid, newid) VALUES " .
                (join ", ", ('(?, ?)') x keys %redirects);
    $sql->Do($query, %redirects);
}

sub update_gid_redirects
{
    my ($self, $old_id, $new_id) = @_; 
    my $sql = Sql->new($self->c->dbh);
    my $table = $self->_gid_redirect_table;
    $sql->Do("UPDATE $table SET newid = ? WHERE newid = ?", $new_id, $old_id);
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
