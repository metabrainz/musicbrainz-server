package MusicBrainz::Server::Controller::Role::Details;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

sub details : Chained('load') PathPart {
    my ($self, $c) = @_;
    $c->stash( template => 'entity/details.tt' );
}

no Moose::Role;
1;
