package MusicBrainz::Server::Controller::Role::Details;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

sub details : Chained('load') PathPart { }

no Moose::Role;
1;
