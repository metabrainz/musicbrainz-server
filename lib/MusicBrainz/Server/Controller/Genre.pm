package MusicBrainz::Server::Controller::Genre;
use Moose;

use MusicBrainz::Server::Constants qw( %ENTITIES );

BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub list : Path('/genres') Args(0) {
    my ($self, $c) = @_;

    my @genres = $ENTITIES{tag}{genres};

    $c->stash(
        current_view => 'Node',
        component_path => 'genre/List',
        component_props => {
            genres => @genres
        }
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2018 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
