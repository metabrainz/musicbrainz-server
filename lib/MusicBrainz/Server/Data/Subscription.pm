package MusicBrainz::Server::Data::Subscription;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;
use List::Util qw( first );
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
    query_to_list_limited
);

extends 'MusicBrainz::Server::Data::FeyEntity';

has 'parent' => (
    is       => 'ro',
    required => 1
);

has '_subscription_column' => (
    is         => 'ro',
    lazy_build => 1,
);

method _build__subscription_column {
    my @fks  = $self->parent->table->schema
        ->foreign_keys_between_tables($self->parent->table, $self->table);

    return first { defined }
        map { $_->source_columns->[0] } @fks;
}

method check_subscription ($editor_id, $entity_id) {
    my $query = Fey::SQL->new_select
        ->select(Fey::Literal::Number->new(1))
        ->from($self->table)
        ->where($self->table->column('editor'), '=', $editor_id)
        ->where($self->_subscription_column, '=', $entity_id);

    return $self->sql->select_single_value(
        $query->sql($self->sql->dbh),
        $query->bind_params) ? 1 : 0;
}

method subscribe ($editor_id, $entity_id) {
    Sql::run_in_transaction(sub
    {
        return if $self->check_subscription($editor_id, $entity_id);

        my $max_edit_id = $self->c->model('Edit')->get_max_id() || 0;
        my $query = Fey::SQL->new_insert
            ->into(
                $self->table->column('editor'), $self->_subscription_column,
                $self->table->column('lasteditsent')
            )->values(
                editor                            => $editor_id,
                $self->_subscription_column->name => $entity_id,
                lasteditsent                      => $max_edit_id
            );

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    }, $self->sql);
}

method unsubscribe ($editor_id, $entity_id)
{
    Sql::run_in_transaction(sub
    {
        my $query = Fey::SQL->new_delete
            ->from($self->table)
            ->where($self->table->column('editor'), '=', $editor_id)
            ->where($self->_subscription_column, '=', $entity_id);

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    }, $self->sql);
}

method find_subscribed_editors ($entity_id)
{
    my $editor = $self->c->model('Editor');
    my $query = $editor->_select
        ->from($editor->table, $self->table)
        ->where($self->_subscription_column, '=', $entity_id)
        ->order_by($editor->table->column('name'),
                   $editor->table->column('id'));

    return query_to_list(
        $self->c->dbh, sub {
            MusicBrainz::Server::Data::Editor->_new_from_row(@_) },
        $query->sql($self->sql->dbh), $query->bind_params);
}

method get_subscribed_editor_count ($entity_id)
{
    my $query = Fey::SQL->new_select
        ->select(Fey::Literal::Function('count', '*'))
        ->from($self->table)
        ->where($self->_subscription_column, '=', $entity_id);

    return $self->sql->select_single_value(
        $query->sql($self->sql->dbh), $query->bind_params);
}

method merge ($new_id, @old_ids)
{
    my $query;

    # Remove duplicate joins
    my $sub_q = Fey::SQL->new_select
        ->select($self->table->column('editor'))
        ->from($self->table)
        ->where($self->_subscription_column, '=', $new_id);

    $query = Fey::SQL->new_delete
        ->from($self->table)
        ->where($self->_subscription_column, 'IN', @old_ids)
        ->where($self->table->column('editor'), 'IN', $sub_q);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);

    # Move all remaining joins to the new entity
    $query = Fey::SQL->new_update
        ->update($self->table)
        ->set($self->_subscription_column, $new_id)
        ->where($self->_subscription_column, 'IN', @old_ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
};

method delete (@ids)
{
    my $query = Fey::SQL->new_delete
        ->from($self->table)
        ->where($self->_subscription_column, 'IN', @ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
}

method find_by_subscribed_editor ($editor_id, $limit, $offset)
{
    my $query = $self->_select
        ->from($self->parent->table, $self->table)
        ->where($self->table->column('editor'), '=', $editor_id)
        ->order_by($self->name_columns->{name},
                   $self->parent->table->column('id'))
        ->limit(undef, $offset || 0);

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query->sql($self->sql->dbh), $query->bind_params);
}

__PACKAGE__->meta->make_immutable;

