package MusicBrainz::Server::Entity::Recording;

use DBDefs;
use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( add_linked_entity );
use List::UtilsBy qw( uniq_by );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Rating';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::ArtistCredit';

sub entity_type { 'recording' }

has 'track_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'track' => (
    is => 'rw',
    isa => 'Track'
);

has 'length' => (
    is => 'rw',
    isa => 'Maybe[Int]'
);

has 'video' => (
    is => 'rw',
    isa => 'Bool',
);

has 'isrcs' => (
    isa     => 'ArrayRef',
    is      => 'ro',
    traits  => [ 'Array' ],
    default => sub { [] },
    handles => {
        add_isrc => 'push',
        all_isrcs => 'elements',
        clear_isrcs => 'clear',
    }
);

has 'first_release_date' => (
    is => 'rw',
    isa => 'Maybe[PartialDate]',
);

sub related_works {
    my $self = shift;
    return uniq_by { $_->id }
    map {
        $_->entity1
    } grep {
        $_->link && $_->link->type && $_->link->type->entity1_type eq 'work'
    } $self->all_relationships;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my @related_works = $self->related_works;
    add_linked_entity('work', $_->id, $_) for @related_works;

    return {
        %{ $self->$orig },
        isrcs   => [map { $_->TO_JSON } $self->all_isrcs],
        length  => $self->length,
        video   => boolean_to_json($self->video),
        related_works => [map { $_->id } @related_works],
        DBDefs->ACTIVE_SCHEMA_SEQUENCE == 26
            ? (first_release_date => $self->first_release_date)
            : (),
    };
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
