package MusicBrainz::Server::Entity::URL::45worlds;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name {
    my $self = shift;

    if ($self->url =~ m{^(?:http://www.45worlds.com/([a-z0-9]+)/(?:artist|label)/[^/?&#]+)$}i) {
        return '45worlds ' . $1;
    }
    elsif ($self->url =~ m{^(?:http://www.45worlds.com/classical/(composer|conductor|orchestra|soloist)/[^/?&#]+)$}i) {
        return '45worlds classical (' . $1 . ')';
    }
    else {
        return '45worlds';
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2017 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

