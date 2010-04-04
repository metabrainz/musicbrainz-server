package MusicBrainz::Server::Data::Role::Gid;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Data::Utils qw( placeholders );

parameter 'redirect_table';

role {
    my $params = shift;
    my $table  = $params->redirect_table;

    method get_by_gid => sub {
        my ($self, $gid) = @_;
        return unless $gid;

        my @result = values %{$self->_get_by_keys($self->table->column('gid'),
                                                  $gid)};
        if (scalar(@result)) {
            return $result[0];
        }

        if ($table) {
            my $lookup = Fey::SQL->new_select
                ->select($table->column('newid'))
                ->from($table)
                ->where($table->column('gid'), '=', $gid);

            my $sql = $self->sql;
            my $id  = $sql->select_single_value($lookup->sql($sql->dbh),
                                                $lookup->bind_params)
                or return;

            return $self->get_by_id($id);
        }
    };

    method remove_gid_redirects => sub
    {
        my ($self, @ids) = @_;
        my $query = Fey::SQL->new_delete
            ->from($table)
            ->where($table->column('newid'), 'IN', @ids);

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    };

    method add_gid_redirects => sub
    {
        my ($self, %redirects) = @_;
        my $query = Fey::SQL->new_insert->into($table);

        while (my ($gid, $newid) = each %redirects) {
            $query->values( newid => $newid, gid => $gid );
        }

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    };

    method update_gid_redirects => sub
    {
        my ($self, $new_id, @old_ids) = @_;

        my $query = Fey::SQL->new_update
            ->update($table)
            ->set($table->column('newid'), $new_id)
            ->where($table->column('newid'), 'IN', @old_ids);

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    };

    method _delete_and_redirect_gids => sub
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
    };
};

1;
