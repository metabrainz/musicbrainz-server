package MusicBrainz::Server::Controller::Genre;
use Moose;

use MusicBrainz::Server::Constants qw( %ENTITIES );

BEGIN { extends 'MusicBrainz::Server::Controller' }

sub list : Path('/genres') Args(0) {
    my ($self, $c) = @_;

    my $genres = $ENTITIES{tag}{genres};

    $c->stash(
        current_view => 'Node',
        component_path => 'genre/List',
        component_props => {
            genres => $genres,
        },
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
