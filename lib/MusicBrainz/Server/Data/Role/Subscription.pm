package MusicBrainz::Server::Data::Role::Subscription;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Data::Subscription;

parameter 'subscription_table';

role {
    my $params    = shift;
    my $sub_table = $params->subscription_table;

    has 'subscription' => (
        is         => 'ro',
        lazy_build => 1
    );

    method _build_subscription => sub {
        my $self = shift;
        return MusicBrainz::Server::Data::Subscription->new(
            c      => $self->c,
            table  => $sub_table,
            parent => $self
        );
    };

    before _delete => sub {
        my ($self, @ids) = @_;
        $self->subscription->delete(@ids);
    };

    before merge => sub {
        my ($self, $new_id, @old_ids) = @_;
        $self->subscription->merge($new_id, @old_ids);
    };

    method find_by_subscribed_editor => sub
    {
        my ($self, $editor_id, $limit, $offset) = @_;
        my $query = $self->_select
            ->from($self->table, $sub_table)
            ->where($sub_table->column('editor'), '=', $editor_id)
            ->order_by($self->name_columns->{name}, $self->table->primary_key)
            ->limit(undef, $offset || 0);

        return query_to_list_limited(
            $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
            $query->sql($self->c->dbh), $query->bind_params);
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
