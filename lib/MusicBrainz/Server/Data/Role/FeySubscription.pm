package MusicBrainz::Server::Data::Role::FeySubscription;
use MooseX::Role::Parameterized;
use Sql;
use List::Util qw( first );
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
    query_to_list_limited
);

parameter 'subscription_table';

role {
    my $params                 = shift;
    my $sub_table              = $params->subscription_table;

    has '_subscription_column' => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;
            my @fks  = $self->table->schema
                ->foreign_keys_between_tables($self->table, $sub_table);

            return first { defined }
                map { $_->source_columns->[0] } @fks;
        }
    );

    method 'subscription' => sub { shift; };

    method check_subscription => sub
    {
        my ($self, $editor_id, $entity_id) = @_;
        my $query = Fey::SQL->new_select
            ->select(Fey::Literal::Number->new(1))
            ->from($sub_table)
            ->where($sub_table->column('editor'), '=', $editor_id)
            ->where($self->_subscription_column, '=', $entity_id);

        return $self->sql->select_single_value(
            $query->sql($self->sql->dbh),
            $query->bind_params) ? 1 : 0;
    };

    method subscribe => sub
    {
        my ($self, $editor_id, $entity_id) = @_;
        Sql::run_in_transaction(sub
        {
            return if $self->check_subscription($editor_id, $entity_id);

            my $max_edit_id = $self->c->model('Edit')->get_max_id() || 0;
            my $query = Fey::SQL->new_insert
                ->into(
                    $sub_table->column('editor'), $self->_subscription_column,
                    $sub_table->column('lasteditsent')
                )->values(
                    editor                            => $editor_id,
                    $self->_subscription_column->name => $entity_id,
                    lasteditsent                      => $max_edit_id
                );

            $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
        }, $self->sql);
    };

    method unsubscribe => sub
    {
        my ($self, $editor_id, $entity_id) = @_;
        Sql::run_in_transaction(sub
        {
            my $query = Fey::SQL->new_delete
                ->from($sub_table)
                ->where($sub_table->column('editor'), '=', $editor_id)
                ->where($self->_subscription_column, '=', $entity_id);

            $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
        }, $self->sql);
    };

    method find_subscribed_editors => sub
    {
        my ($self, $entity_id) = @_;

        my $editor = $self->c->model('Editor');
        my $query = $editor->_select
            ->from($editor->table, $sub_table)
            ->where($self->_subscription_column, '=', $entity_id)
            ->order_by($editor->table->column('name'),
                       $editor->table->column('id'));

        return query_to_list(
            $self->c->dbh, sub {
                MusicBrainz::Server::Data::Editor->_new_from_row(@_) },
            $query->sql($self->sql->dbh), $query->bind_params);
    };

    method get_subscribed_editor_count => sub
    {
        my ($self, $entity_id) = @_;
        my $query = Fey::SQL->new_select
            ->select(Fey::Literal::Function('count', '*'))
            ->from($sub_table)
            ->where($self->_subscription_column, '=', $entity_id);

        return $self->sql->select_single_value(
            $query->sql($self->sql->dbh), $query->bind_params);
    };

    method merge => sub
    {
        my ($self, $new_id, @old_ids) = @_;
        my $query;

        # Remove duplicate joins
        my $sub_q = Fey::SQL->new_select
            ->select($sub_table->column('editor'))
            ->from($sub_table)
            ->where($self->_subscription_column, '=', $new_id);

        $query = Fey::SQL->new_delete
            ->from($sub_table)
            ->where($self->_subscription_column, 'IN', @old_ids)
            ->where($sub_table->column('editor'), 'IN', $sub_q);

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);

        # Move all remaining joins to the new entity
        $query = Fey::SQL->new_update
            ->update($sub_table)
            ->set($self->_subscription_column, $new_id)
            ->where($self->_subscription_column, 'IN', @old_ids);

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    };

    method delete => sub
    {
        my ($self, @ids) = @_;
        my $query = Fey::SQL->new_delete
            ->from($sub_table)
            ->where($self->_subscription_column, 'IN', @ids);

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    };

    method find_by_subscribed_editor => sub
    {
        my ($self, $editor_id, $limit, $offset) = @_;

        my $query = $self->_select
            ->from($self->table, $sub_table)
            ->where($sub_table->column('editor'), '=', $editor_id)
            ->order_by(#$self->name_columns->{name},
                       $self->table->column('id'))
            ->limit(undef, $offset || 0);

        return query_to_list_limited(
            $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
            $query->sql($self->sql->dbh), $query->bind_params);
    };
};

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
