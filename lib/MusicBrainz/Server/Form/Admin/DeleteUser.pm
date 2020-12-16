package MusicBrainz::Server::Form::Admin::DeleteUser;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::SecureConfirm';

has '+name' => ( default => 'delete-user' );

has_field 'allow_reuse' => (
    type => 'Checkbox',
    default => 1,
);

1;
