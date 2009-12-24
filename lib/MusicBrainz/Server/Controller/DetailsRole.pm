package MusicBrainz::Server::Controller::DetailsRole;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

sub details : Chained('load') PathPart { }

no Moose::Role;
1;
