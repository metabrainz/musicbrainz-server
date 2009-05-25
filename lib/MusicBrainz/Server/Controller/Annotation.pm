package MusicBrainz::Server::Controller::Annotation;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load', 'show';

sub latest_annotation : Chained('load') PathPart('annotation')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $annotation = $c->model($self->{model})->annotation->get_latest($entity->id);

    $c->stash(
        annotation => $annotation,
    );
}

after 'show' => sub 
{
    my ($self, $c) = @_;
    $c->model($self->{model})->annotation->load_latest($c->stash->{$self->{entity_name}});
};

no Moose::Role;
1;

