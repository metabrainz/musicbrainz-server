package MusicBrainz::Server::ControllerUtils::SSL;
use strict;
use warnings;

use DBDefs;
use URI;

use Sub::Exporter -setup => {
    exports => [qw( ensure_ssl )]
};

sub ensure_ssl {
    my ($c) = @_;

    return unless DBDefs->SSL_REDIRECTS_ENABLED;

    my $request =
        URI->new("http://".DBDefs->WEB_SERVER_SSL.$c->request->env->{REQUEST_URI});

    if (!$c->request->secure) {
        $c->response->cookies->{return_to_http} = { value => 1 };

        $request->scheme('https');
        $c->response->redirect($request);
    }
    elsif ($c->request->secure && $c->request->cookie ('return_to_http')) {
        # expire in the past == delete cookie
        $c->response->cookies->{return_to_http} = { value => 1, expires => '-1m' };
        $c->response->redirect($request);
    }

    $c->detach if defined($c->response->redirect);
}

1;
