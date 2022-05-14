package MusicBrainz::Server::Entity::UserMood;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'mood_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'mood' => (
    is => 'rw',
    isa => 'Mood',
);

has 'editor_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'editor' => (
    is => 'rw',
    isa => 'Editor',
);

has 'entity_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'entity' => (
    is => 'rw',
    isa => 'Object',
);

has is_upvote => (
    is => 'rw',
    isa => 'Bool',
);

has aggregate_count => (
    is => 'rw',
    isa => 'Int',
);

sub TO_JSON {
    my ($self) = @_;

    return {
        mood => $self->mood->TO_JSON,
        vote => $self->is_upvote ? 1 : -1,
        count => $self->aggregate_count,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Entity::UserMood

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
