package MusicBrainz::Server::View::Node;

use strict;
use warnings;
use base 'MusicBrainz::Server::View::Base';
use DBDefs;
use MusicBrainz::Server::Renderer qw( get_renderer_uri get_renderer_response );

sub process {
    my ($self, $c) = @_;

    my ($uri, $store_key) =
        get_renderer_uri($c, $c->req->path, {}, {context => 1});

    if (DBDefs->RENDERER_X_ACCEL_REDIRECT) {
        my $redirect_uri = '/internal/renderer/' . $uri->host_port . $uri->path_query;
        $c->res->headers->header('X-Accel-Redirect' => $redirect_uri);
        return;
    }

    my $response = get_renderer_response($c, $uri, $store_key, $c->req->headers->clone);
    $c->res->status($response->code);
    $c->res->body($response->decoded_content);
    $self->_post_process($c);
}

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
