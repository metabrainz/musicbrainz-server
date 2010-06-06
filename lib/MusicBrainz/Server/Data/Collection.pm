package MusicBrainz::Server::Data::Collection;
use Moose;
use Method::Signatures::Simple;

use Fey::SQL::Pg;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Schema qw( schema );

with 'MusicBrainz::Server::Data::Role::Context';

method create_collection ($user)
{
    my $table = schema->table('editor_collection');
    my $query = Fey::SQL::Pg->new_insert
        ->into(schema->table('editor_collection'))
        ->values( editor => $user->id )
        ->returning($table->column('id'));

    return $self->sql->select_single_value($query->sql($self->c->dbh), $query->bind_params);
}

method find_collection ($user)
{
    my $table = schema->table('editor_collection');
    my $query = Fey::SQL->new_select
        ->select($table->column('id'))->from($table)
        ->where($table->column('editor'), '=', $user->id);

    return $self->sql->select_single_value(
        $query->sql($self->c->dbh),
        $query->bind_params);
}

method add_release_to_collection ($collection_id, $release_id)
{
    my $table = schema->table('editor_collection_release');
    my $query = Fey::SQL->new_select
        ->select(1)->from($table)
        ->where($table->column('collection'), '=', $collection_id)
        ->where($table->column('release'), '=', $release_id);

    my $rows = $self->sql->select(
        $query->sql($self->c->dbh), $query->bind_params);

    $self->sql->finish;

    $query = Fey::SQL->new_insert
        ->into($table)
        ->values(
            collection => $collection_id,
            release    => $release_id
        );

    $self->sql->auto_commit;
    $self->sql->do(
        $query->sql($self->c->dbh), $query->bind_params) unless $rows;
}

method remove_release_from_collection ($collection_id, $release_id)
{
    my $table = schema->table('editor_collection_release');
    my $query = Fey::SQL->new_delete
        ->from($table)
        ->where($table->column('collection'), '=', $collection_id)
        ->where($table->column('release'), '=', $release_id);

    $self->sql->auto_commit;
    $self->sql->do(
        $query->sql($self->c->dbh), $query->bind_params);
}

method check_release ($collection_id, $release_id)
{
    my $table = schema->table('editor_collection_release');
    my $query = Fey::SQL->new_select
        ->select(1)->from($table)
        ->where($table->column('collection'), '=', $collection_id)
        ->where($table->column('release'), '=', $release_id);

    return $self->sql->select_single_value(
        $query->sql($self->c->dbh), $query->bind_params) ? 1 : 0;
}

method merge_releases ($new_id, @old_ids)
{
    my $table = schema->table('editor_collection_release');

    # Remove duplicate joins (ie, rows with release from @old_ids and pointing to
    # a collection that already contain $new_id)
    my $query = Fey::SQL->new_delete
        ->from($table)
        ->where($table->column('release'), 'IN', @old_ids)
        ->where($table->column('collection'), 'IN',
                Fey::SQL->new_select
                      ->select($table->column('collection'))->from($table)
                      ->where($table->column('release'), '=', $new_id));

    $self->sql->do($query->sql($self->c->dbh), $query->bind_params);

    # Move all remaining joins to the new release
    $query = Fey::SQL->new_update
        ->update($table)
        ->set($table->column('release'), $new_id)
        ->where($table->column('release'), 'IN', @old_ids);

    $self->sql->do($query->sql($self->c->dbh), $query->bind_params);
}

method delete_releases (@ids)
{
    my $table = schema->table('editor_collection_release');
    my $query = Fey::SQL->new_delete
        ->from($table)
        ->where($table->column('release'), 'IN', @ids);

    $self->sql->do($query->sql($self->c->dbh), $query->bind_params);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

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
