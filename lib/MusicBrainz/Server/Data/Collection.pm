package MusicBrainz::Server::Data::Collection;

use Moose;
use Sql;
use MusicBrainz::Server::Data::Utils qw( placeholders );

extends 'MusicBrainz::Server::Data::CoreEntity';

sub _table
{
    return 'collection';
}

sub _columns
{
    return 'id, gid, name, public';
}

sub _id_column
{
    return 'id';
}

sub _gid_redirect_table
{
    return 'collection_gid_redirect';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        editor => 'editor',
        name => 'name',
        public => 'public',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Collection';
}

sub create_collection
{
    my ($self, $user) = @_;

    my $sql = Sql->new($self->c->dbh);
    return $sql->select_single_value("INSERT INTO " . $self->_table . "
                                    (editor)
                                    VALUES (?) RETURNING id", $user->id);
}

sub add_release_to_collection
{
    my ($self, $collection_id, $release_id) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->auto_commit;

    my $rows = $sql->select ("SELECT * FROM collection_release 
       WHERE collection=? AND release=?", $collection_id, $release_id);
    $sql->finish;

    $sql->do("INSERT INTO collection_release (collection, release)
              VALUES (?, ?)", $collection_id, $release_id) unless $rows;
}

sub remove_release_from_collection
{
    my ($self, $collection_id, $release_id) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->auto_commit;
    $sql->do("DELETE FROM collection_release
              WHERE collection = ? AND release = ?",
              $collection_id, $release_id);
}

sub check_release
{
    my ($self, $collection_id, $release_id) = @_;

    my $sql = Sql->new($self->c->dbh);
    return $sql->select_single_value("
        SELECT 1 FROM collection_release
        WHERE collection = ? AND release = ?",
        $collection_id, $release_id) ? 1 : 0;
}

sub merge_releases
{
    my ($self, $new_id, @old_ids) = @_;

    my $sql = Sql->new($self->c->dbh);

    # Remove duplicate joins (ie, rows with release from @old_ids and pointing to
    # a collection that already contain $new_id)
    $sql->do("DELETE FROM collection_release
              WHERE release IN (".placeholders(@old_ids).") AND
                  collection IN (SELECT collection FROM collection_release WHERE release = ?)",
              @old_ids, $new_id);

    # Move all remaining joins to the new release
    $sql->do("UPDATE collection_release SET release = ?
              WHERE release IN (".placeholders(@old_ids).")",
              $new_id, @old_ids);
}

sub delete_releases
{
    my ($self, @ids) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->do("DELETE FROM collection_release
              WHERE release IN (".placeholders(@ids).")", @ids);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

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
