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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
