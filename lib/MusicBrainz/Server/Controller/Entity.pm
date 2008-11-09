package MusicBrainz::Server::Controller::Entity;

use strict;
use warnings;

use base qw/Catalyst::Controller Class::Accessor/;

__PACKAGE__->mk_accessors(qw/ form /);

sub create_action
{
    my $self = shift;
    my %args = @_;

    if (exists $args{attributes}{'Form'})
    {
        push @{ $args{attributes}{ActionClass} },
            'MusicBrainz::Server::Action::Form';
    }

    $self->SUPER::create_action(@_);
}

sub load : Chained('base') PathPart('') CaptureArgs(1)
{
   my ($self, $c, $id) = @_;

   my $entity = $c->model($self->{model})->load($id);
   $c->stash->{$self->{entity_name}} = $entity;
}

1;
