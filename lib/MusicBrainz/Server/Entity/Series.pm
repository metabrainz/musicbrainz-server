package MusicBrainz::Server::Entity::Series;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';

has type_id => (
    is => 'rw',
    isa => 'Int'
);

has type => (
    is => 'rw',
    isa => 'SeriesType'
);

sub type_name
{
    my ($self) = @_;
    return $self->type ? $self->type->name : undef;
}

sub l_type_name
{
    my ($self) = @_;
    return $self->type ? $self->type->l_name : undef;
}

has comment => (
    is => 'rw',
    isa => 'Str'
);

has ordering_attribute_id => (
    is => 'rw',
    isa => 'Int'
);

has ordering_attribute => (
    is => 'rw',
    isa => 'LinkAttributeType'
);

has ordering_type_id => (
    is => 'rw',
    isa => 'Int'
);

has ordering_type => (
    is => 'rw',
    isa => 'SeriesOrderingType'
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
