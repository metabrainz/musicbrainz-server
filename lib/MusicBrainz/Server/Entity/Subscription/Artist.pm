package MusicBrainz::Server::Entity::Subscription::Artist;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Entity::Subscription::Active';

has 'artist_id' => (
    isa => 'Int',
    is => 'ro',
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw',
);

sub target_id { shift->artist_id }
sub type { 'artist' }

__PACKAGE__->meta->make_immutable;
1;
