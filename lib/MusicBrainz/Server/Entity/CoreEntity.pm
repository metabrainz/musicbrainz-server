package MusicBrainz::Server::Entity::CoreEntity;

use Moose;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

has 'gid' => (
    is => 'rw',
    isa => 'Str'
);

has 'gid_redirects' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_gid_redirect => 'push',
        clear_gid_redirects => 'clear',
        all_gid_redirects => 'elements',
    }
);

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

has 'unaccented_name' => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {%{ $self->$orig }, gid => $self->gid};
};

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
