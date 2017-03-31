package MusicBrainz::Server::Plugin::React;

use strict;
use warnings;

use base 'Template::Plugin';
use MusicBrainz::Server::Renderer qw( get_renderer_uri get_renderer_response );

sub embed {
    my ($self, $c, $component, $props, $opts) = @_;

    $opts = undef unless ref($opts) eq 'HASH';

    my $response = get_renderer_response(
        $c,
        get_renderer_uri($c, $component, $props, $opts),
    );

    my $content = $response->decoded_content;
    if ($response->code == 200) {
        return $content;
    } else {
        die $content;
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
