package MusicBrainz::Server::Entity::Subscription::Label;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Entity::Subscription::Active';

has 'label_id' => (
    isa => 'Int',
    is => 'ro',
);

has 'label' => (
    isa => 'Label',
    is => 'rw',
);

sub target_id { shift->label_id }
sub type { 'label' }

1;
