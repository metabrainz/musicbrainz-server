package MusicBrainz::Server::Entity::Role::Taggable;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

has 'tags' => (
    is => 'rw',
    isa => 'ArrayRef[AggregatedTag]',
    traits => [ 'Array' ],
    handles => {
        all_tags => 'elements',
        add_tag => 'push',
        clear_tags => 'clear'
    }
);

has 'user_tags' => (
    is => 'rw',
    isa => 'ArrayRef[UserTag]',
    traits => [ 'Array' ],
    handles => {
        all_user_tags => 'elements',
        add_user_tag => 'push',
        clear_user_tags => 'clear'
    }
);

1;

=head1 NAME

MusicBrainz::Server::Entity::Role::Taggable

=head1 ATTRIBUTES

=head2 tags

Aggregated collection of all user's tags.

=head2 user_tags

User's tags.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
