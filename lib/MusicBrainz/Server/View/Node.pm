package MusicBrainz::Server::View::Node;

use strict;
use warnings;
use base 'MusicBrainz::Server::View::Base';
use DBDefs;
use MusicBrainz::Server::Renderer qw( render_component );
use Readonly;

Readonly our $DOCTYPE => '<!DOCTYPE html>';

sub process {
    my $self = shift;
    my $c = $_[0];

    $self->next::method(@_);

    my $component_path = $c->stash->{component_path} // $c->req->path;
    my $component_props = $c->stash->{component_props} // {};
    my $response = render_component($c, $component_path, $component_props);
    my ($content_type, $status, $body);

    if (defined $response) {
        ($content_type, $status, $body) =
            @$response{qw(content_type status body)};

        if ($content_type eq 'text/html') {
            $body = $DOCTYPE . $body;
        }
    } else {
        $content_type = 'text/plain';
    }

    $c->res->content_type($content_type . '; charset=utf-8');
    $c->res->status($status) if defined $status;
    $c->res->body($body);
    $self->_post_process($c);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
