package MusicBrainz::Server::Data::List;

use Moose;

use Carp;
use Sql;
use MusicBrainz::Server::Entity::List;
use MusicBrainz::Server::Data::Utils qw(
    generate_gid
    placeholders
    query_to_list
    query_to_list_limited
);
use List::MoreUtils qw( zip );

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

sub add_releases_to_list
{
    my ($self, $list_id, @release_ids) = @_;
    $self->sql->auto_commit;

    my $added = $self->sql->select_single_column_array("SELECT release FROM list_release
       WHERE list = ? AND release IN (" . placeholders(@release_ids) . ")",
                             $list_id, @release_ids);

    my %added = map { $_ => 1 } @$added;

    @release_ids = grep { !exists $added{$_} } @release_ids;

    return unless @release_ids;

    my @list_ids = ($list_id) x @release_ids;
    $self->sql->do("INSERT INTO list_release (list, release) VALUES " . join(', ', ("(?, ?)") x @release_ids),
             zip @list_ids, @release_ids);
}

sub remove_releases_from_list
{
    my ($self, $list_id, @release_ids) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->auto_commit;
    $sql->do("DELETE FROM list_release
              WHERE list = ? AND release IN (" . placeholders(@release_ids) . ")",
              $list_id, @release_ids);
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

sub get_first_list
{
    my ($self, $editor_id) = @_;
    my $query = 'SELECT id FROM ' . $self->_table . ' WHERE editor = ? ORDER BY id ASC LIMIT 1';
    return $self->sql->select_single_value($query, $editor_id);
}

sub find_all_by_editor
{
    my ($self, $id) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE editor=? ";

    $query .= "ORDER BY musicbrainz_collate(name)";
    return query_to_list(
        $self->c->dbh, sub { $self->_new_from_row(@_) },
        $query, $id);
}

sub insert
{
    my ($self, $editor_id, @lists) = @_;
    my $class = $self->_entity_class;
    my @created;
    for my $list (@lists) {
        my $row = $self->_hash_to_row($list);
        $row->{editor} = $editor_id;
        $row->{gid} = $list->{gid} || generate_gid();

        push @created, $class->new(
            id => $self->sql->insert_row('list', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @created > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $list_id, $update) = @_;
    croak '$list_id must be present and > 0' unless $list_id > 0;
    my $row = $self->_hash_to_row($update);
    $self->sql->auto_commit;
    $self->sql->update_row('list', $row, { id => $list_id });
}

sub delete
{
    my ($self, @list_ids) = @_;

    $self->sql->auto_commit;
    $self->sql->do('DELETE FROM list_release
                    WHERE list IN (' . placeholders(@list_ids) . ')', @list_ids);
    $self->sql->auto_commit;
    $self->sql->do('DELETE FROM list
                    WHERE id IN (' . placeholders(@list_ids) . ')', @list_ids);
    return;
}

sub _hash_to_row
{
    my ($self, $values) = @_;

    my %row = (
        name => $values->{name},
        public => $values->{public}
    );

    return \%row;
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
