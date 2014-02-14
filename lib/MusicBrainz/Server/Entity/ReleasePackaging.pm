package MusicBrainz::Server::Entity::ReleasePackaging;

use Moose;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

has 'child_order' => (
    is => 'rw',
    isa => 'Int',
);


has 'parent_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'parent' => (
    is => 'rw',
    isa => 'ReleasePackaging',
);

has 'children' => (
    is => 'rw',
    isa => 'ArrayRef[ReleasePackaging]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_children => 'elements',
        add_child => 'push',
        clear_children => 'clear'
    }
);


has 'description' => (
    is => 'rw',
    isa => 'Str',
);

sub l_name {
    my $self = shift;
    return lp($self->name, 'release_packaging')
}
 
__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
