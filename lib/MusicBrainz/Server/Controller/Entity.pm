package MusicBrainz::Server::Controller::Entity;

use strict;
use warnings;

use base qw/Catalyst::Controller Class::Accessor/;

__PACKAGE__->mk_accessors(qw/ entity form /);
__PACKAGE__->config(
    form_namespace => 'MusicBrainz::Server::Form'
);

sub create_action
{
    my $self = shift;
    my %args = @_;

    if (exists $args{attributes}{'Form'})
    {
        $args{_attr_params} = delete $args{attributes}{'Form'};
        push @{ $args{attributes}{ActionClass} },
            'MusicBrainz::Server::Action::Form';
    }

    $self->SUPER::create_action(%args);
}

sub load : Chained('base') PathPart('') CaptureArgs(1)
{
   my ($self, $c, $id) = @_;

   my $entity = $c->model($self->{model})->load($id);

   $self->entity($entity);
   $c->stash->{$self->{entity_name}} = $entity;
}

sub submit_and_validate
{
    my ($self, $c) = @_;
    return $c->form_posted && $self->form->validate($c->req->params);
}

1;
