package MusicBrainz::Server::Translation::History;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Translation';
with 'MusicBrainz::Server::Role::Translation' => { domain => 'history' };

sub l { __PACKAGE__->instance->gettext(@_) }

1;
