package MusicBrainz::Server::Entity::Link;
use Moose;

use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::DatePeriod';

has 'type_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'type' => (
    is => 'rw',
    isa => 'LinkType',
);

has 'attributes' => (
    is => 'rw',
    isa => 'ArrayRef[LinkAttribute]',
    traits => [ 'Array' ],
    default => sub { [] },
    lazy => 1,
    handles => {
        clear_attributes => 'clear',
        all_attributes   => 'elements',
        add_attribute    => 'push'
    }
);

sub has_attribute
{
    my ($self, $name) = @_;

    $name = lc $name;
    foreach my $attr ($self->all_attributes) {
        my $type = $attr->type;
        if (defined $type->root && lc $type->root->name eq $name) {
            return 1;
        }
    }
    return 0;
}

sub get_attribute
{
    my ($self, $name) = @_;

    my @values;
    $name = lc $name;
    foreach my $attr ($self->all_attributes) {
        my $type = $attr->type;
        if (defined $type->root && lc $type->root->name eq $name) {
            push @values, lc $attr->type->name;
        }
    }
    return \@values;
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
