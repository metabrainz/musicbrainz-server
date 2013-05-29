package MusicBrainz::Server::Entity::LinkType;
use Moose;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Relationships qw( l );

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
    isa => 'LinkType',
);

has 'entity0_type' => (
    is => 'rw',
    isa => 'Str',
);

has 'entity1_type' => (
    is => 'rw',
    isa => 'Str',
);

has 'name' => (
    is => 'rw',
    isa => 'Str',
);

has 'link_phrase' => (
    is => 'rw',
    isa => 'Str',
);

sub l_link_phrase {
    my $self = shift;
    return l($self->link_phrase);
}

has 'reverse_link_phrase' => (
    is => 'rw',
    isa => 'Str',
);

sub l_reverse_link_phrase {
    my $self = shift;
    return l($self->reverse_link_phrase);
}

has 'long_link_phrase' => (
    is => 'rw',
    isa => 'Str',
);

sub l_long_link_phrase {
    my $self = shift;
    return l($self->long_link_phrase);
}

has 'description' => (
    is => 'rw',
    isa => 'Str',
);

sub l_description {
    my $self = shift;
    return l($self->description);
}

has 'child_order' => (
    is => 'rw',
    isa => 'Int',
);

has 'priority' => (
    is => 'rw',
    isa => 'Int',
);

has 'children' => (
    is => 'rw',
    isa => 'ArrayRef[LinkType]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_children => 'elements',
        add_child => 'push',
        clear_children => 'clear'
    }
);

has 'attributes' => (
    is => 'rw',
    isa => 'ArrayRef[LinkTypeAttribute]',
    traits => [ 'Array' ],
    default => sub { [] },
    lazy => 1,
    handles => {
        clear_attributes => 'clear',
        all_attributes => 'elements',
        add_attribute => 'push'
    }
);

sub sorted_children {
    my $self = shift;
    return sort { $a->child_order <=> $b->child_order || lc($a->name) cmp lc($b->name) } $self->all_children;
}

has 'documentation' => (
    is => 'rw'
);

has 'examples' => (
    is => 'rw',
    isa => 'ArrayRef',
    traits => [ 'Array' ],
    handles => {
        all_examples => 'elements',
    }
);

sub published_examples {
    my $self = shift;
    return grep { $_->published } $self->all_examples;
}

sub is_deprecated {
    return shift->description =~ /deprecated/;
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
