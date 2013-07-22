package MusicBrainz::Server::Entity::Subscription::Active;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Entity::Subscription';

requires 'target_id', 'type';

has 'last_edit_sent' => (
    isa => 'Int',
    is => 'ro'
);

1;
