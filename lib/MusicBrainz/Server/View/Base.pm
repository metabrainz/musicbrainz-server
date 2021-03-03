package MusicBrainz::Server::View::Base;

use strict;
use warnings;

use base 'Catalyst::View';
use IO::Socket::UNIX;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Renderer qw( send_to_renderer );

sub process {
    my ($self, $c) = @_;

    my $socket;
    my $tries = 0;

    while ($tries < 5) {
        $socket = IO::Socket::UNIX->new(
            Type => SOCK_STREAM,
            Peer => DBDefs->RENDERER_SOCKET,
        );
        if (defined $socket) {
            $c->stash->{renderer_socket} = $socket;
            last;
        } else {
            sleep 2;
            $tries++;
        }
    }

    unless (defined $socket) {
        die q(Couldn't connect to the renderer.);
    }

    my %message = (
        begin => \1,
        context => $c->TO_JSON,
    );

    send_to_renderer($c, \%message);
    return 1;
}

sub _post_process {
    my ($self, $c) = @_;

    send_to_renderer($c, {finish => 1});
    my $socket = delete $c->stash->{renderer_socket};
    $socket->shutdown(2);
    $socket->close;

    # MBS-7061: Prevent network providers/proxies from stripping HTML
    # comments, which are used heavily by knockout.js.
    $c->response->headers->push_header('Cache-Control' => 'no-transform');

    return 1;
}

1;
