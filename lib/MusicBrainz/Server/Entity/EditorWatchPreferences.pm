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
