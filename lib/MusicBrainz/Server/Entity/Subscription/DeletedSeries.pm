package MusicBrainz::Server::Entity::Subscription::DeletedSeries;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Entity::Subscription::Deleted';

__PACKAGE__->meta->make_immutable;
1;
