package MusicBrainz::Server::Controller::Alias;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

sub aliases : Chained('load') PathPart('aliases')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $aliases = $c->model($self->{model})->alias->find_by_entity_id($entity->id); 
    $c->stash(
        aliases => $aliases,
    );
}

no Moose::Role;
1;
