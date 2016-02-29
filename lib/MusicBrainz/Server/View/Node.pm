package MusicBrainz::Server::View::Node;

use strict;
use warnings;
use base 'MusicBrainz::Server::View::Base';
use DBDefs;
use Encode;
use HTML::Entities qw( decode_entities );
use HTTP::Request;
use JSON -convert_blessed_universally;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use URI;

sub process {
    my ($self, $c) = @_;

    my $user;
    if ($c->user_exists) {
        $user = $c->user->TO_JSON;
    }

    my %stash = %{$c->stash};
    # XXX contains code references which can't be encoded
    delete $stash{sidebar_search};

    # convert DateTime objects to iso8601-formatted strings
    if (my $date = $stash{last_replication_date}) {
        $date = $date->clone;
        $date->set_time_zone('UTC');
        $stash{last_replication_date} = $date->iso8601 . 'Z';
    }

    my $body = $c->json_utf8->encode({
        context => {
            user => $user,
            debug => boolean_to_json($c->debug),
            stash => \%stash,
            sessionid => scalar($c->sessionid),
            session => $c->session,
            flash => $c->flash,
        }});

    my $uri = URI->new;
    $uri->scheme('http');
    $uri->host(DBDefs->RENDERER_HOST || '127.0.0.1');
    $uri->port(DBDefs->RENDERER_PORT);
    $uri->path($c->req->path);

    my $response;
    my $tries = 0;

    while ($tries < 5) {
        $response = $c->model('MB')->context->lwp->request(
            HTTP::Request->new('GET', $uri, $c->req->headers->clone, $body)
        );

        # If the connection is refused, the service may be restarting.
        if ($response->code == 500) {
            sleep 2;
            $tries++;
        } else {
            last;
        }
    }

    my $content = decode('utf-8', $response->content);
    $c->res->status($response->code);
    $c->res->body($content);
    $self->_post_process($c);
}

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
