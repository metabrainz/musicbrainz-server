package MusicBrainz::Server::Form::SecureConfirm;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::Confirm';

with 'MusicBrainz::Server::Form::Role::CSRFToken';

1;
