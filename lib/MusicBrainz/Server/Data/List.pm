package MusicBrainz::Server::Data::List;

use Moose;
use Sql;
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list_limited
);

extends 'MusicBrainz::Server::Data::CoreEntity';

sub _table
{
    return 'list';
}

sub _columns
{
    return 'id, gid, editor, name, public';
}

sub _id_column
{
    return 'id';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        editor_id => 'editor',
        name => 'name',
        public => 'public',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::List';
}

sub create_list
{
    my ($self, $user) = @_;

    my $sql = Sql->new($self->c->dbh);
    return $sql->select_single_value("INSERT INTO " . $self->_table . "
                                    (editor)
                                    VALUES (?) RETURNING id", $user->id);
}

sub add_release_to_list
{
    my ($self, $list_id, $release_id) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->auto_commit;

    my $rows = $sql->select ("SELECT * FROM list_release 
       WHERE list=? AND release=?", $list_id, $release_id);
    $sql->finish;

    $sql->do("INSERT INTO list_release (list, release)
              VALUES (?, ?)", $list_id, $release_id) unless $rows;
}

sub remove_release_from_list
{
    my ($self, $list_id, $release_id) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->auto_commit;
    $sql->do("DELETE FROM list_release
              WHERE list = ? AND release = ?",
              $list_id, $release_id);
}

sub check_release
{
    my ($self, $list_id, $release_id) = @_;

    my $sql = Sql->new($self->c->dbh);
    return $sql->select_single_value("
        SELECT 1 FROM list_release
        WHERE list = ? AND release = ?",
        $list_id, $release_id) ? 1 : 0;
}

sub merge_releases
{
    my ($self, $new_id, @old_ids) = @_;

    my $sql = Sql->new($self->c->dbh);

    # Remove duplicate joins (ie, rows with release from @old_ids and pointing to
    # a list that already contains $new_id)
    $sql->do("DELETE FROM list_release
              WHERE release IN (".placeholders(@old_ids).") AND
                  list IN (SELECT list FROM list_release WHERE release = ?)",
              @old_ids, $new_id);

    # Move all remaining joins to the new release
    $sql->do("UPDATE list_release SET release = ?
              WHERE release IN (".placeholders(@old_ids).")",
              $new_id, @old_ids);
}

sub delete_releases
{
    my ($self, @ids) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->do("DELETE FROM list_release
              WHERE release IN (".placeholders(@ids).")", @ids);
}

sub find_by_editor
{
    my ($self, $id, $show_private, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE editor=? ";

    if (!$show_private) {
        $query .= "AND public=true ";
    }

    $query .= "ORDER BY musicbrainz_collate(name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $id, $offset || 0);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2010 Sean Burke

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
