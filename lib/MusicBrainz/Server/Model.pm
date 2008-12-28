package MusicBrainz::Server::Model;

use strict;
use warnings;

use base qw/Catalyst::Component::ACCEPT_CONTEXT Catalyst::Model/;

sub dbh
{
    my $self = shift;
    $self->context->mb->{DBH};
}

1;
