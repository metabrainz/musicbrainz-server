package MusicBrainz::Server::Entity::Link;

use Moose;
use MooseX::AttributeHelpers;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::Entity';

has 'type_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'type' => (
    is => 'rw',
    isa => 'LinkType',
);

has 'begin_date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
);

has 'end_date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
);

has 'attributes' => (
    is => 'rw',
    isa => 'HashRef[ArrayRef]',
    metaclass => 'Collection::Hash',
    default => sub { +{} },
    lazy => 1,
    provides => {
        clear => 'clear_attributes',
        exists => 'has_attribute',
        get => 'get_attribute'
    }
);

sub add_attribute
{
    my ($self, $name, $value) = @_;
    if ($self->has_attribute($name)) {
        push @{$self->attributes->{$name}}, $value;
    }
    else {
        $self->attributes->{$name} = [$value];
    }
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
