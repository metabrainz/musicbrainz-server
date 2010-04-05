package MusicBrainz::Server::Data::FeyEntity;
use Moose;
use Carp;
use List::MoreUtils qw( uniq );
use Moose::Autobox;
use MooseX::ABC;
use Method::Signatures::Simple;
use Fey::SQL;
use Fey::SQL::Pg;

extends 'MusicBrainz::Server::Data::Entity';

has 'table' => (
    is         => 'ro',
    lazy_build => 1,
    isa        => 'Fey::Table',
);

has 'columns' => (
    is         => 'ro',
    lazy_build => 1,
    init_arg   => undef
);

method _build_columns { [ $self->table->columns ] }

method _select {
    return Fey::SQL->new_select
        ->select($self->columns->flatten)
        ->from($self->table);
}

method insert (@hashes) {
    my @created;
    for my $hash (@hashes)
    {
        my $row = $self->_hash_to_row($hash);
        my $query = $self->_insert_query($row);

        my $inserted = $self->sql->select_single_row_hash(
            $query->sql($self->sql->dbh), $query->bind_params);

        push @created, $self->_new_from_row($inserted);
    }
    return @hashes > 1 ? @created : $created[0];
}

method update ($id, $update_hash)
{
    croak 'Must specify an entity to update' unless $id;
    my $row = $self->_hash_to_row($update_hash);
    my $query = $self->_update_query($row)
        ->where($self->table->primary_key->[0], '=', $id);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
}

method _hash_to_row ($hash) { return $hash; }

method _insert_query ($row) {
    my @cols = grep { defined } map { $self->table->column($_) }
        keys %$row;

    return Fey::SQL::Pg->new_insert
        ->into(@cols)
        ->returning(@{ $self->table->primary_key })
        ->values(%$row);
}

method _update_query ($row) {
    my @cols = grep { defined } map { $self->table->column($_) }
        keys %$row;

    my $query = Fey::SQL::Pg->new_update
        ->update($self->table);

    while (my ($col, $val) = each %$row) {
        $query->set($self->table->column($col), $val);
    }

    return $query;
}

method can_delete ($id) { 1 }

method _delete (@ids)
{
    my $query = Fey::SQL->new_delete
        ->from($self->table)
        ->where($self->table->primary_key->[0], 'IN', @ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    return 1;
}

method delete (@ids)
{
    $self->_delete(grep { $self->can_delete($_) } @ids);
}

method merge ($new_id, @old_ids) { }

method _get_by_keys ($column, @ids) {
    @ids = uniq grep { defined && $_ } @ids or return;

    my $query = $self->_select->where($column, 'IN', @ids);
    $self->sql->fey_select($query);
    my %result;
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my $obj = $self->_new_from_row($row);
        $result{$obj->id} = $obj;
    }
    $self->sql->finish;

    return \%result;
}

method get_by_ids (@ids) {
    return $self->_get_by_keys($self->table->column('id'), @ids);
}

__PACKAGE__->meta->make_immutable;
