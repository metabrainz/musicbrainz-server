package MusicBrainz::Server::Data::FeyEntity;
use Moose;
use List::MoreUtils qw( uniq );
use Moose::Autobox;
use MooseX::ABC;
use Method::Signatures::Simple;
use Fey::SQL;

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
