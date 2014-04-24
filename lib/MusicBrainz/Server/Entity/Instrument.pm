package MusicBrainz::Server::Entity::Instrument;

use Moose;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Instruments qw( l );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';

use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Object Str );

sub l_name {
    my $self = shift;
    return l($self->name);
}

has 'type_id' => (
    is => 'rw',
    isa => 'Int'
    );

has 'type' => (
    is => 'rw',
    isa => 'InstrumentType'
);

sub type_name {
    my ($self) = @_;
    return $self->type ? $self->type->name : undef;
}

sub l_type_name {
    my ($self) = @_;
    return $self->type ? $self->type->l_name : undef;
}

has 'comment' => (
    is => 'rw',
    isa => 'Str'
);

has 'description' => (
    is => 'rw',
    isa => 'Str'
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
