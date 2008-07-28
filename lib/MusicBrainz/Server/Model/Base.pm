package MusicBrainz::Server::Model::Base;

use strict;
use warnings;

use base qw/Catalyst::Component::ACCEPT_CONTEXT Catalyst::Model/;

sub dbh
{
    my $self = shift;
    $self->context->mb->{DBH};
}

1;
