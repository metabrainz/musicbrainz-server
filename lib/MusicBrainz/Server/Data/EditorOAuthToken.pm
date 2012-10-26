package MusicBrainz::Server::Data::EditorOAuthToken;
use Moose;
use namespace::autoclean;

use Data::UUID;
use MIME::Base64 qw( encode_base64url );
use DateTime;
use DateTime::Duration;
use MusicBrainz::Server::Entity::EditorOAuthToken;

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'editor_oauth_token';
}

sub _columns
{
    return 'id, editor, application, authorization_code, access_token, refresh_token, expire_time';
}

sub _column_mapping
{
    return {
        id => 'id',
        editor_id => 'editor',
        application_id => 'application',
        authorization_code => 'authorization_code',
        access_token => 'access_token',
        refresh_token => 'refresh_token',
        expire_time => 'expire_time',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::EditorOAuthToken';
}

sub get_by_authorization_code
{
    my ($self, $token) = @_;
    my @result = values %{$self->_get_by_keys('authorization_code', $token)};
    return $result[0];
}

sub get_by_access_token
{
    my ($self, $token) = @_;
    my @result = values %{$self->_get_by_keys('access_token', $token)};
    return $result[0];
}

sub get_by_refresh_token
{
    my ($self, $token) = @_;
    my @result = values %{$self->_get_by_keys('access_token', $token)};
    return $result[0];
}

sub delete_editor
{
    my ($self, $editor_id) = @_;
    $self->sql->do("DELETE FROM editor_oauth_token WHERE editor = ?", $editor_id);
}

sub create_authorization_code
{
    my ($self, $editor_id, $application_id) = @_;

    my $row = {
        editor => $editor_id,
        application => $application_id,
        authorization_code => encode_base64url(Data::UUID->new->create_bin),
        expire_time => DateTime->now->add( hours => 1 ),
    };

    $row->{id} = $self->sql->insert_row($self->_table, $row, 'id');

    return $self->_new_from_row($row);
}

sub grant_access_token
{
    my ($self, $token, $secret) = @_;

    my $update = {
        authorization_code => undef,
        access_token => encode_base64url(Data::UUID->new->create_bin),
        refresh_token => encode_base64url(Data::UUID->new->create_bin),
        expire_time => DateTime->now->add( hours => 1 ),
    };

    $token->authorization_code($update->{authorization_code});
    $token->access_token($update->{access_token});
    $token->refresh_token($update->{refresh_token});
    $token->expire_time($update->{expire_time});

    if ($secret) {
        $update->{secret} = encode_base64url(Data::UUID->new->create_bin);
        $token->secret($update->{secret});
    }

    $self->sql->update_row($self->_table, $update, { id => $token->id });
}

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
