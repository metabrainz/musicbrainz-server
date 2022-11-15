package MusicBrainz::Server::Entity::EditorWatchPreferences;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

has [qw( type_id status_id )] => (
    isa => 'Int',
    is => 'ro',
);

has 'types' => (
    isa => 'ArrayRef[ReleaseGroupType]',
    is => 'rw',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        all_types => 'elements'
    }
);

has 'statuses' => (
    isa => 'ArrayRef[ReleaseStatus]',
    is => 'rw',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        all_statuses => 'elements'
    }
);

has 'notify_via_email' => (
    isa => 'Bool',
    is => 'ro'
);

has 'notification_timeframe' => (
    is => 'ro'
);

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
