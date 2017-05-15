package MusicBrainz::Server::View::Base;

use strict;
use warnings;

use base 'Catalyst::View';
use Date::Calc qw( Today_and_Now Add_Delta_DHMS Date_to_Time );
use DBDefs;
use Digest::MD5 qw( md5_hex );
use feature 'state';
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
        context => $c,
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

    return 1 unless DBDefs->USE_ETAGS;

    my $method = $c->request->method;
    if ($method ne 'GET' and $method ne 'HEAD' or $c->stash->{nocache}) {
        # disable caching explicitely
        return 1;
    }

    my $body = $c->response->body;
    if ($body) {
        utf8::encode($body) if utf8::is_utf8($body);
        $c->response->headers->etag(md5_hex($body));

        # MBS-7061: Prevent network providers/proxies from stripping HTML
        # comments, which are used heavily by knockout.js.
        $c->response->headers->push_header('Cache-Control' => 'no-transform');

        if (DBDefs->REPLICATION_TYPE eq DBDefs->RT_SLAVE && !$c->res->headers->expires) {
            my @today = Today_and_Now(1);
            my $next_hour = Date_to_Time(
                Add_Delta_DHMS($today[0], $today[1], $today[2], $today[3], 10, 0, 0, 1, 0, 0)
            );
            my $this_hour = Date_to_Time($today[0], $today[1], $today[2], $today[3], 10, 0);
            $c->res->headers->expires($next_hour);
            $c->res->headers->last_modified($this_hour);
        }
    }

    return 1;
}

1;
