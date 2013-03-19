package MusicBrainz::Server::Data::EditorOAuthToken;
use Moose;
use namespace::autoclean;

use DateTime;
use DateTime::Duration;
#use MusicBrainz::Server::Entity::OAuthAuthorization;
use MusicBrainz::Server::Entity::EditorOAuthToken;
use MusicBrainz::Server::Data::Utils qw(
    query_to_list_limited
    generate_token
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _table
{
    return 'editor_oauth_token';
}

sub _columns
{
    return 'id, editor, application, authorization_code, access_token, refresh_token, expire_time, scope, mac_key, mac_time_diff';
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
        scope => 'scope',
        mac_key => 'mac_key',
        mac_time_diff => 'mac_time_diff',
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
    my @result = values %{$self->_get_by_keys('refresh_token', $token)};
    return $result[0];
}

sub find_granted_by_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT application, scope, max(refresh_token) AS refresh_token
                 FROM " . $self->_table . "
                 WHERE
                    editor = ? AND
                    access_token IS NOT NULL
                 GROUP BY application, scope
                 ORDER BY application, scope
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub check_granted_token
{
    my ($self, $editor_id, $application_id, $scope, $offline) = @_;
    my $query = "SELECT count(*)
                 FROM " . $self->_table . "
                 WHERE editor = ? AND application = ? AND scope = ? AND
                       access_token IS NOT NULL";
    if ($offline) {
        $query .= " AND refresh_token IS NOT NULL"
    }
    return $self->c->sql->select_single_value($query, $editor_id, $application_id, $scope);
}

sub delete_application
{
    my ($self, $application_id) = @_;
    $self->sql->do("DELETE FROM editor_oauth_token WHERE application = ?", $application_id);
}

sub delete_editor
{
    my ($self, $editor_id) = @_;
    $self->sql->do("DELETE FROM editor_oauth_token WHERE editor = ?", $editor_id);
}

sub create_authorization_code
{
    my ($self, $editor_id, $application_id, $scope, $offline) = @_;

    my $row = {
        editor => $editor_id,
        application => $application_id,
        authorization_code => generate_token(),
        granted => DateTime->now,
        expire_time => DateTime->now->add( hours => 1 ),
        scope => $scope,
    };

    if ($offline) {
        $row->{refresh_token} = generate_token();
    }

    $row->{id} = $self->sql->insert_row($self->_table, $row, 'id');

    return $self->_new_from_row($row);
}

sub grant_access_token
{
    my ($self, $token, $mac) = @_;

    my $update = {
        authorization_code => undef,
        access_token => generate_token(),
        expire_time => DateTime->now->add( hours => 1 ),
        mac_time_diff => undef,
    };

    $token->authorization_code($update->{authorization_code});
    $token->access_token($update->{access_token});
    $token->expire_time($update->{expire_time});
    $token->mac_time_diff($update->{mac_time_diff});

    if ($mac) {
        $update->{mac_key} = generate_token();
        $token->mac_key($update->{mac_key});
    }

    $self->sql->update_row($self->_table, $update, { id => $token->id });

    # delete expired tokens that can't be refreshed in the future
    $self->sql->do("DELETE FROM editor_oauth_token
                    WHERE editor = ? AND application = ? AND scope = ? AND
                          expire_time < ? AND refresh_token IS NULL AND
                          access_token IS NOT NULL",
                   $token->editor_id, $token->application_id, $token->scope,
                   DateTime->now);
}

sub revoke_access
{
    my ($self, $editor_id, $application_id, $scope) = @_;

    $self->sql->do("DELETE FROM editor_oauth_token
                    WHERE editor = ? AND application = ? AND scope = ? AND
                    access_token IS NOT NULL",
                    $editor_id, $application_id, $scope);
}

sub update_mac_time_diff
{
    my ($self, $token, $time_diff) = @_;

    my $update = { mac_time_diff => $time_diff };
    $token->mac_time_diff($update->{mac_time_diff});

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
