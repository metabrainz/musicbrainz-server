package MusicBrainz::Server::Data::Application;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Application;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
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
    my @result = $self->_get_by_keys('oauth_id', $oauth_id);
    return $result[0];
}

sub find_by_owner
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE owner = ?
                 ORDER BY id";
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
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

sub delete_editor {
    my ($self, $editor_id) = @_;
    $self->sql->do("DELETE FROM " . $self->_table . " WHERE owner = ?", $editor_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
