package MusicBrainz::Server::Data::Application;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Application;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    query_to_list_limited
    generate_token
);


extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _table
{
    return 'application';
}

sub _columns
{
    return 'id, owner, name, oauth_id, oauth_secret, oauth_redirect_uri';
}

sub _column_mapping
{
    return {
        id  => 'id',
        owner_id  => 'owner',
        name  => 'name',
        oauth_id => 'oauth_id',
        oauth_secret => 'oauth_secret',
        oauth_redirect_uri => 'oauth_redirect_uri',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Application';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'application', @objs);
}

sub get_by_oauth_id
{
    my ($self, $oauth_id) = @_;
    my @result = values %{$self->_get_by_keys('oauth_id', $oauth_id)};
    return $result[0];
}

sub find_by_owner
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE owner = ?
                 ORDER BY id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

before 'insert' => sub
{
    my ($self, @objs) = @_;

    for my $obj (@objs) {
        $obj->{oauth_id} = generate_token();
        $obj->{oauth_secret} = generate_token();
    }
};

before 'delete' => sub
{
    my ($self, $id) = @_;

    $self->c->model('EditorOAuthToken')->delete_application($id);
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Lukas Lalinsky

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
