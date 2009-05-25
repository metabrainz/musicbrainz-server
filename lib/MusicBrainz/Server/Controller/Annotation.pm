package MusicBrainz::Server::Controller::Annotation;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

sub latest_annotation : Chained('load') PathPart('annotation')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $annotation = $c->model($self->{model})->annotation->get_latest($entity->id);

    $c->stash(
        annotation => $annotation,
    );
}

no Moose::Role;
1;

