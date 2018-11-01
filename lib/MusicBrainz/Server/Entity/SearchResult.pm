package MusicBrainz::Server::Entity::SearchResult;

use Moose;
use MusicBrainz::Server::Entity::Types;
use aliased 'MusicBrainz::Server::Entity::Release';
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int );

has 'position' => (
    is => 'rw',
    isa => 'Int'
);

has 'score' => (
    is => 'rw',
    isa => 'Int'
);

has 'entity' => (
    is => 'rw',
    isa => 'Entity'
);

has 'extra' => (
    is => 'rw',
    isa => ArrayRef[
        Dict[
            release             => Release,
            track_position      => Int,
            medium_position     => Int,
            medium_track_count  => Int,
        ]
    ],
    lazy => 1,
    default => sub { [] },
);

sub TO_JSON {
    my ($self) = @_;

    return {
        entity => $self->entity,
        position => $self->position,
        score => $self->score,
        extra   => [map +{
            release             => $_->{release}->TO_JSON,
            track_position      => $_->{track_position},
            medium_position     => $_->{medium_position},
            medium_track_count  => $_->{medium_track_count}
        }, @{ $self->extra }],
    };
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
