package MusicBrainz::Server::Data::Role::Gid;
use MooseX::Role::Parameterized;

parameter 'redirect_table';

role {
    my $params = shift;
    my $table  = $params->redirect_table;

    around get_by_gid => sub {
        my $orig = shift;
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
};

1;
