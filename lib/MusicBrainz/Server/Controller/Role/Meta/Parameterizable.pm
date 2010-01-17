package MusicBrainz::Server::Controller::Role::Meta::Parameterizable;
use Moose;
extends 'MooseX::Role::Parameterized::Meta::Role::Parameterizable';
sub parameterized_role_metaclass { 'MusicBrainz::Server::Controller::Role::Meta::Parameterized' }
1;

