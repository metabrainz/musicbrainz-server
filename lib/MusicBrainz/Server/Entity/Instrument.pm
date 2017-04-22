package MusicBrainz::Server::Entity::Instrument;

use Moose;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Instruments;
use MusicBrainz::Server::Translation::InstrumentDescriptions;

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'InstrumentType' };

use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Object Str );

sub entity_type { 'instrument' }

sub l_name {
    my $self = shift;
    if ($self->comment) {
        return MusicBrainz::Server::Translation::Instruments::lp($self->name, $self->comment);
    } else {
        return MusicBrainz::Server::Translation::Instruments::l($self->name);
    }
}

has 'description' => (
    is => 'rw',
    isa => 'Str'
);

sub l_description {
    my $self = shift;
    return $self->description ? MusicBrainz::Server::Translation::InstrumentDescriptions::l($self->description) : undef;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        description => $self->l_description,
    };
};

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
