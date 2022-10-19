package MusicBrainz::Server::Data::CoreEntity;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( generate_gid placeholders object_to_ids );
use MusicBrainz::Server::Validation qw( is_guid );
use Sql;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::GetByGID';
with 'MusicBrainz::Server::Data::Role::Name';

sub _main_table {
    my $type = shift->_type;
    return $ENTITIES{$type}{table} // $type;
}

# Override this for joins etc. if necessary.
sub _table { shift->_main_table }

sub _entity_class { 'MusicBrainz::Server::Entity::' . $ENTITIES{shift->_type}{model} }

sub _gid_redirect_table {
    my $self = shift;

    return $self->_main_table . '_gid_redirect'
        if $ENTITIES{$self->_type}{mbid}{multiple};
    return;
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
    for my $gid (grep { is_guid($_) } @gids) {
        unless (exists $gid_map{$gid}) {
            push @missing_gids, $gid;
        }
    }
    if (@missing_gids) {
        my $sql = "SELECT new_id, gid FROM $table
            WHERE gid IN (" . placeholders(@missing_gids) . ')';
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
    return unless is_guid($gid);
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

sub insert {
    my ($self, @entities) = @_;

    my $extra_data = $self->_insert_hook_prepare(\@entities);

    my @created;
    for my $entity (@entities) {
        my $row = $self->_insert_hook_make_row($entity, $extra_data);
        $row->{gid} = $entity->{gid} || generate_gid();

        my $created = {
            id => $self->sql->insert_row($self->_main_table, $row, 'id'),
            gid => $row->{gid},
        };

        $self->_insert_hook_after_each($created, $entity, $extra_data);

        push @created, $created;
    }

    $self->_insert_hook_after(\@created, $extra_data);
    return @entities > 1 ? @created : $created[0];
}

sub _insert_hook_prepare { {} }

sub _insert_hook_make_row {
    my ($self, $entity) = @_;
    return $self->_hash_to_row($entity);
}

sub _insert_hook_after_each { }

sub _insert_hook_after { }

sub load_gid_redirects {
    my ($self, @entities) = @_;
    my $table = $self->_gid_redirect_table;

    my %entities_by_id = object_to_ids(@entities);

    my $query = "SELECT new_id, array_agg(gid) AS gid_redirects FROM $table WHERE new_id = any(?) GROUP BY new_id";
    my $results = $self->c->sql->select_list_of_hashes($query, [map { $_->id } @entities]);

    for my $row (@$results) {
        for my $entity (@{ $entities_by_id{$row->{new_id}} }) {
            $entity->gid_redirects($row->{gid_redirects});
        }
    }
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
                (join q(, ), ('(?, ?)') x keys %redirects);
    $self->sql->do($query, %redirects);
}

sub update_gid_redirects
{
    my ($self, $new_id, @old_ids) = @_;
    my $table = $self->_gid_redirect_table;
    $self->sql->do("
        UPDATE $table SET new_id = ?
        WHERE new_id IN (".placeholders(@old_ids).')', $new_id, @old_ids);
}

sub _delete_and_redirect_gids
{
    my ($self, $table, $new_id, @old_ids) = @_;

    # Update all GID redirects from @old_ids to $new_id
    $self->update_gid_redirects($new_id, @old_ids);

    # Delete the recording and select current GIDs
    my $old_gids = $self->delete_returning_gids(@old_ids);

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
    my ($self, @ids) = @_;
    return $self->sql->select_single_column_array('
        DELETE FROM ' . $self->_main_table . '
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
