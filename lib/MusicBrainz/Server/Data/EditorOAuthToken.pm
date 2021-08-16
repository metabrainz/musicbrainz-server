package MusicBrainz::Server::Data::EditorOAuthToken;
use Moose;
use namespace::autoclean;

use DateTime;
use DateTime::Duration;
use MusicBrainz::Server::Entity::EditorOAuthToken;
use MusicBrainz::Server::Data::Utils qw(
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
    return 'id, editor, application, authorization_code, ' .
           'access_token, refresh_token, expire_time, scope, ' .
           'code_challenge, code_challenge_method';
}

sub _column_mapping
{
    return {
        id => 'id',
        editor_id => 'editor',
        application_id => 'application',
        authorization_code => 'authorization_code',
        access_token => 'access_token',
        code_challenge => 'code_challenge',
        code_challenge_method => 'code_challenge_method',
        refresh_token => 'refresh_token',
        expire_time => 'expire_time',
        scope => 'scope',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::EditorOAuthToken';
}

sub get_by_authorization_code
{
    my ($self, $token) = @_;
    my @result = $self->_get_by_keys('authorization_code', $token);
    return $result[0];
}

sub get_by_access_token
{
    my ($self, $token) = @_;
    my @result = $self->_get_by_keys('access_token', $token);
    return $result[0];
}

sub get_by_refresh_token
{
    my ($self, $token) = @_;
    my @result = $self->_get_by_keys('refresh_token', $token);
    return $result[0];
}

sub find_granted_by_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = 'SELECT application, scope, max(refresh_token) AS refresh_token
                 FROM ' . $self->_table . '
                 WHERE
                    editor = ? AND
                    access_token IS NOT NULL
                 GROUP BY application, scope
                 ORDER BY application, scope';
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
}

sub check_granted_token
{
    my ($self, $editor_id, $application_id, $scope, $offline) = @_;
    my $query = 'SELECT count(*)
                 FROM ' . $self->_table . '
                 WHERE editor = ? AND application = ? AND scope = ? AND
                       access_token IS NOT NULL';
    if ($offline) {
        $query .= ' AND refresh_token IS NOT NULL'
    }
    return $self->c->sql->select_single_value($query, $editor_id, $application_id, $scope);
}

sub delete_application
{
    my ($self, $application_id) = @_;
    $self->sql->do('DELETE FROM editor_oauth_token WHERE application = ?', $application_id);
}

sub delete_editor
{
    my ($self, $editor_id) = @_;
    $self->sql->do('DELETE FROM editor_oauth_token WHERE editor = ?', $editor_id);
    $self->sql->do('DELETE FROM editor_oauth_token WHERE application IN '.
        '(SELECT id FROM application WHERE owner = ?)', $editor_id);
}

sub create_authorization_code
{
    my ($self, $editor_id, $application_id, $scope, $offline,
        $code_challenge, $code_challenge_method) = @_;

    my $row = {
        editor => $editor_id,
        application => $application_id,
        authorization_code => generate_token(),
        code_challenge => $code_challenge,
        code_challenge_method => $code_challenge_method,
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
    my ($self, $token) = @_;

    my $update = {
        authorization_code => undef,
        code_challenge => undef,
        code_challenge_method => undef,
        access_token => generate_token(),
        expire_time => DateTime->now->add( hours => 1 ),
    };

    $token->authorization_code(undef);
    $token->code_challenge(undef);
    $token->code_challenge_method(undef);
    $token->access_token($update->{access_token});
    $token->expire_time($update->{expire_time});

    $self->sql->update_row($self->_table, $update, { id => $token->id });

    # delete expired tokens that can't be refreshed in the future
    $self->sql->do('DELETE FROM editor_oauth_token
                    WHERE editor = ? AND application = ? AND scope = ? AND
                          expire_time < ? AND refresh_token IS NULL AND
                          access_token IS NOT NULL',
                   $token->editor_id, $token->application_id, $token->scope,
                   DateTime->now);
}

sub revoke_access
{
    my ($self, $editor_id, $application_id, $scope) = @_;

    $self->sql->do('DELETE FROM editor_oauth_token
                    WHERE editor = ? AND application = ? AND scope = ? AND
                    access_token IS NOT NULL',
                    $editor_id, $application_id, $scope);
}

sub revoke_token {
    my ($self, $application_id, $token) = @_;

    die 'undef token' unless defined $token;

    # If the token is a refresh token, or if it's an access token with no
    # associated refresh token ("online" apps), delete the entire
    # authorization grant.
    return if $self->sql->select_single_value(
        'DELETE FROM editor_oauth_token ' .
        'WHERE application = $1 ' .
        'AND (' .
            '(refresh_token IS NOT NULL AND refresh_token = $2) OR ' .
            '(refresh_token IS NULL AND access_token = $2)' .
        ') RETURNING id',
        $application_id, $token,
    );

    # Otherwise, only NULL the access token. RFC 7009 specifies that we MAY
    # revoke the respective refresh token as well, but our implementation
    # allows it to continue to be used unless the client explicitly revokes
    # the refresh token.
    $self->sql->do(
        'UPDATE editor_oauth_token ' .
        'SET access_token = NULL ' .
        'WHERE application = ? ' .
        'AND access_token = ?',
        $application_id, $token,
    );
    return;
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
