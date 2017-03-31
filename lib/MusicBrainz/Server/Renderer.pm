package MusicBrainz::Server::Renderer;

use strict;
use warnings;

use base 'Exporter';
use DBDefs;
use feature 'state';
use HTTP::Request;
use JSON -convert_blessed_universally;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json generate_token );
use URI::QueryParam;
use URI;

our @EXPORT_OK = qw(
    get_renderer_uri
    get_renderer_response
);

sub get_renderer_uri {
    my ($c, $path, $props) = @_;

    state $server_token = generate_token();
    state $request_id = 0;

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

    my $body = {
        context => {
            user => $user,
            debug => boolean_to_json($c->debug),
            stash => \%stash,
            sessionid => scalar($c->sessionid),
            session => $c->session,
            flash => $c->flash,
        },
        props => $props,
    };

    my $uri = URI->new;
    $uri->scheme('http');
    $uri->host(DBDefs->RENDERER_HOST || '127.0.0.1');
    $uri->port(DBDefs->RENDERER_PORT);
    $uri->path($path);
    $uri->query_param_append('token', $server_token);
    $uri->query_param_append('request_id', ++$request_id);
    $uri->query_param_append('user', $c->user->name) if $c->user_exists;

    my $store_key = 'template-body:' . $uri->path_query;
    $c->model('MB')->context->store->set($store_key, $body, 15);

    return ($uri, $store_key);
}

sub get_renderer_response {
    my ($c, $uri, $store_key, $headers) = @_;

    my $response;
    my $tries = 0;

    while ($tries < 5) {
        $response = $c->model('MB')->context->lwp->request(
            HTTP::Request->new('GET', $uri, $headers)
        );

        # If the connection is refused, the service may be restarting.
        if ($response->code == 500) {
            sleep 2;
            $tries++;
        } else {
            $c->model('MB')->context->store->delete($store_key);
            last;
        }
    }

    return $response;
}

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
