package MusicBrainz::Server::Controller::Role::Meta::Parameterized;
use Moose;

extends 'Moose::Meta::Role';
with 'MooseX::Role::Parameterized::Meta::Trait::Parameterized';
with 'MooseX::MethodAttributes::Role::Meta::Role';

__PACKAGE__->meta->make_immutable;
no Moose;
1;
