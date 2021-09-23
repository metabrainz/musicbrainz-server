package MusicBrainz::Server::ControllerUtils::SSL;
use strict;
use warnings;

use DBDefs;

use Sub::Exporter -setup => {
    exports => [qw( ensure_ssl )]
};

sub ensure_ssl {
    my ($c) = @_;

    if (DBDefs->SSL_REDIRECTS_ENABLED && !$c->request->secure) {
        $c->response->redirect(
            'https://'.DBDefs->WEB_SERVER_SSL.$c->request->env->{REQUEST_URI});
        $c->detach;
    }
}

1;
