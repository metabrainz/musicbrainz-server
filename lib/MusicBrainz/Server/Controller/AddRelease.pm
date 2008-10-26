package MusicBrainz::Server::Controller::AddRelease;

use strict;
use warnings;

use base qw(Catalyst::Component Catalyst::Component::ACCEPT_CONTEXT);

sub system
{
    my ($self) = @_;

    return $self->context->session->{wizard};
}

1;
