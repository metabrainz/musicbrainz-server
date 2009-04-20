package MusicBrainz::Server::Entity::Artist;

use Moose;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CoreEntity';

has 'sort_name' => (
    is => 'rw',
    isa => 'Str'
);

has 'type_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'type' => (
    is => 'rw',
    isa => 'ArtistType',
);

sub type_name
{
    my ($self) = @_;
    return $self->type ? $self->type->name : undef;
}

has 'gender_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'gender' => (
    is => 'rw',
    isa => 'Gender',
);

sub gender_name
{
    my ($self) = @_;
    return $self->gender ? $self->gender->name : undef;
}

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

has 'country_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'country' => (
    is => 'rw',
    isa => 'Country'
);

has 'comment' => (
    is => 'rw',
    isa => 'Str'
);

has 'edits_pending' => (
    is => 'rw',
    isa => 'Int'
);

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
