package MusicBrainz::Server::View::Base;

use strict;
use warnings;

use base 'Catalyst::View';
use IO::Socket::UNIX;
use DBDefs;
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Renderer qw( send_to_renderer );

sub process {
    my ($self, $c) = @_;

    my $socket;
    my $tries = 0;

    if (!non_empty(DBDefs->RENDERER_SOCKET)) {
        $c->error('The template renderer has been disabled on this server. (URL: ' . $c->req->uri . ')');
        return 0;
    }

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
        $c->error(q(Couldn't connect to the renderer.) . ' (URL: ' . $c->req->uri . ')');
        return 0;
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
    if (defined $socket) {
        $socket->shutdown(2);
        $socket->close;
    }

    # MBS-7061: Prevent network providers/proxies from stripping HTML
    # comments, which are used heavily by knockout.js.
    $c->response->headers->push_header('Cache-Control' => 'no-transform');

    return 1;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
