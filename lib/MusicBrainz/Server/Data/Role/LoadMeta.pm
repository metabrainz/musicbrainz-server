package MusicBrainz::Server::Data::Role::LoadMeta;
use MooseX::Role::Parameterized;

parameter 'metadata_table';

role {
    my $params = shift;
    my $table  = $params->metadata_table;

    method load_meta => sub {
        my $self = shift;
        my @objs = @_ or return;
        my %id_to_obj = map { $_->id => $_ } @objs;

        my $q = Fey::SQL->new_select
            ->select($table)->from($table)
            ->where($table->column('id'), 'IN', keys %id_to_obj);

        $self->sql->fey_select($q);
        while(1) {
            my $row = $self->sql->next_row_hash_ref or last;
            my $obj = $id_to_obj{$row->{id}};
            $obj->meta->rebless_instance($obj, %$row);
        }
        $self->sql->finish;
    };
};

1;
