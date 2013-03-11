package MusicBrainz::Server::Entity::LinkAttributeType;
use Moose;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Relationships;
use MusicBrainz::Server::Translation::Instruments;
use MusicBrainz::Server::Translation::InstrumentDescriptions;

use MusicBrainz::Server::Constants qw( $INSTRUMENT_ROOT_ID );

extends 'MusicBrainz::Server::Entity';

has 'gid' => (
    is => 'rw',
    isa => 'Str',
);

has 'parent_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'parent' => (
    is => 'rw',
    isa => 'LinkAttributeType',
);

has 'root_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'root' => (
    is => 'rw',
    isa => 'LinkAttributeType',
);

has 'name' => (
    is => 'rw',
    isa => 'Str',
);

sub l_name {
    my $self = shift;
    my $rootid = defined $self->root ? $self->root->id : $self->root_id;
    if ($rootid == $INSTRUMENT_ROOT_ID) {
        return MusicBrainz::Server::Translation::Instruments::l($self->name);
    } else {
        return MusicBrainz::Server::Translation::Relationships::l($self->name);
    }
}

has 'description' => (
    is => 'rw',
    isa => 'Str',
);

sub l_description {
    my $self = shift;
    my $rootid = defined $self->root ? $self->root->id : $self->root_id;
    if ($rootid == $INSTRUMENT_ROOT_ID) {
        return MusicBrainz::Server::Translation::InstrumentDescriptions::l($self->description);
    } else {
        return MusicBrainz::Server::Translation::Relationships::l($self->description);
    }
}

has 'child_order' => (
    is => 'rw',
    isa => 'Int',
);

has 'children' => (
    is => 'rw',
    isa => 'ArrayRef[LinkAttributeType]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_children => 'elements',
        add_child => 'push',
        clear_children => 'clear'
    }
);

sub sorted_children {
    my $self = shift;
    return sort { $a->child_order <=> $b->child_order || lc($a->l_name) cmp lc($b->l_name) } $self->all_children;
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
