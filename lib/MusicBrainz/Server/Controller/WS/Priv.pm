package MusicBrainz::Server::Controller::WS::Priv;

use strict;
use warnings;
use MusicBrainz::Server::Handlers::WS::Private::Lookup;

use base 'MusicBrainz::Server::Controller';

=head1 NAME

MusicBrainz::Server::Controller::WS::Private - Private (JSON) based MusicBrainz XML web service

=head1 DESCRIPTION

Handles dispatching calls to the existing Web Service perl modules. TT is not being used for this service.

=head1 METHODS

=head2 artist

Handle artist related web service queries

=cut

sub lookup : Path('')
{
    my ($self, $c) = @_;
    return MusicBrainz::Server::Handlers::WS::Private::Lookup::handler($c);
}

1;
