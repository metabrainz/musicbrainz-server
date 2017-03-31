package MusicBrainz::Server::Plugin::React;

use strict;
use warnings;

use base 'Template::Plugin';
use MusicBrainz::Server::Renderer qw( render_component );

sub embed {
    my ($self, $c, $component, $props) = @_;

    my $response = render_component($c, $component, $props);
    if ($response->{status} == 200) {
        return $response->{body};
    } else {
        die $response->{body};
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
