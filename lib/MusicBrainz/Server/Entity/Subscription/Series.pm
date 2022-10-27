package MusicBrainz::Server::Entity::Subscription::Series;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

with 'MusicBrainz::Server::Entity::Subscription::Active';

has 'series_id' => (
    isa => 'Int',
    is => 'ro',
);

has 'series' => (
    isa => 'Series',
    is => 'rw',
);

sub target_id { shift->series_id }
sub type { 'series' }

1;
