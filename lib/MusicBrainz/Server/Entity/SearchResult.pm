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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
